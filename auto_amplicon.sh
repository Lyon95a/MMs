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
metafile="/home/data/t230307/test/test.csv"
v4_ref_path="/home/data/t230307/db/16s/2022.10.taxonomy.asv.nwk.qza"
No_v4_db_path="/home/data/t230307/db/16s/2022.10.backbone.full-length.fna.qza"
##################################################



father_path=$(dirname "$metafile")
meta_file_basename=$(basename "$metafile")

if [[ ! "$father_path" =~ /$ ]]; then
    father_path="$father_path/"
fi
# At here, set column name to each variable
python $script_path"make_clean_meta1.py" $metafile "Datasets_ID" "Bioproject" "SRA_Number" "Biosample" "region"

echo "####################################################################################"
echo "Downloading SRA file"
echo "####################################################################################"
#cat "${father_path}datasets_ID.txt" | while IFS= read -r line; do
#    echo "Processing line: $line"
#    dataset_ID=$(echo "$line" | cut -f1)
#    dataset_path="${father_path}${dataset_ID}/"
#    sra_file_name="${dataset_ID}_sra.txt"
#    echo "Dataset path: $dataset_path"
#    echo "SRA file name: $sra_file_name"
#    cd "$dataset_path"
#    echo "${dataset_ID} downloading...."
#    dl_sra_to_fq -d "$dataset_path" -s "$script_path" -a "$sra_file_name"
#    echo "${dataset_ID} complete...."
#done


echo "####################################################################################"
echo "Qiime2 processing"
echo "####################################################################################"
cat "${father_path}datasets_ID.txt" | while IFS= read -r line; do
    echo "Processing line: $line"
    dataset_ID=$(echo "$line" | cut -f1)
    dataset_path="${father_path}${dataset_ID}/"
    sra_file_name="${dataset_ID}_sra.txt"
    echo "Dataset path: $dataset_path"
    echo "SRA file name: $sra_file_name"
    cd "$dataset_path"
    echo "$dir_path"
    fastq_to_fastp -d "$dataset_path" -s "$script_path"
    make_manifest -d "$dataset_path" -s "$script_path" -n "$dataset_ID"
    import_to_qiime2 -d "$dataset_path" -n "$dataset_ID" 
    q2_cutadapt -d "$dataset_path" -e 0.1 -c 12 -n "$dataset_ID" 
    quality_control -d "$dataset_path" -n "$dataset_ID" 
    deblur_denoise -d "$dataset_path" -n "$dataset_ID" -c 12
    #dada_denoise -d "$dataset_path" -n "$dataset_ID" -c 12
    #tax_g2 -d "$dataset_path" -a "$sra_file_name" -n "$dataset_ID" -y $v4_ref_path -z $No_v4_db_path
    echo "done"
done


echo "all process finished"

