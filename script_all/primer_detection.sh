#!/bin/bash


while getopts ":p:m:f:" opt
do
    case $opt in
        p)
        path=$OPTARG
        ;;
        m)
        mismatch=$OPTARG
        ;;
        f)
        F_primer=$OPTARG
        ;;
        ?)
        echo "未知参数"
        exit 1;;
    esac
done




cd $path

temp_file_path=$path"temp/temp_file/"
fastq_path=$path"ori_fastq/"

first_file=$(find $fastq_path -type f -name "*_R1.fastq" | head -n 1)

head -10000 $first_file > $temp_file_path'f10000_R1.fastq'
seqkit grep -m ${mismatch} -p ${F_primer} $temp_file_path'f10000_R1.fastq' > $temp_file_path'primer_detection.txt'
 
file_size=$(stat -c %s $temp_file_path'primer_detection.txt')

echo "$file_size" > $temp_file_path'file_size.txt'