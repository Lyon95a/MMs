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
        for file in "$(find $temp_dl_path -type f -name "*.sra")"; do
            basename_sra=$(basename "$file")
            new_name=$cleaned_line_rename"_"$basename_sra
            mv $file $temp_dl_path$new_name
            mv $temp_dl_path$new_name $ori_path
        done
    done
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

# Define function 3
make_manifest() {
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
    fastp_out_path=$dir_path"temp/fastp_out/"
    fastq_path=$dir_path"ori_fastq/"
    mkdir -p $dir_path"temp/temp_file"
    temp_file_path=$dir_path"temp/temp_file/"
    find $fastp_out_path -type f > $temp_file_path"file_paths.txt"
    python $script_path"make_manifest.py" $temp_file_path"file_paths.txt" $fastp_out_path
}

primer_detection() {
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
    temp_file_path=$dir_path"temp/temp_file/"
    fastp_out_path=$dir_path"temp/fastp_out/"
    first_file=$(find $fastq_path -type f -name "*_R1.fastq" | head -n 1)
    head -10000 $first_file > $temp_file_path'f10000_R1.fastq'
    seqkit grep -m ${mismatch} -p ${F_primer} $temp_file_path'f10000_R1.fastq' > $temp_file_path'primer_detection.txt'
    file_size=$(stat -c %s $temp_file_path'primer_detection.txt')
    echo "$file_size" > $temp_file_path'file_size.txt'
}

import_to_qiime2() {
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
    temp_path=$dir_path"temp/"
    mkdir -p $temp_path"qza"
    qza_path=$temp_path"qza/"
    mkdir -p $dir_path"temp/temp_file"
    temp_file_path=$dir_path"temp/temp_file/"
    qiime tools import \
        --type 'SampleData[PairedEndSequencesWithQuality]' \
        --input-path $temp_file_path'manifest.tsv' \
        --output-path $qza_path"merge.qza" \
        --input-format PairedEndFastqManifestPhred33V2
}

qiime_trim() {
    OPTIND=1
    local dir_path script_path acc error core
    while getopts ":d:s:a:e:c:" opt
    do
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
          exit 1;;
      esac
    done
    cd $dir_path
    temp_path=$dir_path"temp/"
    qza_path=$temp_path"qza/"
    qza_primer_removal_path=$temp_path"qza_primer_removal/"
    temp_file_path=$dir_path"temp/temp_file/"
    mkdir -p $temp_path"qza"
    mkdir -p $temp_path"qza_primer_removal"

    qiime cutadapt trim-paired \
        --i-demultiplexed-sequences $qza_path"merge.qza" \
        --p-cores $core \
        --p-error-rate $error \
        --p-quality-cutoff-5end 15 \
        --p-quality-cutoff-3end 15 \
        --o-trimmed-sequences $qza_primer_removal_path"trimmed-seqs.qza"\
        --verbose
}

Trim_pos_decied() {
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
    temp_path=$dir_path"temp/"
    vis_path=$temp_path"vis/"
    qza_primer_removal_path=$temp_path"qza_primer_removal/"
    trim_view_path=$vis_path"trim_view/"
    trim_pos_path=$vis_path"trim_pos/"
    mkdir -p $temp_path"vis"
    mkdir -p $vis_path"trim_view"
    mkdir -p $vis_path"trim_pos"
    mkdir -p $dir_path"temp/temp_file/"
    temp_file_path=$dir_path"temp/temp_file/"
    qiime demux summarize \
        --i-data $qza_primer_removal_path"trimmed-seqs.qza" \
        --o-visualization $vis_path"trimmed-seqs.qzv"

    unzip $vis_path"trimmed-seqs.qzv" -d $trim_view_path
    find $trim_view_path -type f -name 'forward-seven-number-summaries.tsv' -exec cp {} $trim_pos_path \;
    find $trim_view_path -type f -name 'reverse-seven-number-summaries.tsv' -exec cp {} $trim_pos_path \;
    rm -rf $trim_view_path

    forward_result=$(python $script_path"Trim_pos.py" $trim_pos_path'forward-seven-number-summaries.tsv' )
    IFS=',' read -r forward_start forward_end <<< "$forward_result"
    echo "forward start at: $forward_start"
    echo "forward end at: $forward_end"

    reverse_result=$(python $script_path"Trim_pos.py" $trim_pos_path'reverse-seven-number-summaries.tsv' )
    IFS=',' read -r reverse_start reverse_end <<< "$reverse_result"
    echo "reverse start at: $reverse_start"
    echo "reverse end at: $reverse_end"

    echo "$forward_start $forward_end $reverse_start $reverse_end" > $temp_file_path'Trim_position.txt'
    
}

denoise() {
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
    temp_path=$dir_path"temp/"
    mkdir -p $temp_path"filtered_reads"
    mkdir -p $temp_path"vis"
    temp_file_path=$dir_path"temp/temp_file/"
    filter_reads_path=$temp_path"filtered_reads/"

    vis_path=$temp_path"vis/"
    qza_primer_removal_path=$temp_path"qza_primer_removal/"

    read forward_start forward_end reverse_start reverse_end < $temp_file_path'Trim_position.txt'
    qiime dada2 denoise-paired \
        --i-demultiplexed-seqs $qza_primer_removal_path"trimmed-seqs.qza" \
        --p-trunc-len-f $forward_end \
        --p-trunc-len-r $reverse_end \
        --p-trim-left-f $forward_start \
        --p-trim-left-r $reverse_start \
        --o-representative-sequences $filter_reads_path$dataset_name'_all_rep_seqs.qza' \
        --o-denoising-stats $filter_reads_path'denoising_stats.qz' \
        --o-table $filter_reads_path$dataset_name'_merged_table.qza' \
        --p-n-threads $core

    qiime metadata tabulate \
        --m-input-file $filter_reads_path"denoising_stats.qz.qza" \
        --o-visualization $vis_path"denoise.qzv"
}

denoise_view() {
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
    temp_path=$dir_path"temp/"
    vis_path=$temp_path"vis/"
    denoise_view_path=$vis_path"denoise_view/"
    mkdir -p $vis_path"denoise_view"


    unzip $vis_path"denoise.qzv" -d $denoise_view_path
    find $trim_view_path -type f -name 'metadata.tsv' -exec cp {} $trim_pos_path \;
    find $trim_view_path -type f -name 'reverse-seven-number-summaries.tsv' -exec cp {} $trim_pos_path \;
    rm -rf $trim_view_path

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
