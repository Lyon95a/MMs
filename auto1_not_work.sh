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




F_primer=""
R_primer=""
dataset_name=""
read -r dataset_name F_primer R_primer < <(head -n 8 $father_path'primer.tsv' | tail -n 1 | awk -F'\t' '{print $1, $2, $3}')
if [ -n "$F_primer" ]; then
    bash $script_path'auto_amplicon_script.sh' -p $father_path -d $dataset_name -s $script_path -f $F_primer -r $R_primer > $father_path$dataset_name'_output.log'
else
    continue
fi

F_primer=""
R_primer=""
dataset_name=""
read -r dataset_name F_primer R_primer < <(head -n 2 $father_path'primer.tsv' | tail -n 1 | awk -F'\t' '{print $1, $2, $3}')
if [ -n "$F_primer" ]; then
    bash $script_path'auto_amplicon_script.sh' -p $father_path -d $dataset_name -s $script_path -f $F_primer -r $R_primer > $father_path$dataset_name'_output.log'
else
    continue
fi

F_primer=""
R_primer=""
dataset_name=""
read -r dataset_name F_primer R_primer < <(head -n 3 $father_path'primer.tsv' | tail -n 1 | awk -F'\t' '{print $1, $2, $3}')
if [ -n "$F_primer" ]; then
    bash $script_path'auto_amplicon_script.sh' -p $father_path -d $dataset_name -s $script_path -f $F_primer -r $R_primer > $father_path$dataset_name'_output.log'
else
    continue
fi

F_primer=""
R_primer=""
dataset_name=""
read -r dataset_name F_primer R_primer < <(head -n 4 $father_path'primer.tsv' | tail -n 1 | awk -F'\t' '{print $1, $2, $3}')
if [ -n "$F_primer" ]; then
    bash $script_path'auto_amplicon_script.sh' -p $father_path -d $dataset_name -s $script_path -f $F_primer -r $R_primer > $father_path$dataset_name'_output.log'
else
    continue
fi

F_primer=""
R_primer=""
dataset_name=""
read -r dataset_name F_primer R_primer < <(head -n 5 $father_path'primer.tsv' | tail -n 1 | awk -F'\t' '{print $1, $2, $3}')
if [ -n "$F_primer" ]; then
    bash $script_path'auto_amplicon_script.sh' -p $father_path -d $dataset_name -s $script_path -f $F_primer -r $R_primer > $father_path$dataset_name'_output.log'
else
    continue
fi

F_primer=""
R_primer=""
dataset_name=""
read -r dataset_name F_primer R_primer < <(head -n 6 $father_path'primer.tsv' | tail -n 1 | awk -F'\t' '{print $1, $2, $3}')
if [ -n "$F_primer" ]; then
    bash $script_path'auto_amplicon_script.sh' -p $father_path -d $dataset_name -s $script_path -f $F_primer -r $R_primer > $father_path$dataset_name'_output.log'
else
    continue
fi

F_primer=""
R_primer=""
dataset_name=""
read -r dataset_name F_primer R_primer < <(head -n 7 $father_path'primer.tsv' | tail -n 1 | awk -F'\t' '{print $1, $2, $3}')
if [ -n "$F_primer" ]; then
    bash $script_path'auto_amplicon_script.sh' -p $father_path -d $dataset_name -s $script_path -f $F_primer -r $R_primer > $father_path$dataset_name'_output.log'
else
    continue
fi

F_primer=""
R_primer=""
dataset_name=""
read -r dataset_name F_primer R_primer < <(head -n 9 $father_path'primer.tsv' | tail -n 1 | awk -F'\t' '{print $1, $2, $3}')
if [ -n "$F_primer" ]; then
    bash $script_path'auto_amplicon_script.sh' -p $father_path -d $dataset_name -s $script_path -f $F_primer -r $R_primer > $father_path$dataset_name'_output.log'
else
    continue
fi

F_primer=""
R_primer=""
dataset_name=""
read -r dataset_name F_primer R_primer < <(head -n 10 $father_path'primer.tsv' | tail -n 1 | awk -F'\t' '{print $1, $2, $3}')
if [ -n "$F_primer" ]; then
    bash $script_path'auto_amplicon_script.sh' -p $father_path -d $dataset_name -s $script_path -f $F_primer -r $R_primer > $father_path$dataset_name'_output.log'
else
    continue
fi

F_primer=""
R_primer=""
dataset_name=""
read -r dataset_name F_primer R_primer < <(head -n 11 $father_path'primer.tsv' | tail -n 1 | awk -F'\t' '{print $1, $2, $3}')
if [ -n "$F_primer" ]; then
    bash $script_path'auto_amplicon_script.sh' -p $father_path -d $dataset_name -s $script_path -f $F_primer -r $R_primer > $father_path$dataset_name'_output.log'
