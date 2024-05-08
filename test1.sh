#!/bin/bash
#SBATCH --job-name=PipelineTest
#SBATCH --account=project_2009135
#SBATCH --time=5:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --partition=small
#SBATCH --gres=nvme:100

path="/scratch/project_2009135/linyang/test/pipeline_test/"
acc="SRR_Acc_List.txt"
script_path="/users/linyangs/M_Ms/script_all/"
db_path="/users/linyangs/Database/"
dataset_name_16s="Apis mellifera_GCF_003254395.2_Amel_HAv3.1_genomic.fna"

cd $path
chmod -R +x /users/linyangs/M_Ms/*

module load sratoolkit/3.0.0
module load bowtie2/2.5.3
module load samtools/1.18
source ~/.zshrc

srun $script_path'build_index.sh' -p $path -d $db_path -n $dataset_name_16s
