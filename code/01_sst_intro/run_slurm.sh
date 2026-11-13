#!/bin/bash
#SBATCH --job-name=sst_intro
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --time=00:10:00
#SBATCH --output=sst_intro_%j.out

# TODO: replace with the way SST is provided on the cluster (module / container).
# module load SST
sst hello_sst.py
