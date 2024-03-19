#!/bin/bash


while getopts ":p:f:r:c:e:" opt
do
    case $opt in
        p)
        path=$OPTARG
        ;;
        f)
        F_primer=$OPTARG
        ;;
        r)
        R_primer=$OPTARG
        ;;
        c)
        core=$OPTARG
        ;;
        e)
        error=$OPTARG
        ;;
        ?)
        echo "未知参数"
        exit 1;;
    esac
done

cd $path
temp_path=$path"temp/"
qza_path=$temp_path"qza/"
qza_primer_removal_path=$temp_path"qza_primer_removal/"
temp_file_path=$path"temp/temp_file/"
mkdir -p $temp_path"qza"
mkdir -p $temp_path"qza_primer_removal"

read file_size < $temp_file_path'file_size.txt'

if [ $file_size -gt 0 ]; then
  echo "primer has not been removed"
  qiime cutadapt trim-paired \
    --i-demultiplexed-sequences $qza_path"merge.qza" \
    --p-cores $core \
    --p-anywhere-f $F_primer\
    --p-anywhere-r $R_primer\
    --p-error-rate $error \
    --p-discard-untrimmed \
    --o-trimmed-sequences $qza_primer_removal_path"trimmed-seqs.qza"\
    --verbose
else
  echo "no need cut primer."
  cp $qza_path"merge.qza" $qza_primer_removal_path"trimmed-seqs.qza"
fi
