# Practicals

All material for practical parts in this folder

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

The raw data used on this course can be found in `/scratch/project_2005590/COURSE_FILES/RAWDATA`.  
Instead of copying the data we will use links to this folder in all of the needed tasks.  
Why don't we want 14 students copying data to their own folders?

## QC and trimming
QC for the raw data takes few minutes, depending on the allocation.  
Go to your working directory and make a folder called e.g. `FASTQC` for the QC reports.  

QC does not require lot of memory and can be run on the interactive nodes using `sinteractive`.   

Activate the biokit environment and open interactive node:

```bash
sinteractive -A project_2005590
module load biokit
```

### Running fastQC
Run `fastQC` to the files stored in the RAWDATA folder. What does the `-o` and `-t` flags refer to?

```bash
fastqc /scratch/project_2005590/COURSE_FILES/RAWDATA/_FILENAMESHERE_* -o FASTQC/ -t 2
```

Running the QC step on all sequence files would take too long, so they are already done and you can just copy them.
Make sure you're on your own folder before copying.

```bash
cd /scratch/project_2005590/$USER
cp -r /scratch/project_2005590/COURSE_FILES/FASTQC_RAW ./
```

Then combine the reports in FASTQC folder with multiQC:
MultiQC is not pre-installed to Puhti, so we have created a virtual environment that has it.

```bash
export PROJAPPL=/projappl/project_2005590
module purge
module load bioconda/3
source activate QC_env
multiqc FASTQC_RAW/* -o FASTQC_RAW --interactive
```

To leave the interactive node, type `exit`.  

Copy the resulting HTML file to your local machine with `scp` from the command line (Mac/Linux) or *WinSCP* on Windows.  
Have a look at the QC report with your favourite browser.  

After inspecting the output, it should be clear that we need to do some trimming.  
__What kind of trimming do you think should be done?__

### Running Cutadapt
For trimming we have an array script that runs `Cutadapt` for each file in the `RAWDATA` folder.  
Go to your working directory and copy the `CUTADAPT.sh` script from `/scratch/project_2001499/COURSE_FILES/SBATCH_SCRIPTS`.  
Check the script for example with the command `less`.  
The adapter sequences that you want to trim are located after `-a` and `-A`.  
What is the difference with `-a` and `-A`?  
And what is specified with option `-p` or `-o`?
And how about `-m` and `-j`?  
You can find the answers from Cutadapt [manual](http://cutadapt.readthedocs.io).

Before running the script, we need to create the directory where the trimmed data will be written:

```bash
mkdir TRIMMED
```

Then we need to submit our jos to the SLURM system.  
Make sure to submit it from your own folder.  
More about CSC batch jobs here: https://docs.csc.fi/computing/running/creating-job-scripts-puhti/.  

```bash
sbatch CUTADAPT.sh
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

### Running fastQC on the trimmed reads
Go to the folder containing the trimmed reads (`TRIMMED`) and view the `Cutadapt` log. Can you answer:

* How many read pairs we had originally?
* How many reads contained adapters?
* How many read pairs were removed because they were too short?
* How many base calls were quality-trimmed?
* Overall, what is the percentage of base pairs that were kept?

Then make a new folder (`FASTQC`) for the QC files of the trimmed data and run fastQC and multiQC again as you did before trimming:
Again the QC part would take too long, so we have created the files for you to copy and run only the multiQC part.

```bash
cd /scratch/project_2005590/$USER
cp -r /scratch/project_2005590/COURSE_FILES/FASTQC_TRIMMED ./
```

```bash
sinteractive -A project_2005590

export PROJAPPL=/projappl/project_2005590
module load bioconda/3
conda deactivate
source activate QC_env

multiqc FASTQC_TRIMMED/* -o FASTQC_TRIMMED --interactive
```

Copy the resulting HTML file to your local machine as earlier and look how well the trimming went.  


# Sandbox
Place to store some scratch code while testing. 

## checkM
checkM should work from singularity container. Need to pull the right container (tag: 1.1.3--py_0) to course folder and test it once again
```
# needs computing node, otherwise runs out of memory
singularity exec --bind checkM_test/:/checkM_test ~/projappl/containers/checkm-genome_1.1.3--py_0.sif checkm lineage_wf -x fasta /checkM_test /checkM_test -t 4 --tmpdir /checkM_test
```
## GTDB-tk
Download database before running
```
wget https://data.ace.uq.edu.au/public/gtdb/data/releases/latest/auxillary_files/gtdbtk_data.tar.gz
