#!/bin/bash

#SBATCH --job-name=kaiju
#SBATCH --output=output_%j.txt
#SBATCH --error=errors_%j.txt
#SBATCH --time=06:00:00
#SBATCH --partition=small
#SBATCH --ntasks=1
#SBATCH --nodes=1  
#SBATCH --cpus-per-task=4
#SBATCH --account=project_2005590
#SBATCH --mem=40000


# Kaiju database files
names=/scratch/project_2005590/databases/kaiju_database/names.dmp
nodes=/scratch/project_2005590/databases/kaiju_database/nodes.dmp
db=/scratch/project_2005590/databases/kaiju_database/kaiju_db.fmi

# Cyano strain label and the Kaiju input path variable
input=spades_327/scaffolds.fasta
strain=327

# Run Kaiju
kaiju -t $nodes -f $db -i $input -o strain_"$strain".kaiju.txt -z $SLURM_CPUS_PER_TASK

# Add taxon names (phylum level) to the first Kaiju output table (uses the previous output as input)
kaiju-addTaxonNames -t $nodes -n $names -r phylum -i strain_"$strain".kaiju.txt -o strain_"$strain".kaiju.taxons.txt


# Format the spades output using fastx-toolkit
# Activate the fastx-toolkit module
module load fastx-toolkit

fasta_formatter -i $input -o fmt.spades_$strain".fasta"

# Use the Kaiju output table to select only the contigs classified as Cyanobacteria
for i in $(grep "Cyanobacteria" strain_"$strain".kaiju.taxons.txt | cut -f2); do
grep -A1 -w "$i" fmt.spades_$strain".fasta" >> cyano."$strain".fasta
done


