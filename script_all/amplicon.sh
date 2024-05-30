#!/bin/bash


dl_sra_to_fq() {
    OPTIND=1
    local dir_path script_path acc
    while getopts ":d:s:a:" opt;do
        case $opt in
            d) dir_path=$OPTARG ;;
            s) script_path=$OPTARG ;;
            a) acc=$OPTARG ;;
            ?) echo "Unknown Parameter: -$OPTARG";return 1 ;;
        esac
    done

    cd $dir_path
    echo "Processing" $dir_path
    # define path variable, and create path.
    local ori_path=${dir_path}"ori_data/"
    local fastq_path=${dir_path}"ori_fastq/"
    local temp_dl_path=${dir_path}"temp1/"

    mkdir -p "$ori_path" "$fastq_path" "$temp_dl_path"

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

fastq_to_fastp() {
    OPTIND=1
    local dir_path script_path
    while getopts ":d:s:" opt;do
        case $opt in
            d) dir_path=$OPTARG ;;
            s) script_path=$OPTARG ;;
            ?) echo "Unknown Parameter: -$OPTARG";return 1 ;;
        esac
    done
    cd $dir_path
    local fastq_path=$dir_path"ori_fastq/"
    local fastp_out_path=$dir_path"temp/step_01_fastp/"
    mkdir -p "$fastp_out_path"
    
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
    local dir_path script_path dataset_name
    while getopts ":d:s:n:" opt;do
        case $opt in
            d) dir_path=$OPTARG ;;
            s) script_path=$OPTARG ;;
            n) dataset_name=$OPTARG ;;
            ?) echo "Unknown Parameter: -$OPTARG";return 1 ;;
        esac
    done
    cd $dir_path
    local fastq_path=$dir_path"ori_fastq/"
    local fastp_out_path=$dir_path"temp/step_01_fastp/"
    local temp_file_path=$dir_path"temp/temp_file/"
    mkdir -p "$temp_file_path"

    find $fastp_out_path -type f > $temp_file_path"file_paths.txt"
    python $script_path"make_manifest.py" $temp_file_path"file_paths.txt" $fastp_out_path $dataset_name
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
            ?) echo "Unknown Parameter: -$OPTARG";return 1 ;;
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
    local dir_path dataset_name
    while getopts ":d:n:" opt;do
        case $opt in
            d) dir_path=$OPTARG ;;
            n) dataset_name=$OPTARG ;;
            ?) echo "Unknown Parameter: -$OPTARG";return 1 ;;
        esac
    done
    cd $dir_path
    local temp_path=$dir_path"temp/"
    local temp_file_path=$dir_path"temp/temp_file/"
    local qza_path=$temp_path"step_02_qza_import/"
    mkdir -p "$temp_file_path" "$qza_path"
    
    qiime tools import \
        --type 'SampleData[PairedEndSequencesWithQuality]' \
        --input-path $temp_file_path$dataset_name"_manifest.tsv" \
        --output-path $qza_path$dataset_name"_import.qza" \
        --input-format PairedEndFastqManifestPhred33V2
}

q2_cutadapt() {
    OPTIND=1
    local dir_path error core dataset_name
    while getopts ":d:e:c:n:" opt
    do
      case $opt in
          d) dir_path=$OPTARG ;;
          e) error=$OPTARG ;;
          c) core=$OPTARG ;;
          n) dataset_name=$OPTARG ;;
          ?) echo "Unknown Parameter: -$OPTARG";return 1 ;;
      esac
    done
    cd $dir_path

    local cutadapt_path=$dir_path"temp/step_03_qza_import_cutadapt/"
    local qza_path=$dir_path"temp/step_02_qza_import/"
    #local qza_primer_removal_path=$dir_path"temp/step_04_qza_import_QualityFilter_cutadapt/"
    local temp_file_path=$dir_path"temp/temp_file/"
    mkdir -p "$cutadapt_path"

    qiime cutadapt trim-paired \
        --i-demultiplexed-sequences $qza_path$dataset_name"_import.qza" \
        --p-cores $core \
        --p-error-rate $error \
        --o-trimmed-sequences $cutadapt_path$dataset_name"_import_cutadapt.qza" \
        --verbose
}

