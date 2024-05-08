#!/bin/bash


while getopts ":p:a:" opt
do
    case $opt in
        p)
        path=$OPTARG
        ;;
        a)
        acc=$OPTARG
        ;;
        ?)
        echo "未知参数"
        exit 1;;
    esac
done

cd $path

ori_path=$path"ori_data/"
fastq_path=$path"ori_fastq/"
mkdir -p $ori_path
mkdir -p $fastq_path


while read line || [[ -n $line ]]; do
    cleaned_line=$(echo "$line" | tr -cd '[:print:]')
    download_command="prefetch -O $path $cleaned_line --force all"

    while true; do
        $download_command

        if [ $? -eq 0 ]; then
            echo "Download of $cleaned_line successful"
            break
        else
            echo "Download of $cleaned_line failed. Retrying..."
        fi

        sleep 5
    done
done < $path${acc}

################################################
# move data 2 new folder

for file in "$(find $path -type f -name "*.sra")"; do
    mv $file $ori_path
done

# # remove empty data folder
find $path -maxdepth 1 -type d -empty -delete

# # # unzip sra data

for file in "$(find $ori_path -type f -name "*.sra")"; do
    fasterq-dump --split-3 $file --outdir $fastq_path
done