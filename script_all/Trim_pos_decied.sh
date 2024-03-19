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
qza_primer_removal_path=$temp_path"qza_primer_removal/"
trim_view_path=$vis_path"trim_view/"
trim_pos_path=$vis_path"trim_pos/"
mkdir -p $temp_path"vis"
mkdir -p $vis_path"trim_view"
mkdir -p $vis_path"trim_pos"
mkdir -p $path"temp/temp_file/"
temp_file_path=$path"temp/temp_file/"


qiime demux summarize \
  --i-data $qza_primer_removal_path"trimmed-seqs.qza" \
  --o-visualization $vis_path"trimmed-seqs.qzv"



unzip $vis_path"trimmed-seqs.qzv" -d $trim_view_path
find $trim_view_path -type f -name 'forward-seven-number-summaries.tsv' -exec cp {} $trim_pos_path \;
find $trim_view_path -type f -name 'reverse-seven-number-summaries.tsv' -exec cp {} $trim_pos_path \;
rm -rf $trim_view_path

forward_result=$(python $script_path"Trim_pos.py" $trim_pos_path'forward-seven-number-summaries.tsv' )
IFS=',' read -r forward_start forward_end <<< "$forward_result"
echo "forward start at: $forward_start"
echo "forward end at: $forward_end"

reverse_result=$(python $script_path"Trim_pos.py" $trim_pos_path'reverse-seven-number-summaries.tsv' )
IFS=',' read -r reverse_start reverse_end <<< "$reverse_result"
echo "reverse start at: $reverse_start"
echo "reverse end at: $reverse_end"

echo "$forward_start $forward_end $reverse_start $reverse_end" > $temp_file_path'Trim_position.txt'
