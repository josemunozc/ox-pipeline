#!/bin/bash
#SBATCH --job-name=longqc
#SBATCH -o o.%x.%A.%a
#SBATCH -e e.%x.%A.%a
#SBATCH --nodes 1
#SBATCH --ntasks-per-node=8
#SBATCH --partition=short
#SBATCH --clusters=arc
#SBATCH --time=0-02:00:00
#SBATCH --array=1-96
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=refath.farzana@biology.ox.ac.uk

set -eu

barcode_number=`printf "%02d\n" ${SLURM_ARRAY_TASK_ID}`
echo Array job $SLURM_ARRAY_TASK_ID working on barcode${barcode_number}

input_dir=/data/biol-covid19-dri/zool2552/burn1_output/dorado_demux_4171426
output_dir=/data/biol-covid19-dri/zool2552/burn1_output/longQC-${SLURM_ARRAY_JOB_ID}/barcode${barcode_number}
rm -rf $output_dir
mkdir -p $output_dir

###########
# LongQC  #
###########

echo Starting LongQC

module purge
module load Anaconda3/2022.10
module list

conda activate /data/zool-ohb/conda-venvs/longqc-dev

# You need to clone LongQC to access the Python scripts
# git clone https://github.com/yfukasawa/LongQC.git
# maybe adding to PATH migth work?

cd /data/zool-ohb/jmunoz/LongQC

python longQC.py sampleqc \
	-x ont-rapid \
	-p ${SLURM_NTASKS} \
	-o $output_dir/out \
	$input_dir/SQK-RBK114-96_barcode${barcode_number}.fastq

#longqc sampleqc \
#-x pb-sequel \ **specify a preset and change accordingly.**
#-p $(nproc) \ **number of process/cores, this uses all of your cores. change accordingly.**
#-o /output/YOUR_SAMPLE_NAME \ **keep /output as this is binded.**
#/input/YOUR_INPUT_READ_FILE **keep /input as this is binded.**

