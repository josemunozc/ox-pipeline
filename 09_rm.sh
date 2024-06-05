#!/bin/bash
#SBATCH -J rm                # Job name
#SBATCH -o o.%x.%j           # Job output file
#SBATCH -e e.%x.%j           # Job error file
#SBATCH --ntasks=48          # number of parallel processes (tasks)
#SBATCH --ntasks-per-node=48 # number of tasks per node
#SBATCH -p short             # selected queue
#SBATCH --time=12:00:00      # time limit
#SBATCH --clusters=arc

rm /data/biol-covid19-dri/zool2552/burn3_raw/*.pod5 

