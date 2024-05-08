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

cd $path
source ~/.zshrc

module load sratoolkit/3.0.0

mkdir -p "/scratch/project_2009135/linyang/database/"

srun wget https://genome-idx.s3.amazonaws.com/kraken/uniq/krakendb-2023-08-08-MICROBIAL/kuniq_microbialdb_minus_kdb.20230808.tgz -P "/scratch/project_2009135/linyang/database/"