#!/bin/bash

while getopts ":p:d:n:" opt
do
    case $opt in
        p)
        path=$OPTARG
        ;;
        d)
        dbpath=$OPTARG
        ;;
        n)
        dbname=$OPTARG
        ;;
        ?)
        echo "未知参数"
        exit 1;;
    esac
done


cd $path

full_path=$dbpath


cd $path 

fastq_path=$path"ori_fastq/"
bowtie_pathname="bowtie_"$dbname
bowtie_process_path=$path"temp/"$bowtie_pathname"/"
mkdir -p $bowtie_process_path
fastp_out_path=$path"temp/fastp_out/"




start=`date +%s`
find $fastp_out_path -type f -name "*_1.fastq"| while read -r file; do
    filename=$(basename "$file")
    base_name=$(echo $filename | sed 's/_1\.fastq//')
    read1="$fastp_out_path$base_name""_1.fastq"
    read2="$fastp_out_path$base_name""_2.fastq"
    bowtie2 --very-sensitive-local \
            -p 24 \
            -D 20\
            -R 3\
            -x $dbname_no_extension_path$dbname_no_extension \
            -1 $read1 \
            -2 $read2 \
            -S $bowtie_process_path$base_name"_mapped_unmapped.sam"|\
            samtools view -bh - |\
            samtools view -bh -f 12 -F 256 - |\
            samtools sort -n - | \
            bedtools bamtofastq -i - -fq $bowtie_process_path/${base_name}_hostrmvd_1.fastq -fq2 $bowtie_process_path/${base_name}_hostrmvd_2.fastq
##双端测序数据去宿主：
done
end=`date +%s`
runtime=$((end-start))
echo Runtime: $runtime seconds