quality_control(){
    OPTIND=1
    local dir_path dataset_name
    while getopts ":d:n:" opt
    do
      case $opt in
          d) dir_path=$OPTARG ;;
          n) dataset_name=$OPTARG ;;
          ?) echo "Unknown Parameter: -$OPTARG";return 1 ;;
      esac
    done
    cd $dir_path
    local cutadapt_path=$dir_path"temp/step_03_qza_import_cutadapt/"
    local quality_filter_path=$dir_path"temp/step_04_qza_import_cutadapt_QualityFilter/"
    local qf_vis_path=$dir_path"temp/temp_file/QualityFilter_vis/"
    mkdir -p "$quality_filter_path" "$qf_vis_path"

    qiime quality-filter q-score \
        --i-demux $cutadapt_path$dataset_name"_import_cutadapt.qza" \
        --p-min-quality 20 \
        --o-filtered-sequences $quality_filter_path$dataset_name"_import_cutadapt_QualityFilter.qza" \
        --o-filter-stats $quality_filter_path$dataset_name"_filter-stats.qza" \
        --verbose
    qiime demux summarize \
        --i-data $quality_filter_path$dataset_name"_import_cutadapt_QualityFilter.qza" \
        --o-visualization $qf_vis_path$dataset_name"_import_cutadapt_QualityFilter.qzv"
}


deblur_denoise() {
    OPTIND=1
    local dir_path dataset_name core 
    while getopts ":d:n:c:" opt;do
        case $opt in
            d) dir_path=$OPTARG ;;
            n) dataset_name=$OPTARG ;;
            c) core=$OPTARG ;;
            ?) echo "Unknown Parameter: -$OPTARG";return 1 ;;
        esac
    done
    cd $dir_path
    local quality_filter_path=$dir_path"temp/step_04_qza_import_cutadapt_QualityFilter/"
    local deblur_path=$dir_path"temp/step_05_qza_import_cutadapt_QualityFilter_deblur/"
    mkdir -p $deblur_path


    qiime deblur denoise-16S \
          --i-demultiplexed-seqs $quality_filter_path$dataset_name"_import_QualityFilter.qza" \
          --p-trim-length 0 \
          --o-representative-sequences $deblur_path'rep-seqs-deblur.qza' \
          --o-table $deblur_path'table-deblur.qza' \
          --p-sample-stats \
          --o-stats $deblur_path'deblur-stats.qza'

}


dada_denoise() {
    OPTIND=1
    local dir_path dataset_name core 
    while getopts ":d:n:c:" opt;do
        case $opt in
            d) dir_path=$OPTARG ;;
            n) dataset_name=$OPTARG ;;
            c) core=$OPTARG ;;
            ?) echo "Unknown Parameter: -$OPTARG";return 1 ;;
        esac
    done
    cd $dir_path
    local qza_primer_removal_path=$dir_path"temp/step_04_qza_import_QualityFilter_cutadapt/"
    local cutadapt_trim_pos_path=$dir_path"temp/temp_file/cutadapt_vis/cutadapt_trim_pos/"
    local denoise_path=$dir_path"temp/step_05_qza_import_QualityFilter_cutadapt_DADAdenoise/"
    local dada_denoise_vis_path=$dir_path"temp/temp_file/dada_denoise_vis/"
    local vis_path=$dir_path"temp/temp_file/cutadapt_vis/"
    local cutadapt_view_path=$dir_path"temp/temp_file/cutadapt_vis/cutadapt_view/"
    mkdir -p "$denoise_path" "$dada_denoise_vis_path"
    mkdir -p "$vis_path" "$cutadapt_view_path" "$cutadapt_trim_pos_path"
    
    qiime demux summarize \
        --i-data $qza_primer_removal_path$dataset_name"_import_QualityFilter_cutadapt.qza" \
        --o-visualization $vis_path$dataset_name"_cutadapt.qzv"

    unzip $vis_path$dataset_name"_cutadapt.qzv" -d $cutadapt_view_path
    find $cutadapt_view_path -type f -name 'forward-seven-number-summaries.tsv' -exec cp {} $trim_pos_path \;
    find $cutadapt_view_path -type f -name 'reverse-seven-number-summaries.tsv' -exec cp {} $trim_pos_path \;
    rm -rf $cutadapt_view_path

    forward_result=$(python $script_path"Trim_pos.py" $trim_pos_path'forward-seven-number-summaries.tsv' )
    IFS=',' read -r forward_start forward_end <<< "$forward_result"
    echo "forward start at: $forward_start"
    echo "forward end at: $forward_end"

    reverse_result=$(python $script_path"Trim_pos.py" $trim_pos_path'reverse-seven-number-summaries.tsv' )
    IFS=',' read -r reverse_start reverse_end <<< "$reverse_result"
    echo "reverse start at: $reverse_start"
    echo "reverse end at: $reverse_end"

    echo "$forward_start $forward_end $reverse_start $reverse_end" > $cutadapt_trim_pos_path'Trim_position.txt'
    

    read forward_start forward_end reverse_start reverse_end < $cutadapt_trim_pos_path'Trim_position.txt'
    let forward_start1=forward_start+20
    let reverse_start1=reverse_start+20
    #--p-min-fold-parent-over-abundance 8 \
    qiime dada2 denoise-paired \
        --i-demultiplexed-seqs $qza_primer_removal_path$dataset_name"_import_QualityFilter_cutadapt.qza" \
        --p-trunc-len-f $forward_end \
        --p-trunc-len-r $reverse_end \
        --p-trim-left-f $forward_start1 \
        --p-trim-left-r $reverse_start1 \
        --o-representative-sequences $denoise_path$dataset_name'_import_QualityFilter_cutadapt_DADAdenoise_RepSeqs.qza' \
        --o-denoising-stats $denoise_path$dataset_name'_denoising_stats.qz' \
        --o-table $denoise_path$dataset_name'_import_QualityFilter_cutadapt_DADAdenoise_merged_table.qza' \
        --p-n-threads $core \
        --verbose

    qiime metadata tabulate \
        --m-input-file $denoise_path$dataset_name'_denoising_stats.qz' \
        --o-visualization $dada_denoise_vis_path$dataset_name"_denoise.qzv"
    
    local dada_denoise_vis_path=$dir_path"temp/temp_file/dada_denoise_vis/"
    local denoise_view_path=$dada_denoise_vis_path"denoise_view/"
    mkdir -p $denoise_view_path


    unzip $dada_denoise_vis_path$dataset_name"_denoise.qzv" -d $denoise_view_path
    find $denoise_view_path -type f -name 'stats.tsv' -exec cp {} $dada_denoise_vis_path \;
    rm -rf $denoise_view_path
}