else
    continue
fi

F_primer=""
R_primer=""
dataset_name=""
read -r dataset_name F_primer R_primer < <(head -n 12 $father_path'primer.tsv' | tail -n 1 | awk -F'\t' '{print $1, $2, $3}')
if [ -n "$F_primer" ]; then
    bash $script_path'auto_amplicon_script.sh' -p $father_path -d $dataset_name -s $script_path -f $F_primer -r $R_primer > $father_path$dataset_name'_output.log'
else
    continue
fi

F_primer=""
R_primer=""
dataset_name=""
read -r dataset_name F_primer R_primer < <(head -n 13 $father_path'primer.tsv' | tail -n 1 | awk -F'\t' '{print $1, $2, $3}')
if [ -n "$F_primer" ]; then
    bash $script_path'auto_amplicon_script.sh' -p $father_path -d $dataset_name -s $script_path -f $F_primer -r $R_primer > $father_path$dataset_name'_output.log'
else
    continue
fi

F_primer=""
R_primer=""
dataset_name=""
read -r dataset_name F_primer R_primer < <(head -n 14 $father_path'primer.tsv' | tail -n 1 | awk -F'\t' '{print $1, $2, $3}')
if [ -n "$F_primer" ]; then
    bash $script_path'auto_amplicon_script.sh' -p $father_path -d $dataset_name -s $script_path -f $F_primer -r $R_primer > $father_path$dataset_name'_output.log'
else
    continue
fi

F_primer=""
R_primer=""
dataset_name=""
read -r dataset_name F_primer R_primer < <(head -n 15 $father_path'primer.tsv' | tail -n 1 | awk -F'\t' '{print $1, $2, $3}')
if [ -n "$F_primer" ]; then
    bash $script_path'auto_amplicon_script.sh' -p $father_path -d $dataset_name -s $script_path -f $F_primer -r $R_primer > $father_path$dataset_name'_output.log'
else
    continue
fi

F_primer=""
R_primer=""
dataset_name=""
read -r dataset_name F_primer R_primer < <(head -n 16 $father_path'primer.tsv' | tail -n 1 | awk -F'\t' '{print $1, $2, $3}')
if [ -n "$F_primer" ]; then
    bash $script_path'auto_amplicon_script.sh' -p $father_path -d $dataset_name -s $script_path -f $F_primer -r $R_primer > $father_path$dataset_name'_output.log'
else
    continue
fi

F_primer=""
R_primer=""
dataset_name=""
read -r dataset_name F_primer R_primer < <(head -n 17 $father_path'primer.tsv' | tail -n 1 | awk -F'\t' '{print $1, $2, $3}')
if [ -n "$F_primer" ]; then
    bash $script_path'auto_amplicon_script.sh' -p $father_path -d $dataset_name -s $script_path -f $F_primer -r $R_primer > $father_path$dataset_name'_output.log'
else
    continue
fi

F_primer=""
R_primer=""
dataset_name=""
read -r dataset_name F_primer R_primer < <(head -n 18 $father_path'primer.tsv' | tail -n 1 | awk -F'\t' '{print $1, $2, $3}')
if [ -n "$F_primer" ]; then
    bash $script_path'auto_amplicon_script.sh' -p $father_path -d $dataset_name -s $script_path -f $F_primer -r $R_primer > $father_path$dataset_name'_output.log'
else
    continue
fi

F_primer=""
R_primer=""
dataset_name=""
read -r dataset_name F_primer R_primer < <(head -n 19 $father_path'primer.tsv' | tail -n 1 | awk -F'\t' '{print $1, $2, $3}')
if [ -n "$F_primer" ]; then
    bash $script_path'auto_amplicon_script.sh' -p $father_path -d $dataset_name -s $script_path -f $F_primer -r $R_primer > $father_path$dataset_name'_output.log'
else
    continue
fi

F_primer=""
R_primer=""
dataset_name=""
read -r dataset_name F_primer R_primer < <(head -n 20 $father_path'primer.tsv' | tail -n 1 | awk -F'\t' '{print $1, $2, $3}')
if [ -n "$F_primer" ]; then
    bash $script_path'auto_amplicon_script.sh' -p $father_path -d $dataset_name -s $script_path -f $F_primer -r $R_primer > $father_path$dataset_name'_output.log'
else
    continue
fi

F_primer=""
R_primer=""
dataset_name=""
read -r dataset_name F_primer R_primer < <(head -n 21 $father_path'primer.tsv' | tail -n 1 | awk -F'\t' '{print $1, $2, $3}')
if [ -n "$F_primer" ]; then
    bash $script_path'auto_amplicon_script.sh' -p $father_path -d $dataset_name -s $script_path -f $F_primer -r $R_primer > $father_path$dataset_name'_output.log'
else
    continue
fi


