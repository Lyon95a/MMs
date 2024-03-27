#!/bin/bash

while getopts ":p:d:s:f:r:" opt
do
    case $opt in
        p)
        father_path=$OPTARG
        ;;
        d)
        dataset_name=$OPTARG
        ;;
        s)
        script_path=$OPTARG
        ;;
        f)
        F_primer=$OPTARG
        ;;
        r)
        R_primer=$OPTARG
        ;;
        ?)
        echo "未知参数"
        exit 1;;
    esac
done

if [[ ! "$father_path" =~ /$ ]]; then
    father_path="$father_path/"
fi

path=$father_path$dataset_name"/"
acc=$dataset_name"_sra.txt"





mismatch=3
#script_path="/home/data/t230307/mms_scripts/"
#amplicon_size=350
#region="v4" # two option v4 or non-v4-16s
# No_v4_db_path="/home/data/t230307/db/16s/2022.10.backbone.full-length.fna.qza"
# v4_db_path="/home/data/t230307/db/16s/2022.10.taxonomy.asv.nwk.qza"
#module load qiime2/2023.9-amplicon
#module load sratoolkit/3.0.0
#module load seqkit/2.5.1
#module load cutadapt/4.6
# config env 
# needed package are: qiime2, seqkit, figaro, cutadapter
# install them first and import it  
source /home/data/t230307/miniconda3/etc/profile.d/conda.sh
conda activate qiime2_amplicon
echo "test"
