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
dbpath="/scratch/project_2009135/linyang/database/"

cd $path
source ~/.zshrc
THREADS=24
KMER_LEN=35
READ_LEN=151



mkdir -p "/scratch/project_2009135/linyang/database/"
#srun kraken2-build --download-taxonomy --db "/scratch/project_2009135/linyang/database/"
#srun kraken2-build --download-library bacteria  --threads ${THREADS} --db $dbpath
#srun kraken2-build --download-library fungi  --threads ${THREADS} --db $dbpath
#srun kraken2-build --download-library viral  --threads ${THREADS} --db $dbpath
#srun kraken2-build --download-library archaea  --threads ${THREADS} --db $dbpath
srun bracken-build -d ${KRAKEN_DB} -t ${THREADS} -k ${KMER_LEN} -l ${READ_LEN}