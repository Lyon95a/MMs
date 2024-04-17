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

set -x

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

########################################################################################################
#download sra data-->unzip to fq formate
echo "step1"
bash $script_path'dl_sra_to_fq.sh' -p $path -a $acc
echo "step1 finished"

#make manifest file 
echo "step2"
bash $script_path'make_manifest.sh' -p $path -s $script_path
echo "step2 finished"


conda deactivate
echo "sleep for 2 min"
sleep 3m
conda activate qiime2_amplicon

#detect primer is cleaned or not 
echo "step3"
bash $script_path'primer_detection.sh' -p $path -m $mismatch -f $F_primer
echo "step3 finished"

# import to qiime2
echo "step4"
bash $script_path'import_to_qiime.sh' -p $path
echo "step4 finished"


# cut primer
echo "step5"
bash $script_path'cut_primer.sh' -p $path -f $F_primer -r $R_primer -c 8 -e 0.1
echo "step5 finished"

#get trim position for both side of reads
echo "step6"
bash $script_path'Trim_pos_decied.sh' -p $path -s $script_path
echo "step6 finished"

#denoise
echo "step7"
bash $script_path'denoise.sh' -p $path -d $dataset_name -c 8
echo "step7 finished"

exit