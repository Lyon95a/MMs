#!/bin/bash


dl_sra_to_fq() {
    OPTIND=1
    local dir_path script_path acc error core
    while getopts ":d:s:a:e:c:" opt;do
        case $opt in
            d)
                dir_path=$OPTARG
                ;;
            s)
                script_path=$OPTARG
                ;;
            a)
                acc=$OPTARG
                ;;
            e)
                error=$OPTARG
                ;;
            c)
                core=$OPTARG
                ;;
            ?)
                echo "Unknown Parameter: -$OPTARG"
                return 1
                ;;
        esac
    done

    cd $dir_path
    echo $dir_path
    echo $dir_path$acc
    # define path variable, and create path.
    ori_path=$dir_path"ori_data/"
    fastq_path=$dir_path"ori_fastq/"
    mkdir -p $ori_path
    mkdir -p $fastq_path
    mkdir -p $dir_path"temp1/"
    temp_dl_path=$dir_path"temp1/"
    exec 3<"$dir_path$acc"

    while read -u 3 line || [[ -n $line ]]; do
        cleaned_line=$(echo "$line" | tr -cd '[:print:]')
        cleaned_line_sra=$(echo "$line" | cut -f1)
        cleaned_line_rename=$(echo "$line" | cut -f2)
        download_command="prefetch -O $temp_dl_path $cleaned_line_sra"
        while true; do
            $download_command
            if [ $? -eq 0 ]; then
                echo "Download of $cleaned_line successful"
                break
            else
                echo "Download of $cleaned_line failed. Retrying..."
                sleep 5
            fi
        done
    done

    exec 3<&-
    for file in "$(find $temp_dl_path -type f -name "*.sra")"; do
        basename_sra=$(basename "$file")
        new_name=$cleaned_line_rename"_"$basename_sra
        mv $file $temp_dl_path$new_name
        mv $temp_dl_path$new_name $ori_path
    done
    # remove empty data folder
    rm -r $temp_dl_path
    # unzip sra to fastq
    for file in "$(find $ori_path -type f -name "*.sra")"; do
        fasterq-dump --split-3 $file --outdir $fastq_path
    done
    # remove sra data
    rm -r $ori_path
}

# Define function 2
fastq_to_fastp() {
    OPTIND=1
    local dir_path script_path acc error core
    while getopts ":d:s:a:e:c:" opt;do
        case $opt in
            d)
                dir_path=$OPTARG
                ;;
            s)
                script_path=$OPTARG
                ;;
            a)
                acc=$OPTARG
                ;;
            e)
                error=$OPTARG
                ;;
            c)
                core=$OPTARG
                ;;
            ?)
                echo "Unknown Parameter"
                exit 1
                ;;
        esac
    done
    cd $dir_path
    fastq_path=$dir_path"ori_fastq/"
    mkdir -p $dir_path"temp/fastp_out/"
    fastp_out_path=$dir_path"temp/fastp_out/"
    find $fastq_path -type f -name "*_1.fastq"| while read -r file; do
        filename=$(basename "$file")
        base_name=$(echo $filename | sed 's/_1\.fastq//')
        read1="$fastq_path$base_name""_1.fastq"
        read2="$fastq_path$base_name""_2.fastq"
        out1="$fastp_out_path$base_name""_fastp_1.fastq"
        out2="$fastp_out_path$base_name""_fastp_2.fastq"
        fastp -Q -G -i $read1 -o $out1 -I $read2 -O $out2
    done
}


# Call the functions if script_a.sh is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    dl_sra_to_fq
    fastq_to_fastp
    make_manifest
    primer_detection
    import_to_qiime2
    qiime_trim
    Trim_pos_decied
    denoise
    denoise_view
fi
