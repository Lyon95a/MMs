#!/bin/bash


while getopts ":p:s:" opt
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
fastq_path=$path"ori_fastq/"
mkdir -p $path"temp/temp_file"
temp_file_path=$path"temp/temp_file/"

find $fastq_path -type f > $temp_file_path"file_paths.txt"
python $script_path"make_manifest.py" $temp_file_path"file_paths.txt" $fastq_path 