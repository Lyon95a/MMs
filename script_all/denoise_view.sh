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

temp_path=$path"temp/"
vis_path=$temp_path"vis/"
denoise_view_path=$vis_path"denoise_view/"
mkdir -p $vis_path"denoise_view"


unzip $vis_path"denoise.qzv" -d $denoise_view_path
find $trim_view_path -type f -name 'metadata.tsv' -exec cp {} $trim_pos_path \;
find $trim_view_path -type f -name 'reverse-seven-number-summaries.tsv' -exec cp {} $trim_pos_path \;
rm -rf $trim_view_path