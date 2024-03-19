#!/bin/bash


while getopts ":p:d:" opt
do
    case $opt in
        p)
        path=$OPTARG
        ;;
        s)
        script_path=$OPTARG
        ;;
        ?)
        echo "未知参数"
        exit 1;;
    esac
done

cd $path
temp_path=$path"temp/"
filter_reads_path=$temp_path"filtered_reads/"
mkdir $dataset_name'_final_result'
final_result=$path$dataset_name"_final_result/"


qiime greengenes2 non-v4-16s \
  --i-table $filter_reads_path'merged-table.qza' \
  --i-sequences $filter_reads_path'all-rep-seqs.qza' \
  --i-backbone $No_v4_db_path \
  --o-mapped-table $final_result'gg_table.qza' \
  --o-representatives $final_result'final_rep_seq.qza'

qiime greengenes2 taxonomy-from-table \
  --i-reference-taxonomy $v4_db_path \
  --i-table $final_result'gg_table.qza' \
  --o-classification $final_result'taxonomy.qza'