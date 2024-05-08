#!/bin/bash


path="/home/data/t230307/test1/"
acc="SRR_Acc_List.txt"
script_path="/home/data/t230307/M_Ms/"
db_path="/home/data/t230307/Database/"
dataset_name_16s="Apis mellifera_GCF_003254395.2_Amel_HAv3.1_genomic.fna"

cd $path
chmod -R +x /home/data/t230307/M_Ms/*

source /home/data/t230307/miniconda3/etc/profile.d/conda.sh
conda activate mg

echo "step1"
bash $script_path'dl_sra_to_fq.sh' -p $path -a $acc
echo "step1 finished"

echo "step2"
bash $script_path'fastq_to_fastp.sh' -p $path
echo "step2 finished"



bash $script_path'build_index.sh' -p $path -d $db_path -n $dataset_name_16s
