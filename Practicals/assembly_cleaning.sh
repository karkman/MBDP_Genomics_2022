#!/bin/bash


# Kaiju is not pre-installed on Puhti

export PROJAPPL=/projappl/project_2005590
module purge
module load bioconda/3

# Activate virtual environment with kaiju installed
source activate csc_course


# Modify the script kaiju.sh before running it

# Run kaiju batch script
sbatch kaiju.sh


