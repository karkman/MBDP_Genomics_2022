#!/bin/bash

# Programs used:
# FastQC
# Cutadapt
# Prinseq
# Spades


# Activate biokit module
module load biokit

# Create FastQC output dir
mkdir fastqc_out_raw

# Run FastQC with the raw data
fastqc /scratch/project_2005590/raw_data_cyanos/* -o fastqc_out_raw



# Running Cutadapt for adapter-trimming

# Illumina forward and reverse Raw sequences for the cyanobacteria strain 327
R1=/scratch/project_2005590/raw_data_cyanos/A044-327-2-CTTGCCTC-GTTATCTC-Tania-Shishido-run20211223R_S44_L001_R1_001.fastq.gz
R2=/scratch/project_2005590/raw_data_cyanos/A044-327-2-CTTGCCTC-GTTATCTC-Tania-Shishido-run20211223R_S44_L001_R2_001.fastq.gz

# Create output dir for trimmed reads
mkdir trimmed_seqs

# Create a variable with the cyanobacteria strain label
strain=327

# Run program with Nextera Transposase Sequences adapters
cutadapt -a CTGTCTCTTATA -A CTGTCTCTTATA -o trimmed_seqs/"$strain"_cut_1.fastq -p trimmed_seqs/"$strain"_cut_2.fastq $R1 $R2 --minimum-length 80

# Check the quality of Cutadapt outputs with FastQC
fastqc trimmed_seqs/"$strain"_cut_1.fastq -o fastqc_out_trimmed
fastqc trimmed_seqs/"$strain"_cut_2.fastq -o fastqc_out_trimmed


# Repeat the cutadapt and FastQC commands with the other strains
# Strain 328 Illumina raw sequences:
# /scratch/project_2005590/raw_data_cyanos/A045-328-GGTCCATT-AGTAGGCT-Tania-Shishido-run20211223R_S45_L001_R1_001.fastq.gz
# /scratch/project_2005590/raw_data_cyanos/A045-328-GGTCCATT-AGTAGGCT-Tania-Shishido-run20211223R_S45_L001_R2_001.fastq.gz



# Run Prinseq for quality control using the Cutadapt outputs

# Create a variable with the cyanobacteria strain label
strain=327

# Run program using the previous trimmed reads
prinseq-lite.pl \
-fastq trimmed_seqs/"$strain"_cut_1.fastq \
-fastq2 trimmed_seqs/"$strain"_cut_2.fastq \
-min_qual_mean 25 \
-trim_left 10 \
-trim_right 8 \
-trim_qual_right 36 \
-trim_qual_left 30 \
-min_len 80 \
-out_good trimmed_seqs/"$strain"_pseq

# Check the quality of Prinseq outputs with FastQC
fastqc trimmed_seqs/"$strain"_pseq_1.fastq -o fastqc_out_trimmed
fastqc trimmed_seqs/"$strain"_pseq_2.fastq -o fastqc_out_trimmed

# Repeat the Prinseq and FastQC commands with the other strains



# Genome assembly with Spades

# Create a variable with the cyanobacteria strain label
strain=327

# Create the "forward" and "reverse" variables with the reads processed by Prinseq
R1=trimmed_seqs/"$strain"_pseq_1.fastq
R2=trimmed_seqs/"$strain"_pseq_2.fastq

# Run Spades
spades.py --only-assembler -1 $R1 -2 $R2 -o spades_"$strain" -t 16

# Repeat the spades command with the other strains







