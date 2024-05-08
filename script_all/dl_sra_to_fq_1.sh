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
# define path variable, and create path.
ori_path=$path"ori_data/"
fastq_path=$path"ori_fastq/"
mkdir -p $ori_path
mkdir -p $fastq_path
mkdir -p $path"temp1/"
temp_dl_path=$path"temp1/"



# logic: read file by line. each line have two variable, download data based on sra number and rename it. if download failed caused by internet problem, retry it.

# why use this: tr -cd '[:print:]'  because the read line command in Linux will stops reading when it encounters the end of the line or the end of the file. 
# If the last line in the file does not end with a newline character (\n), the read line command will not be able to read it. therefore, use tr -cd '[:print:]' to
# avoid this problem.

# cut -f1 to select first variable


while read line || [[ -n $line ]]; do
    cleaned_line=$(echo "$line" | tr -cd '[:print:]')
    cleaned_line_sra=$(echo "$line" | cut -f1)
    cleaned_line_rename=$(echo "$line" | cut -f2)
    download_command="prefetch -O $temp_dl_path $cleaned_line_sra"
    for file in "$(find $temp_dl_path -type f -name "*.sra")"; do
        basename_sra=$(basename "$file")
        new_name=$cleaned_line_rename"_"$basename_sra
        mv $file $temp_dl_path$new_name
        mv $temp_dl_path$new_name $ori_path
    done

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

# remove empty data folder

rm -r $temp_dl_path

# unzip sra to fastq

for file in "$(find $ori_path -type f -name "*.sra")"; do
    fasterq-dump --split-3 $file --outdir $fastq_path
done
# remove sra data
rm -r $ori_path