#!/bin/bash
##################################################
#            user setting

#            environment setting
source /home/data/t230307/miniconda3/etc/profile.d/conda.sh
echo "activate environment"
conda activate qiime2_amplicon

source /home/data/t230307/M_Ms/script_all/amplicon.sh



#             parameter setting
script_path="/home/data/t230307/M_Ms/script_all/"
metafile="/home/data/t230307/test/test1.csv"
##################################################



father_path=$(dirname "$metafile")
meta_file_basename=$(basename "$metafile")

if [[ ! "$father_path" =~ /$ ]]; then
    father_path="$father_path/"
fi
# At here, set column name to each variable
python $script_path"make_clean_meta1.py" $metafile "Datasets_ID" "Bioproject" "SRA_Number" "Biosample"

echo $father_path"datasets_ID.txt"
while IFS= read -r line; do
    dataset_ID=$(echo "$line" | cut -f1)
    dataset_path=$father_path$dataset_ID"/"
    sra_file_name=$dataset_ID"_sra.txt"
    cd $dataset_path
    echo $dir_path
    dl_sra_to_fq -d $dataset_path -s $script_path -a $sra_file_name -e 0.1 -c 12
    cd $path
done < $father_path"datasets_ID.txt"