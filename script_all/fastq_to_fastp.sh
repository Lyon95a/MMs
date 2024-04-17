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
fastq_path=$path"ori_fastq/"
mkdir -p $path"temp/fastp_out/"
fastp_out_path=$path"temp/fastp_out/"
find $fastq_path -type f -name "*_1.fastq"| while read -r file; do
    filename=$(basename "$file")
    base_name=$(echo $filename | sed 's/_1\.fastq//')
    read1="$fastq_path$base_name""_1.fastq"
    read2="$fastq_path$base_name""_2.fastq"
    out1="$fastp_out_path$base_name""_fastp_1.fastq"
    out2="$fastp_out_path$base_name""_fastp_2.fastq"
    fastp -i $read1 -o $out1 -I $read2 -O $out2
done



