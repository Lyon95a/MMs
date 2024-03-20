#!/bin/bash


while getopts ":p:d:c:" opt
do
    case $opt in
        p)
        path=$OPTARG
        ;;
        d)
        dataset_name=$OPTARG
        ;;
        c)
        core=$OPTARG
        ;;
        ?)
        echo "未知参数"
        exit 1;;
    esac
done

cd $path
temp_path=$path"temp/"
mkdir -p $temp_path"filtered_reads"
mkdir -p $temp_path"vis"
temp_file_path=$path"temp/temp_file/"
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