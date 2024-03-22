#!/bin/bash

while getopts ":m:s:d:a:f:r:" opt
do
    case $opt in
        m)
        metafile=$OPTARG
        ;;
        s)
        script_path=$OPTARG
        ;;
        d)
        Data_col_name=$OPTARG
        ;;
        a)
        sra=$OPTARG
        ;;
        f)
        forward=$OPTARG
        ;;
        r)
        reverse=$OPTARG
        ;;
        ?)
        echo "未知参数"
        exit 1;;
    esac
done

source /home/data/t230307/miniconda3/etc/profile.d/conda.sh
echo "activate environment"
conda activate qiime2_amplicon
echo "activate environment1"



father_path=$(dirname "$metafile")
meta_file_basename=$(basename "$metafile")

if [[ ! "$father_path" =~ /$ ]]; then
    father_path="$father_path/"
fi

python $script_path"make_clean_meta.py" $metafile $Data_col_name $sra $forward $reverse

while IFS= read -r line; do
    F_primer=$(echo "$line" | awk '{print $2}')
    R_primer=$(echo "$line" | awk '{print $3}')
    dataset_name=$(echo "$line" | awk '{print $1}')
    if [ -n "$F_primer" ]; then
        bash $script_path'auto_amplicon_script.sh' -p $father_path -d $dataset_name -s $script_path -f $F_primer -r $R_primer
    else
        continue
    fi
done < $father_path'primer.tsv'