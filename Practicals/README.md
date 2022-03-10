# Practicals
All material for practical parts in this folder

__TOC:__
1. [Setting up](#setting-up-the-course-folders)
2. [Interactive use of Puhti](#interactive-use-of-puhti)
3. [QC and trimming](#qc-and-trimming)
4. [Genome assembly with Spades](#genome-assembly-with-spades)
5. [Kaiju](#kaiju)


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

The raw data used on this course can be found in `/scratch/project_2005590/COURSE_FILES/RAWDATA_MISEQ`.  
Instead of copying the data we will use links to this folder in all of the needed tasks.  
Why don't we want 14 students copying data to their own folders?

## Interactive use of Puhti

Puhti uses a scheduling system called SLURM. Most jobs are sent to the queue,  but smaller jobs can be run interactively.

Interactive session is launched with `sinteractive`   .   
You can specify the resources you need for you interactive work interactively with `sinteractive -i`. Or you can give them as options to `sinteractive`.  
You always need to specify the accounting project (`-A`, `--account`). Otherwise for small jobs you can use the default resources (see below).

| Option | Function | Default | Max | 
| --     | --       | --      | --  |
| -i, --interactive | set resources interactively | | |
| -t,  --time | Reservation in minutes or in format d-hh:mm:ss | 24:00:00 | 7-00:00:00 |
| -m, --mem | Memory in Mb       | 2000     | 76000  |
| -j, --jobname |Job name       | interactive     |   |
| -c, --cores     | Number of cores       | 1      | 8  |
| -A, --account     | Accounting project       |       |  |
| -d, --tmp     | $TMPDIR size (in GiB)      |  32     | 760  |
| -g, --gpu     | Number of GPUs       | 0     | 0 |


[__Read more about interactive use of Puhti.__](https://docs.csc.fi/computing/running/interactive-usage/#sinteractive-in-puhti)   


## QC and trimming
QC for the raw data takes few minutes, depending on the allocation.  
Go to your working directory and make a folder called e.g. `FASTQC_RAW` for the QC reports.  

QC does not require lot of memory and can be run on the interactive nodes using `sinteractive`.

Activate the biokit environment and open interactive node:

```bash
sinteractive -A project_2005590
module load biokit
```

Now each group will work with their own sequences. Create the link to R1 and R2 just for the strain you will use:

```bash
#### Illumina Raw sequences for the cyanobacteria strain 328
R1=/scratch/project_2005590/COURSE_FILES/RAWDATA_MISEQ/A045-328-GGTCCATT-AGTAGGCT-Tania-Shishido-run20211223R_S45_L001_R1_001.fastq.gz
R2=/scratch/project_2005590/COURSE_FILES/RAWDATA_MISEQ/A045-328-GGTCCATT-AGTAGGCT-Tania-Shishido-run20211223R_S45_L001_R2_001.fastq.gz

#### Illumina Raw sequences for the cyanobacteria strain 327
R1=/scratch/project_2005590/COURSE_FILES/RAWDATA_MISEQ/A044-327-2-CTTGCCTC-GTTATCTC-Tania-Shishido-run20211223R_S44_L001_R1_001.fastq.gz
R2=/scratch/project_2005590/COURSE_FILES/RAWDATA_MISEQ/A044-327-2-CTTGCCTC-GTTATCTC-Tania-Shishido-run20211223R_S44_L001_R2_001.fastq.gz

#### Illumina Raw sequences for the cyanobacteria strain 193
R1=/scratch/project_2005590/COURSE_FILES/RAWDATA_MISEQ/Oscillatoria-193_1.fastq.gz
R2=/scratch/project_2005590/COURSE_FILES/RAWDATA_MISEQ/Oscillatoria-193_2.fastq.gz
```


You can check if your link is correct by using:

```bash
echo $R1
```




### Running fastQC
Run `fastQC` to the files stored in the RAWDATA folder. What does the `-o` and `-t` flags refer to?

```bash
fastqc $R1 -o FASTQC_RAW/ -t 1

fastqc $R2 -o FASTQC_RAW/ -t 1
```



Copy the resulting HTML file to your local machine with `scp` from the command line (Mac/Linux) or *WinSCP* on Windows.  
Have a look at the QC report with your favourite browser.  

After inspecting the output, it should be clear that we need to do some trimming.  
__What kind of trimming do you think should be done?__

### Running Cutadapt


```bash
# To create a link to your cyanobacterial strain:
strain=328
```

The adapter sequences that you want to trim are located after `-a` and `-A`.  
What is the difference with `-a` and `-A`?  
And what is specified with option `-p` or `-o`?
And how about `-m` and `-j`?  
You can find the answers from Cutadapt [manual](http://cutadapt.readthedocs.io).

Before running the script, we need to create the directory where the trimmed data will be written:

```bash
mkdir TRIMMED
```


```bash
cutadapt -a CTGTCTCTTATA -A CTGTCTCTTATA -o TRIMMED/"$strain"_cut_1.fastq -p TRIMMED/"$strain"_cut_2.fastq $R1 $R2 --minimum-length 80 > cutadapt.log

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
fastqc *.fastq -o fastqc_out_trimmed/ -t 1
```



Copy the resulting HTML file to your local machine as earlier and look how well the trimming went.  
Did you find problems with the sequences? We can further proceed to quality control using Prinseq.


### Running Prinseq

You could check the different parameters that can be used in prinseq:
http://prinseq.sourceforge.net/manual.html



```bash

module load prinseq

```

Run program using the previous trimmed reads:

```bash
prinseq-lite.pl \
-fastq TRIMMED/"$strain"_cut_1.fastq \
-fastq2 TRIMMED/"$strain"_cut_2.fastq \
-min_qual_mean 25 \
-trim_left 10 \
-trim_right 8 \
-trim_qual_right 36 \
-trim_qual_left 30 \
-min_len 80 \
-out_good TRIMMED/"$strain"_pseq -log prinseq.log
```

You can check the `prinseq.log` and run again FastQC on the Prinseq trimmed sequences and copy them to your computer. You can now compare the quality of these sequences with the raw and cutadapt trimmed sequences FastQC results. Did you find any difference?



```bash
cd TRIMMED/

fastqc "$strain"_pseq_*.fastq -o fastqc_out_trimmed/ -t 1

```




To combine all the reports .zip in a new `combined_fastqc` folder with multiQC:
```bash
mkdir combined_fastqc

cp FASTQC_RAW/*zip combined_fastqc/
cp TRIMMED/fastqc_out_trimmed/*zip combined_fastqc/

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

You can copy the file `multiqc_report.html` to your computer and open it in a webbrowser. Can you see any difference amon the raw and trimmed reads?



## Genome assembly with Spades
Now that you have good trimmed sequences, we can assemble the reads.
For assembling you will need more resources than the default.  
Allocate 8 cpus, 20000 Mb of memory (20G) and 4 hours.  
Remember also the accounting project, `project_2005590`.

```bash

# Remember to modify  this
sinteractive --account --time --mem --cores

# Activate program
module load gcc/9.1.0
module load spades/3.15.0


# Cyano strain and processed reads
strain=328
R1=TRIMMED/"$strain"_pseq_1.fastq
R2=TRIMMED/"$strain"_pseq_2.fastq

```

### Run Spades

Check the commands used using `spades.py -h`

```bash
spades.py --only-assembler -1 $R1 -2 $R2 -o "spades_"$strain -t 8
```

Remember to close the interactive connection and free the resourses after use with `exit`.



## kaiju

```bash
module load bioconda/3

```

### Run kaiju batch script
You can copy the script based on the strains your are using from `/scratch/project_2005590/RAWDATA`. You could go through the script and look at https://docs.csc.fi/computing/running/creating-job-scripts-puhti/ and `kaiju -h` before run in your folder:

```bash

sbatch kaiju_illumina_328.sh

```


You can check the status of your job with:  **didn't work

```bash
squeue -l -u $USER
```

After the job has finished, you can see how much resources it actually used and how many billing units were consumed.

```bash
seff JOBID
```

**NOTE:** Change **JOBID** the the job id number you got when you submitted the script.












































# Sandbox
Place to store some scratch code while testing.

## checkM
checkM should work from singularity container. Need to pull the right container (tag: 1.1.3--py_0) to course folder and test it once again
```
# needs computing node, otherwise runs out of memory
singularity exec --bind checkM_test/:/checkM_test /projappl/project_2005590/containers/checkM_1.1.3.sif \
              checkm lineage_wf -x fasta /checkM_test /checkM_test -t 4 --tmpdir /checkM_test
```
## GTDB-tk
Download database before running
```
# download gtdb database
wget https://data.ace.uq.edu.au/public/gtdb/data/releases/latest/auxillary_files/gtdbtk_data.tar.gz
tar -xzf gtdbtk_data.tar.gz

# run gtdbtk
export GTDBTK_DATA_PATH=/scratch/project_2005590 /databases/GTDB/release202/
singularity exec --bind $GTDBTK_DATA_PATH:$GTDBTK_DATA_PATH,$PWD:$PWD  /projappl/project_2005590/containers/gtdbtk_1.7.0.sif \
              gtdbtk classify_wf -x fasta --genome_dir checkM_test/ --out_dir gtdb_test --cpus 4  --tmpdir gtdb_test
```
