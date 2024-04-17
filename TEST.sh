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




echo "step2"
srun $script_path'fastq_to_fastp_B.sh' -p $path
echo "step2 finished"

echo "step2"
srun $script_path'fastq_to_fastp_C.sh' -p $path
echo "step2 finished"
echo "step2"
srun $script_path'fastq_to_fastp_D.sh' -p $path
echo "step2 finished"

echo "step2"
srun $script_path'fastq_to_fastp_E.sh' -p $path
echo "step2 finished"
echo "step2"
srun $script_path'fastq_to_fastp.sh_A' -p $path
echo "step2 finished"