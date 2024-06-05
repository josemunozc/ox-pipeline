#!/bin/bash
#SBATCH -J pod5-view-subset  # Job name
#SBATCH -o o.%x.%j           # Job output file
#SBATCH -e e.%x.%j           # Job error file
#SBATCH --ntasks=24          # number of parallel processes (tasks)
#SBATCH --ntasks-per-node=24 # number of tasks per node
#SBATCH -p medium            # selected queue
#SBATCH --time=48:00:00      # time limit
#SBATCH --clusters=arc
#SBATCH --exclude=arc-c168
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=refath.farzana@biology.ox.ac.uk

# Enables debugging options
set -eu

# Set directory to use
INPUTDIR=/data/biol-covid19-dri/zool2552/burn1_raw
OUTPATH=/data/biol-covid19-dri/zool2552/burn1_output/pod5_subset.${SLURM_JOB_ID}
mkdir -p $OUTPATH
cd $OUTPATH

env

##########
#  Pod5  #
##########

echo Starting Pod5

module purge
module load Python/3.7.4-GCCcore-8.3.0
module list

source /data/biol-covid19-dri/pip-envs/venv-pod5/bin/activate

# run pod5 view to generate a table containing information
# to split on specifically, the "channel" information.
echo Running pod5 view
time pod5 view $INPUTDIR/*.pod5 --include "read_id, channel" --output summary.tsv

# run pod5 subset to copy records from your source data into
# outputs per-channel. This might take some time depending on
# the size of your dataset
echo Running pod5 subset
time pod5 subset $INPUTDIR --threads ${SLURM_NTASKS} --summary summary.tsv --columns channel --output split_by_channel

chmod -R g+rw $OUTPATH

