#!/bin/bash
#SBATCH -J dorado.basecaller # Job name
#SBATCH -o o.%x.%j           # Job output file
#SBATCH -e e.%x.%j           # Job error file
#SBATCH --ntasks=32          # number of parallel processes (tasks)
#SBATCH --ntasks-per-node=32 # number of tasks per node
#SBATCH -p test              # selected queue
#SBATCH --gres=gpu:2         # number of gpus per node
#SBATCH --time=48:00:00      # time limit
#SBATCH --clusters=htc
#SBATCH -w htc-g019
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=refath.farzana@biology.ox.ac.uk

# Enables debugging options
set -eu

#Add dorado binary to PATH
export PATH=/data/biol-covid19-dri/bin/dorado-0.4.1-linux-x64/bin:$PATH

# We assume that previus pod5 results are within this directory as well
BASEDIR=/data/biol-covid19-dri/zool2552/burn1_output

# Set directory to use
INPUTDIR=$BASEDIR/pod5_subset.7531172/split_by_channel

# Make working directory & Change to working directory
OUTDIR=$BASEDIR/dorado_basecalling_$SLURM_JOB_ID
mkdir -p $OUTDIR
cd $OUTDIR

#########################
# Run Dorado basecalling
#########################
batchsize=1024
echo Running dorado with batchsize $batchsize

model="dna_r10.4.1_e8.2_400bps_sup@v4.2.0"
dorado download --model $model
dorado basecaller \
	--emit-fastq \
	--batchsize $batchsize \
	-x "cuda:auto" \
	-v \
	$model \
	$INPUTDIR > calls.fastq

chmod -R g+rw $OUTDIR

############################
# Run Dorado demultiplexing
############################

# Set directory to use
INPUTDIR=$OUTDIR

## Make working directory & Change to working directory
OUTDIR=$BASEDIR/dorado_demux_$SLURM_JOB_ID
mkdir -p $OUTDIR
cd $OUTDIR

# Run Dorado barcoder (demultiplexing)
dorado demux \
    --kit-name SQK-RBK114-96 \
    --output-dir ${OUTDIR} \
    --emit-fastq \
    ${INPUTDIR}/calls.fastq

chmod -R g+rw $OUTDIR
