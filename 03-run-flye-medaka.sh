#!/bin/bash
#SBATCH --job-name=flye-medaka
#SBATCH -o o.%x.%A.%a
#SBATCH -e e.%x.%A.%a
#SBATCH --ntasks=16
#SBATCH --mem=64G
#SBATCH --partition=short
#SBATCH --clusters=arc
#SBATCH --array=01-96
#SBATCH --time=0-12:00:00
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=refath.farzana@biology.ox.ac.uk

set -eu

module purge
module load Anaconda3/2022.05
module list

source activate /data/biol-covid19-dri/conda-venvs/nanopore

number=`printf "%02d" ${SLURM_ARRAY_TASK_ID}`
input_dir=/data/biol-covid19-dri/zool2552/burn1_output/dorado_demux_4171426

output_dir=/data/biol-covid19-dri/zool2552/burn1_output/flye-output-${SLURM_ARRAY_JOB_ID}/barcode$number
mkdir -p $output_dir
cd $output_dir

flye \
    -t $SLURM_NTASKS \
    --nano-raw $input_dir/SQK-RBK114-96_barcode${number}.fastq \
    -g 5m \
    -o $output_dir

chmod -R g+rw $output_dir

########################
#   MEDAKA CONSENSUS   #
########################

fasta_input_assembly=$output_dir/assembly.fasta
output_dir=/data/biol-covid19-dri/zool2552/burn1_output/medaka-output-${SLURM_ARRAY_JOB_ID}/barcode$number
mkdir -p $output_dir
cd $output_dir

#    -d  fasta input assembly (required).
#    -i  fastx input basecalls (required).
#    -o  output folder (default: medaka).
#    -t  number of threads with which to create features (default: 1).
#    -m  medaka model, (default: r941_min_hac_g507).
medaka_consensus \
    -d $fasta_input_assembly \
    -i $input_dir/SQK-RBK114-96_barcode${number}.fastq \
    -o $output_dir \
    -t $SLURM_NTASKS \
    -m r1041_e82_400bps_sup_g615

consensus="consensus.fasta"
if [[ -f $consensus ]]; then
    mv $consensus barcode${number}.$consensus
else
    echo ERROR: Missing file $consensus
    exit 1
fi

chmod -R g+rw $output_dir

