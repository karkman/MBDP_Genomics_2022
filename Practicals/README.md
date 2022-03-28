# Practicals

__Table of Contents:__
1. [Setting up](#setting-up-the-course-folders)
2. [Interactive use of Puhti](#interactive-use-of-puhti)
3. [QC and trimming for Illumina reads](#qc-and-trimming-for-illumina-reads)
4. [QC and trimming for Nanopore reads](#qc-and-trimming-for-nanopore-reads)
5. [Genome assembly with Spades](#genome-assembly-with-spades)
6. [Eliminate contaminant contigs with Kaiju](#eliminate-contaminant-contigs-with-kaiju)
7. [Assembly QC](#assembly-qc)
8. [Calculate the genome coverage](#calculate-the-genome-coverage)
9. [Genome completeness and contamination](#genome-completeness-and-contamination)
10. [Name the strain](#name-the-strain)
11. [Pangenomics](#pangenomics-with-anvio)
12. [Detection  of secondary  metabolites biosynthesis gene clusters](#detection-of-secondary-metabolites-biosynthesis-gene-clusters)
13. [Comparison of secondary metabolites biosynthesis gene clusters](#comparison-of-secondary-metabolites-biosynthesis-gene-clusters)



## Setting up the course folders
The main course directory is located in `/scratch/project_2005590`.  
There you will set up your own directory where you wil perform all the tasks for this course.  
So let's create a folder for you:

```bash
cd /scratch/project_2005590
mkdir $USER
```

Check with `ls`; which folder did `mkdir $USER` create?

This directory (`/scratch/project_2005590/your-user-name`) is your working directory.  
Every time you log into Puhti, you should use `cd` to navigate to this directory, and **all the scripts are to be run in this folder**.  

The raw data used on this course can be found in `/scratch/project_2005590/COURSE_FILES/RAWDATA_ILLUMINA`.  
Instead of copying the data we will use links to this folder in all of the needed tasks.  
Why don't we want 14 students copying data to their own folders?

## Interactive use of Puhti

Puhti uses a scheduling system called SLURM. Most jobs are sent to the queue,  but smaller jobs can be run interactively.

Interactive session is launched with `sinteractive`   .   
You can specify the resources you need for you interactive work interactively with `sinteractive -i`. Or you can give them as options to `sinteractive`.  
You always need to specify the accounting project (`-A`, `--account`). Otherwise for small jobs you can use the default resources (see below).

| Option | Function | Default | Max |  
| --     | --       | --      | --  |  
| -i, --interactive | Set resources interactively |  |  |  
| -t,  --time | Reservation in minutes or in format d-hh:mm:ss | 24:00:00 | 7-00:00:00 |
| -m, --mem | Memory in Mb       | 2000     | 76000  |  
| -j, --jobname |Job name       | interactive     |   |  
| -c, --cores     | Number of cores       | 1      | 8  |  
| -A, --account     | Accounting project       |       |  |  
| -d, --tmp     | $TMPDIR size (in GiB)      |  32     | 760  |  
| -g, --gpu     | Number of GPUs       | 0     | 0 |  


[__Read more about interactive use of Puhti.__](https://docs.csc.fi/computing/running/interactive-usage/#sinteractive-in-puhti)   


## QC and trimming for Illumina reads
QC for the raw data takes few minutes, depending on the allocation.  
Go to your working directory and make a folder called e.g. `fastqc_raw` for the QC reports.  

QC does not require lot of memory and can be run on the interactive nodes using `sinteractive`.

Activate the biokit environment and open interactive node:

```bash
sinteractive -A project_2005590
module load biokit
```

Now each group will work with their own sequences. Create the variables R1 and R2 to represent the path to your files. Do that just for the strain you will use:

```bash
#### Illumina Raw sequences for the cyanobacteria strain 328
R1=/scratch/project_2005590/COURSE_FILES/RAWDATA_ILLUMINA/A045-328-GGTCCATT-AGTAGGCT-Tania-Shishido-run20211223R_S45_L001_R1_001.fastq.gz
R2=/scratch/project_2005590/COURSE_FILES/RAWDATA_ILLUMINA/A045-328-GGTCCATT-AGTAGGCT-Tania-Shishido-run20211223R_S45_L001_R2_001.fastq.gz

#### Illumina Raw sequences for the cyanobacteria strain 327
R1=/scratch/project_2005590/COURSE_FILES/RAWDATA_ILLUMINA/A044-327-2-CTTGCCTC-GTTATCTC-Tania-Shishido-run20211223R_S44_L001_R1_001.fastq.gz
R2=/scratch/project_2005590/COURSE_FILES/RAWDATA_ILLUMINA/A044-327-2-CTTGCCTC-GTTATCTC-Tania-Shishido-run20211223R_S44_L001_R2_001.fastq.gz

#### Illumina Raw sequences for the cyanobacteria strain 193
R1=/scratch/project_2005590/COURSE_FILES/RAWDATA_ILLUMINA/Oscillatoria-193_1.fastq.gz
R2=/scratch/project_2005590/COURSE_FILES/RAWDATA_ILLUMINA/Oscillatoria-193_2.fastq.gz
```


You can check if your variable was set correctly by using:

```bash
echo $R1
echo $R2
```




### Running fastQC
Run `fastQC` to the files stored in the RAWDATA folder. What does the `-o` and `-t` flags refer to?

```bash
fastqc $R1 -o fastqc_raw/ -t 1

fastqc $R2 -o fastqc_raw/ -t 1
```



Copy the resulting HTML file to your local machine with `scp` from the command line (Mac/Linux) or *WinSCP* on Windows.  
Have a look at the QC report with your favourite browser.  

After inspecting the output, it should be clear that we need to do some trimming.  
__What kind of trimming do you think should be done?__

### Running Cutadapt


```bash
# To create a variable to your cyanobacterial strain:
strain=328
```

The adapter sequences that you want to trim are located after `-a` and `-A`.  
What is the difference with `-a` and `-A`?  
And what is specified with option `-p` or `-o`?
And how about `-m` and `-j`?  
You can find the answers from Cutadapt [manual](http://cutadapt.readthedocs.io).

Before running the script, we need to create the directory where the trimmed data will be written:

```bash
mkdir trimmed
```


```bash
cutadapt -a CTGTCTCTTATA -A CTGTCTCTTATA -o trimmed/"$strain"_cut_1.fastq -p trimmed/"$strain"_cut_2.fastq $R1 $R2 --minimum-length 80 > cutadapt.log

```


### Running fastQC on the trimmed reads
You could now check the `cutadapt.log` and answer:

* How many read pairs we had originally?
* How many reads contained adapters?
* How many read pairs were removed because they were too short?
* How many base calls were quality-trimmed?
* Overall, what is the percentage of base pairs that were kept?

Then make a new folder (`FASTQC`) for the QC files of the trimmed data and run fastQC and multiQC again as you did before trimming:

```bash
mkdir fastqc_out_trimmed
fastqc trimmed/cd T *.fastq -o fastqc_out_trimmed/ -t 1
```



Copy the resulting HTML file to your local machine as earlier and look how well the trimming went.  
Did you find problems with the sequences? We can further proceed to quality control using Prinseq.


#### Running Prinseq

You could check the different parameters that can be used in prinseq:
http://prinseq.sourceforge.net/manual.html



```bash

module load prinseq

```

Run program using the previous trimmed reads:

```bash
prinseq-lite.pl \
-fastq trimmed/"$strain"_cut_1.fastq \
-fastq2 trimmed/"$strain"_cut_2.fastq \
-min_qual_mean 25 \
-trim_left 10 \
-trim_right 8 \
-trim_qual_right 36 \
-trim_qual_left 30 \
-min_len 80 \
-out_good trimmed/"$strain"_pseq -log prinseq.log
```

You can check the `prinseq.log` and run again FastQC on the Prinseq trimmed sequences and copy them to your computer. You can now compare the quality of these sequences with the raw and cutadapt trimmed sequences FastQC results. Did you find any difference?



```bash
cd trimmed/

fastqc "$strain"_pseq_*.fastq -o ../fastqc_out_trimmed/ -t 1

```


### Optional - To compare raw and trimmed sequences using multiqc


To combine all the reports .zip in a new `combined_fastqc` folder with multiQC:
```bash
mkdir combined_fastqc

cp fastqc_raw/*zip combined_fastqc/
cp fastqc_out_trimmed/*zip combined_fastqc/

```


MultiQC is not pre-installed to Puhti, so we have created a virtual environment that has it.

```bash
export PROJAPPL=/projappl/project_2005590
module purge
module load bioconda/3
source activate mbdp_genomics
cd combined_fastqc/
multiqc . --interactive
```

To leave the interactive node, type `exit`.  

You can copy the file `multiqc_report.html` to your computer and open it in a web browser. Can you see any difference among the raw and trimmed reads?


## QC and trimming for Nanopore reads

The QC for the Nanopore reads can be done with NanoPlot and NanoQC. They are plotting tools for long read sequencing data and alignments. You can read more about them in: [NanoPlot](https://github.com/wdecoster/NanoPlot) and [NanoQC](https://github.com/wdecoster/nanoQC)

NanoPlot and NanoQC are not pre-installed to Puhti so we need to reset the modules and activate the virtual environment. If the environment is already loaded you can skip this step.

```bash
export PROJAPPL=/projappl/project_2005590
module purge
module load bioconda/3
source activate mbdp_genomics
```

The nanopore data you will use can be found in the folder `/scratch/project_2005590/COURSE_FILES/RAWDATA_NANOPORE`

This run will require more computing resources, so you can apply for more memory or run in sbatch:

```bash
sinteractive -A project_2005590 -m 45000
```

Generate graphs for visualization of reads quality and length distribution

```bash
NanoPlot -o nanoplot_out -t 4 -f png --fastq path-to/your_raw_nanopore_reads.fastq.gz
```

Transfer to your computer and check two plots inside the nanoplot output folder:
Reads quality distribution: `LengthvsQualityScatterPlot_kde.png`
Reads length distribution: `Non_weightedLogTransformed_HistogramReadlength.png`

```bash
nanoQC -o nanoQC_out path-to/your_raw_nanopore_reads.fastq.gz
```

Using the Puhti interactive mode, check the file `nanoQC.html` inside the ouput folder of the nanoQC job.

* How is the quality at the beginning and at the end of the reads? How many bases would you cut from these regions?



### Trimming and quality filtering of reads

The following command will trim the first 30 bases and the last 20 bases of each read, exclude reads with a phred score below 12 and exclude reads with less than 1000 bp.

```bash
mkdir trimmed_nanopore

cd trimmed_nanopore

gunzip -c /scratch/project_2005590/COURSE_FILES/RAWDATA_NANOPORE/raw.nanopore.328.fastq.gz | NanoFilt -q 12 -l 1000 --headcrop 30 --tailcrop 20 | gzip > nanopore.trimmed.fastq.gz
```

### Optional - Visualizing the trimmed data
```bash
NanoPlot -o nanoplot_out -t 4 -f png --fastq nanopore.trimmed.fastq.gz
```


## Genome assembly with Spades
Now that you have good trimmed sequences, we can assemble the reads.
For assembling you will need more resources than the default.  
Allocate 8 cpus, 20000 Mb of memory (20G) and 4 hours.  
Remember also the accounting project, `project_2005590`.

```bash

# Remember to modify  this
sinteractive --account --time --mem --cores


# Deactivate the current virtual environment and reset the modules before loading Spades
source deactivate mbdp_genomics
module purge


# Activate program
module load gcc/9.1.0
module load spades/3.15.0


# Cyano strain and processed reads
strain=328
R1=trimmed/"$strain"_pseq_1.fastq
R2=trimmed/"$strain"_pseq_2.fastq

```

### Run Spades

We will use the trimmed Illumina and Nanopore sequences to assemble the cyanobacteria genomes. Check the commands used using `spades.py -h`

```bash
spades.py --isolate --nanopore nanopore.trimmed.fastq.gz -1 $R1 -2 $R2 -o spades_hybrid_out -t 8
```

If you have time, you can try different options for assembly. Read more from [here](https://cab.spbu.ru/files/release3.15.0/manual.html) and experiment.  
Remember to rename the output folder for your different experiments.

After you're done, remember to close the interactive connection and free the resources with `exit`.



## Eliminate contaminant contigs with Kaiju

Kaiju is no pre-installed to Puhti so we need to reset the modules and activate the virtual environment again.

```bash
export PROJAPPL=/projappl/project_2005590
module purge
module load bioconda/3
source activate mbdp_genomics
```

### Run kaiju batch script
To run Kaiju you can use the script in `/scratch/project_2005590/COURSE_FILES/run_kaiju.sh`. This script takes your assembly as input and will eliminate all sequences not classified as cyanobacteria, creating a new "clean" file. You could go through the script and look at https://docs.csc.fi/computing/running/creating-job-scripts-puhti/ and `kaiju -h` before run in your folder:


```bash
sbatch /scratch/project_2005590/COURSE_FILES/run_kaiju.sh -i spades_hybrid_out/scaffolds.fasta -o kaiju_out
```

You can check the status of your job with:  

```bash
squeue -l -u $USER
```

After the job has finished, you can see how much resources it actually used and how many billing units were consumed.

```bash
seff JOBID
```

**NOTE:** Change **JOBID** the the job id number you got when you submitted the script.


## Assembly QC

After the assembly has finished we will use Quality Assessment Tool for Genome Assemblies, [Quast](http://quast.sourceforge.net/) for (comparing and) evaluating our assemblies. Quast can be found from Puhti, but since there might be some incompability issues with Python2 and Python3, we will use a Singularity container that has Quast installed.  
More about Singularity: [More general introduction](https://sylabs.io/guides/3.5/user-guide/introduction.html) and [a bit more CSC specific](https://docs.csc.fi/computing/containers/run-existing/).

```
singularity exec --bind $PWD:$PWD /projappl/project_2005590/containers/quast_5.0.2.sif quast.py -o quast_out kaiju_out_filtered.fasta -t 4
```

## Calculate the genome coverage

To calculate the genome coverage, all the reads used for the assembly must be mapped to the final genome. For that, we can use three programs: Bowtie2 to map the reads; Samtools to sort and make an index of the mapped reads; and bedtools to make the calculation.

The entire workflow can take a long time, so the bedtools output with the sequencing depth for each base in the genome is available for each cyanobacterial strain in `/scratch/project_2005590/COURSE_FILES/RESULTS/coverage_[strain_number]/CoverageTotal.bedgraph`.

You can check the commands used in the workflow to generate this file in the script in: `/scratch/project_2005590/COURSE_FILES/SCRIPTS/genome_coverage_workflow.sh`.


You can visualize the contents of the file `CoverageTotal.bedgraph` using the command `head` to show the first few lines.

The first 10 lines of `CoverageTotal.bedgraph` for the strain 328 as an example:
```bash
NODE_2_length_2022818_cov_20.647969   0   1   19
NODE_2_length_2022818_cov_20.647969   1   2   31
NODE_2_length_2022818_cov_20.647969   2   3   53
NODE_2_length_2022818_cov_20.647969   3   4   57
NODE_2_length_2022818_cov_20.647969   4   6   60
NODE_2_length_2022818_cov_20.647969   6   8   62
NODE_2_length_2022818_cov_20.647969   8   9   69
NODE_2_length_2022818_cov_20.647969   9   11  73
NODE_2_length_2022818_cov_20.647969   11  12  74
NODE_2_length_2022818_cov_20.647969   12  13  76
```
The first column refers to the contig name, the second and third column refers to the base position, and the fourth column is the sequencing depth of the base.

In order to calculate the final genome coverage we must calculate the average sequencing depth of all the bases in the genome. We can achieve this by using `awk`.

This command will sum all the numbers in the fourth column of the file `CoverageTotal.bedgraph` and divide by the total numbers of lines (number of bases), giving the average number. The final result will be printed in your screen.

```bash
cat CoverageTotal.bedgraph | awk '{total+=$4} END {print total/NR}'
```

## Genome completeness and contamination

Now we have calculated different metrics for our genomes, but they don't really tell anything about the "real" quality of our genome.  
We will use checkM to calculate the completeness and possible contamination in our genomes.  
Allocate some resources (>40G memory & 4 threads) and run checkM (v. 1.1.3.) from a singularity container.  

Before running checkM, it might be good to put all genomes to one folder.

```
singularity exec --bind $PWD:$PWD,$TMPDIR:/tmp /projappl/project_2005590/containers/checkM_1.1.3.sif \
              checkm lineage_wf -x fasta PATH/TO/GENOME/FOLDER OUTPUT/FOLDER -t 4 --tmpdir /tmp
```

## Name the strain

After we know the completeness and the amount of possible contamination in our assembly, next thing is to give a name to our strain. In other words, what species did we sequence.  
We will use a tool called GTDB-tk to give some taxonomy to our genomes.

This will use a lot of memory (> 200G), so allocate a new computing node for this.

```
#############  (THIS HAS BEEN DONE ALREADY)  #########################
## download gtdb database
# wget https://data.ace.uq.edu.au/public/gtdb/data/releases/latest/auxillary_files/gtdbtk_data.tar.gz
# tar -xzf gtdbtk_data.tar.gz
#############  (THIS HAS BEEN DONE ALREADY)  #########################

# run gtdbtk
export GTDBTK_DATA_PATH=/scratch/project_2005590/databases/GTDB/release202/

singularity exec --bind $GTDBTK_DATA_PATH:$GTDBTK_DATA_PATH,$PWD:$PWD,$TMPDIR:/tmp  \
                    /projappl/project_2005590/containers/gtdbtk_1.7.0.sif \
                    gtdbtk classify_wf -x fasta --genome_dir PATH/TO/GENOME/FOLDER \
                    --out_dir OUTPUT/FOLDER --cpus 4 --tmpdir gtdb_test
```

## Pangenomics with Anvi'o


We will run the whole anvi'o part interactively. So again, allocate a computing node with enough memory (>40G) and 8 threads.  
```
mkdir pangenomics
cd pangenomics

GENOME_DIR=ABSOLUTE/PATH/TO/GENOME/DIR

singularity exec --bind $PWD:$PWD,$GENOME_DIR:/genomes ~/bin/anvio_7.sif \
          anvi-script-reformat-fasta --simplify-names -o Oscillatoria_193.fasta \
          -r reformat_193_report.txt /genomes/GENOME1.fasta

singularity exec --bind $PWD:$PWD,$GENOME_DIR:/genomes ~/bin/anvio_7.sif \
          anvi-script-reformat-fasta --simplify-names -o Oscillatoria_327_2.fasta \
          -r reformat_327_2_report.txt /genomes/GENOME2.fasta

singularity exec --bind $PWD:$PWD,$GENOME_DIR:/genomes ~/bin/anvio_7.sif \
          anvi-script-reformat-fasta --simplify-names -o Oscillatoria_328.fasta \
          -r reformat_328_report.txt /genomes/GENOME3.fasta

# copy reference genomes to your own folder
cp /scratch/project_2005590/COURSE_FILES/closest_oscillatoriales_genomes/*.gbf ./

# annotate
module load biokit
for strain in $(ls *.fasta); do prokka --cpus 8 --outdir ./ --prefix ${strain%.fasta} $strain; done

# process genbank files
for genome in $(ls *.gbf)
do
    singularity exec --bind $PWD:$PWD ~/bin/anvio_7.sif \
                                        anvi-script-process-genbank \
                                            -i $genome -O ${genome%.gbf} \
                                            --annotation-source prodigal \
                                            --annotation-version v2.6.3
done


# make a fasta.txt file from these for pangenomics workflow

for strain in $(ls *-contigs.fa)
do
    echo -e ${strain%-contigs.fa}"\t"$strain"\t"${strain%-contigs.fa}"-external-gene-calls.txt\t"${strain%-contigs.fa}"-external-functions.txt"
done > fasta.txt

# afterwards add headers to fasta.txt file in any text editor, separated with tab
##  name  path	external_gene_calls	gene_functional_annotation

# And make a config.json file:
{
    "workflow_name": "pangenomics",
    "config_version": "2",
    "max_threads": "8",
    "project_name": "Oscillatoriales_pangenome",
    "external_genomes": "external-genomes.txt",
    "fasta_txt": "fasta.txt",
    "anvi_gen_contigs_database": {
        "--project-name": "{group}",
        "--description": "",
        "--skip-gene-calling": "",
        "--ignore-internal-stop-codons": true,
        "--skip-mindful-splitting": "",
        "--contigs-fasta": "",
        "--split-length": "",
        "--kmer-size": "",
        "--skip-predict-frame": "",
        "--prodigal-translation-table": "",
        "threads": ""
    },
    "anvi_pan_genome": {
      "threads": "8"
    }
}

singularity exec --bind $PWD:$PWD ~/bin/anvio_7.sif anvi-run-workflow -w pangenomics -c config.json

cd 03_PAN
export ANVIOPORT=PORT
singularity exec --bind $PWD:$PWD ~/bin/anvio_7.sif \
                                    anvi-display-pan \
                                        -g Oscillatoriales_pangenome-GENOMES.db \
                                        -p Oscillatoriales_pangenome-PAN.db \
                                        --server-only -P $ANVIOPORT

singularity exec --bind $PWD:$PWD ~/bin/anvio_7.sif \
                                    anvi-get-sequences-for-gene-clusters \
                                        -p Oscillatoriales_pangenome-PAN.db \
                                        -g Oscillatoriales_pangenome-GENOMES.db \
                                        -C default -b SCG \
                                        --concatenate-gene-clusters \
                                        -o single-copy-core-genes.fa                               

singularity exec --bind $PWD:$PWD ~/bin/anvio_7.sif \
                                    anvi-gen-phylogenomic-tree \
                                        -f single-copy-core-genes.fa  \
                                        -o SCG.tre

# study the geosmin phylogeny
singularity exec --bind $PWD:$PWD ~/bin/anvio_7.sif \
                                    anvi-get-sequences-for-gene-clusters \
                                    -p Oscillatoriales_pangenome-PAN.db \
                                    -g Oscillatoriales_pangenome-GENOMES.db \
                                    --report-DNA-sequences \
                                    -C default -b Geosmin -o geosmin.fasta

# This time you need  to align the sequences (use  mafft) and construct the tree from  the aligned sequence file (raxml)
# concatenate the header before alignment
sed -i 's/[|:]/_/g' geosmin.fasta

ginsi geosmin.fasta > geosmin_aln.fasta 
raxmlHPC -f a -x 12345 -p 12345 -# 100 -m GTRGAMMA -s geosmin_aln.fasta -n geosmin
```

## Detection of secondary metabolites biosynthesis gene clusters

Biosynthetic genes putatively involved in the synthesis of secondary metabolites can identified using `antiSMASH`

Got to `https://antismash.secondarymetabolites.org/#!/start`. You can load the assembled genome you obtained and turn on all the extra features.

When the analysis is ready, you may be able to answer the following questions:

1. How many secondary metabolites biosynthetic gene clusters (BGC) were detected?
2. Which different types of BGC were detected and qhat is the difference among these types?
3. Do you think your strain produce all these metabolites? Why?


## Comparison of secondary metabolites biosynthesis gene clusters

Biosynthetic genes clusters can be compared using `BiG-SCAPE` (Biosynthetic Gene Similarity Clustering and Prospecting Engine) and `CORASON` (CORe Analysis of Syntenic Orthologs to prioritize Natural Product-Biosynthetic Gene Cluster)  https://bigscape-corason.secondarymetabolites.org/tutorial/index.html


You can run BiG-SCAPE/CORASON in your folder, using the results obtained from antiSMASH. The .gbk files from the three studied strains and selected reference strains from NCBI are available here: `/scratch/project_2005590/COURSE_FILES/BIGSCAPE/combinedGBK`

You need to load bigscape using a Conda environment:

```bash
export PROJAPPL=/projappl/project_2005590
module load bioconda/3
source activate bigscape
```


```bash
sinteractive -A project_2005590
```

Now you can run BiG-SCAPE/CORASON in your user folder:

```bash
mkdir bigscape
cd bigscape/

python /scratch/project_2005590/shishido/BIGSCAPE/bigscape.py -c 8 -i /scratch/project_2005590/COURSE_FILES/BIGSCAPE/combinedGBK --pfam_dir /scratch/project_2005590/COURSE_FILES/BIGSCAPE/Pfam_database -o bigscape_auto --anchorfile /scratch/project_2005590/COURSE_FILES/BIGSCAPE/anchor_domains.txt --mode auto --hybrids-off --mibig  --cutoffs 0.40 0.50 0.60
```

Take a look what it means each parameter used: https://git.wageningenur.nl/medema-group/BiG-SCAPE/-/wikis/home

Once the run is finished, you may transfer the folder to your own computer and observe the results.

Can you find the geosmin and/or 2-methylisoborneol biosynthetic gene clusters?




## Sandbox
Place to store some scratch code while testing.

### checkM
checkM should work from singularity container. Need to pull the right container (tag: 1.1.3--py_0) to course folder and test it once again
```
# needs computing node, otherwise runs out of memory (40G)
singularity exec --bind checkM_test/:/checkM_test /projappl/project_2005590/containers/checkM_1.1.3.sif \
              checkm lineage_wf -x fasta /checkM_test /checkM_test -t 4 --tmpdir /checkM_test
```
### GTDB-tk
Download database before running, needs >200G
```
# download gtdb database
wget https://data.ace.uq.edu.au/public/gtdb/data/releases/latest/auxillary_files/gtdbtk_data.tar.gz
tar -xzf gtdbtk_data.tar.gz

# run gtdbtk
export GTDBTK_DATA_PATH=/scratch/project_2005590 /databases/GTDB/release202/
singularity exec --bind $GTDBTK_DATA_PATH:$GTDBTK_DATA_PATH,$PWD:$PWD  /projappl/project_2005590/containers/gtdbtk_1.7.0.sif \
              gtdbtk classify_wf -x fasta --genome_dir checkM_test/ --out_dir gtdb_test --cpus 4  --tmpdir gtdb_test
```


### basecalling
```

~/projappl/ont-guppy/bin/guppy_basecaller -i fast5_pass/ -s BASECALLED/ -c ~/projappl/ont-guppy/data/dna_r9.4.1_450bps_hac.cfg --device auto --min_qscore 10
cat BASECALLED/pass/*.fastq |gzip > BASECALLED/strain_328_nanopore.fastq.gz
```


### Anvio pangenomics

Reserve enough memory > 40 G
```
mkdir pangenomics
cd pangenomics

singularity exec --bind $PWD:$PWD,../all-genomes-193:/all-genomes-193 ~/bin/anvio_7.sif \
          anvi-script-reformat-fasta --simplify-names -o Oscillatoria_193.fasta -r reformat_193_report.txt /all-genomes-193/strain_328_MAG_00004-contigs.fa

singularity exec --bind $PWD:$PWD,../assembly_327-2:/assembly_327-2 ~/bin/anvio_7.sif \
          anvi-script-reformat-fasta --simplify-names -o Oscillatoria_327_2.fasta -r reformat_327_2_report.txt /assembly_327-2/contigs.fasta

singularity exec --bind $PWD:$PWD,../assembly_328:/assembly_328 ~/bin/anvio_7.sif \
          anvi-script-reformat-fasta --simplify-names -o Oscillatoria_328.fasta -r reformat_328_report.txt /assembly_328/contigs.fasta

cp ../../COURSE_FILES/closest_oscillatoriales_genomes/*.fasta.gz ./
gunzip *.gz

module load biokit
for strain in $(ls *.fasta); do prokka --outdir ${strain%.fasta} --prefix ${strain%.fasta} $strain; done

# process genbank files
for genome in $(ls */*gbf)
do
    singularity exec --bind $PWD:$PWD ~/bin/anvio_7.sif \
                                        anvi-script-process-genbank \
                                            -i $genome -O ${genome%/*} \
                                            --annotation-source prodigal \
                                            --annotation-version v2.6.3
done


# make a fasta.txt file from these for pangenomics workflow

for strain in $(ls *-contigs.fa)
do
    echo -e ${strain%-contigs.fa}"\t"$strain"\t"${strain%-contigs.fa}"-external-gene-calls.txt\t"${strain%-contigs.fa}"-external-functions.txt"
done > fasta.txt

# afterwards add headers to fasta.txt file in any text editor, separated with tab
##  name  path	external_gene_calls	gene_functional_annotation

# And make a config.json file:
{
    "workflow_name": "pangenomics",
    "config_version": "2",
    "project_name": "Oscillatoriales_pangenome",
    "external_genomes": "external-genomes.txt",
    "fasta_txt": "fasta.txt",
    "anvi_gen_contigs_database": {
        "--project-name": "{group}",
        "--description": "",
        "--skip-gene-calling": "",
        "--ignore-internal-stop-codons": true,
        "--skip-mindful-splitting": "",
        "--contigs-fasta": "",
        "--split-length": "",
        "--kmer-size": "",
        "--skip-predict-frame": "",
        "--prodigal-translation-table": "",
        "threads": ""
    },
    "output_dirs": {
        "FASTA_DIR": "01_FASTA_contigs_workflow",
        "CONTIGS_DIR": "02_CONTIGS_contigs_workflow",
        "LOGS_DIR": "00_LOGS_pan_workflow"
    }
}

singularity exec --bind $PWD:$PWD ~/bin/anvio_7.sif anvi-run-workflow -w pangenomics -c config.json

export ANVIOPORT=PORT
singularity exec --bind $PWD:$PWD ~/bin/anvio_7.sif \
                                    anvi-display-pan \
                                        -g Oscillatoriales_pangenome-GENOMES.db \
                                        -p Oscillatoriales_pangenome-PAN.db \
                                        --server-only -P $ANVIOPORT

singularity exec --bind $PWD:$PWD ~/bin/anvio_7.sif \
                                    anvi-get-sequences-for-gene-clusters \
                                        -p 03_PAN/Oscillatoriales_pangenome-PAN.db \
                                        -g 03_PAN/Oscillatoriales_pangenome-GENOMES.db \
                                        -C default -b SCG \
                                        --concatenate-gene-clusters \
                                        -o single-copy-core-genes.fa                               

singularity exec --bind $PWD:$PWD ~/bin/anvio_7.sif \
                                    anvi-gen-phylogenomic-tree \
                                        -f single-copy-core-genes.fa  \
                                        -o SCG.tre


```





## Detection of secondary metabolites biosynthesis gene clusters

Biosynthetic genes putatively involved in the synthesis of secondary metabolites can identified using `antiSMASH`

Got to `https://antismash.secondarymetabolites.org/#!/start`. You can load the assembled genome you obtained and turn on all the extra features.

When the analysis is ready, you may be able to answer the following questions:

1. How many secondary metabolites biosynthetic gene clusters (BGC) were detected?
2. Which different types of BGC were detected and qhat is the difference among these types?
3. Do you think your strain produce all these metabolites? Why?


## Comparison of secondary metabolites biosynthesis gene clusters

Biosynthetic genes clusters can be compared using `BiG-SCAPE` (Biosynthetic Gene Similarity Clustering and Prospecting Engine) and `CORASON` (CORe Analysis of Syntenic Orthologs to prioritize Natural Product-Biosynthetic Gene Cluster)  https://bigscape-corason.secondarymetabolites.org/tutorial/index.html


You can run BiG-SCAPE/CORASON in your folder, using the results obtained from antiSMASH. The .gbk files from the three studied strains and selected reference strains from NCBI are available here: `/scratch/project_2005590/COURSE_FILES/BIGSCAPE/combinedGBK`

You need to load bigscape using a Conda environment:

```bash
export PROJAPPL=/projappl/project_2005590
module load bioconda/3
source activate bigscape
```


```bash
sinteractive -A project_2005590
```

Now you can run BiG-SCAPE/CORASON in your user folder:

```bash
mkdir bigscape
cd bigscape/

python /scratch/project_2005590/shishido/BIGSCAPE/bigscape.py -c 8 -i /scratch/project_2005590/COURSE_FILES/BIGSCAPE/combinedGBK --pfam_dir /scratch/project_2005590/COURSE_FILES/BIGSCAPE/Pfam_database -o bigscape_auto --anchorfile /scratch/project_2005590/COURSE_FILES/BIGSCAPE/anchor_domains.txt --mode auto --hybrids-off --mibig  --cutoffs 0.40 0.50 0.60
```

Take a look what it means each parameter used: https://git.wageningenur.nl/medema-group/BiG-SCAPE/-/wikis/home

Once the run is finished, you may transfer the folder to your own computer and observe the results.

Can you find the geosmin and/or 2-methylisoborneol biosynthetic gene clusters?