tax_g2() {
    OPTIND=1
    local dir_path acc v4_ref_path No_v4_db_path dataset_name
    while getopts ":d:a:e:y:z:n:" opt;do
        case $opt in
            d) dir_path=$OPTARG ;;
            a) acc=$OPTARG ;;
            y) v4_ref_path=$OPTARG ;;
            z) No_v4_db_path=$OPTARG ;;
            n) dataset_name=$OPTARG ;;
            ?) echo "Unknown Parameter: -$OPTARG";return 1 ;;
        esac
    done
    cd $dir_path
    local denoise_path=$dir_path"temp/step_05_qza_import_QualityFilter_cutadapt_DADAdenoise/"
    local final_result=$dir_path"temp/step_06_qza_import_QualityFilter_cutadapt_DADAdenoise_gg2/"
    mkdir -p "$final_result"
    
    
    region=$(awk 'NR==2 {print $3}' $dir_path$acc)
    if [ "$region" = "v4" ]; then
        qiime greengenes2 taxonomy-from-table \
                          --i-reference-taxonomy $v4_ref_path \
                          --i-table $denoise_path$dataset_name'_import_QualityFilter_cutadapt_DADAdenoise_merged_table.qza' \
                          --o-classification $final_result$dataset_name"_gg2_taxonomy.qza"
    else
        qiime greengenes2 non-v4-16s \
                          --i-table $denoise_path$dataset_name'_import_QualityFilter_cutadapt_DADAdenoise_merged_table.qza' \
                          --i-sequences $denoise_path$dataset_name'_import_QualityFilter_cutadapt_DADAdenoise_RepSeqs.qza' \
                          --i-backbone $No_v4_db_path \
                          --o-mapped-table $final_result$dataset_name'_gg2_table.qza' \
                          --o-representatives $final_result'_gg2_final_rep_seq.qza'
        qiime greengenes2 taxonomy-from-table \
                          --i-reference-taxonomy $v4_ref_path \
                          --i-table $final_result$dataset_name'_gg2_table.qza' \
                          --o-classification $final_result$dataset_name"_gg2_taxonomy.qza"
    fi
}


# Call the functions if script_a.sh is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    dl_sra_to_fq
    fastq_to_fastp
    make_manifest
    primer_detection
    import_to_qiime2
    quality_control
    q2_cutadapt
    dada_denoise
    deblur_denoise
    tax_g2
fi
