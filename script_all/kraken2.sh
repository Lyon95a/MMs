#!/bin/bash

while getopts ":p:d:n:r:l:t:" opt
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
        r)
        READ_LEN=$OPTARG
        ;;
        l)
        LEVEL=$OPTARG
        ;;
        t)
        THRESHOLD=$OPTARG
        ;;
        ?)
        echo "未知参数"
        exit 1;;
    esac
done





cd $path 

fastq_path=$path"ori_fastq/"
bowtie_pathname="bowtie_"$dbname
bowtie_process_path=$path"temp/"$bowtie_pathname"/"
mkdir -p $bowtie_process_path
fastp_out_path=$path"temp/fastp_out/"

kraken2_process_path=$path"temp/kraken2/"
mkdir -p $krakenuniq_process_path

start=`date +%s`
find $bowtie_process_path -type f -name "*_1.fastq"| while read -r file; do
    echo $file
    filename=$(basename "$file")
    echo $filename
    base_name=$(echo $filename | sed 's/_1\.fastq//')
    read1=${bowtie_process_path}${base_name}"_1.fastq"
    echo $read1
    read2=${bowtie_process_path}${base_name}"_2.fastq"
    kraken2 \
           --db ${dbpath} \
           --threads 24 \
           --report ${kraken2_process_path}${base_name}.kraken2.kreprot \
           --fastq-input \
           --confidence 0.67 \
           --paired \
           $read1 $read2 \
           > ${base_name}.kraken
    bracken \
           -d ${dbpath} \
           -i ${kraken2_process_path}${base_name}.kraken2.kreport \
           -o ${kraken2_process_path}${base_name}.bracken \
           -r ${READ_LEN} \
           -l ${LEVEL} \
           -t ${THRESHOLD}
done
end=`date +%s`
runtime=$((end-start))
echo Runtime: $runtime seconds




#krakenuniq \
#	--db $dbpath \
#	--preload \
#	--threads 24

