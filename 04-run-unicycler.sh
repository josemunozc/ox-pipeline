#!/bin/bash
#SBATCH --job-name=unicycler
#SBATCH -o o.%x.%A.%a
#SBATCH -e e.%x.%A.%a
#SBATCH --ntasks=8
#SBATCH --ntasks-per-node=8
#SBATCH --partition=short
#SBATCH --clusters=arc
#SBATCH --array=01-05
#SBATCH --time=0-04:00:00

set -eu

module purge
module load Anaconda3/2022.05
module list

source activate /data/zool-ohb/conda-venvs/unicycler

number=`printf "%02d" ${SLURM_ARRAY_TASK_ID}`
#input_dir=/data/zool-ohb/jmunoz/guppy/demultiplexing/output.3471727/barcode$number

output_dir=/data/zool-ohb/jmunoz/unicycler/output.$SLURM_ARRAY_JOB_ID/barcode$number
mkdir -p $output_dir
cd $output_dir

cp ${SLURM_SUBMIT_DIR}/data.csv $output_dir

short_reads_1=`head -n ${SLURM_ARRAY_TASK_ID} data.csv | tail -n 1 | cut -d, -f 1`
short_reads_2=`head -n ${SLURM_ARRAY_TASK_ID} data.csv | tail -n 1 | cut -d, -f 2`
long_reads_dir=`head -n ${SLURM_ARRAY_TASK_ID} data.csv | tail -n 1 | cut -d, -f 3`

# long reads
# merge fastq files from same barcode
# in a single fastq file
long_reads=long_reads_b${number}.fastq
cat ${long_reads_dir}/*.fastq > $long_reads

#Hybrid assembly:
unicycler -1 ${short_reads_1} -2 ${short_reads_2} -l ${long_reads} -o $output_dir -t ${SLURM_NTASKS}
