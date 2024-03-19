#!/bin/bash


while getopts ":p:" opt
do
    case $opt in
        p)
        path=$OPTARG
        ;;
        ?)
        echo "未知参数"
        exit 1;;
    esac
done

cd $path

temp_path=$path"temp/"
mkdir -p $temp_path"qza"
qza_path=$temp_path"qza/"
mkdir -p $path"temp/temp_file"
temp_file_path=$path"temp/temp_file/"

qiime tools import \
  --type 'SampleData[PairedEndSequencesWithQuality]' \
  --input-path $temp_file_path'manifest.tsv' \
  --output-path $qza_path"merge.qza" \
  --input-format PairedEndFastqManifestPhred33V2