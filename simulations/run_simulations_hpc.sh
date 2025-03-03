#!/bin/bash
#SBATCH --array=1-4%4
#SBATCH --job-name=simulations
#SBATCH --partition=wrobel
#SBATCH --output=run_simulations.out
#SBATCH --error=run_simulations.err

module purge
module load R

# Rscript to run an r script
# This stores which job is running (1, 2, 3, etc)
JOBID=$SLURM_ARRAY_TASK_ID
Rscript run_simulations_hpc.R $JOBID


