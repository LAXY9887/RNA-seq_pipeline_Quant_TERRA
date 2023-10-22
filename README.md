# RNA-seq_pipeline_Quant_TERRA
This repo is a RNA-seq pipeline that can quantify TERRA expression level from different samples (GEO datasets SRA).

## Download this pipeline

<https://github.com/LAXY9887/RNA-seq_pipeline_Quant_TERRA/archive/refs/heads/main.zip>

## Setup conda enviroment

Create a conda enviroment by the yaml file provided in the `install_env/`

**Two separated enviroment should be created!**

   1. `RNAseq_quantTERRA_env` for general RNA-seq analysis.

   2. `TelomereHunter_env` for counting telomeric-repeats read content.

*They are separated because that telomerehunter use python2 and old version of R.*

*The enviroment will crash if install telomerehunter with other tools.*
 
### **_Command line_:**

   `conda env create -n "RNAseq_quantTERRA_env" -f RNAseq_quantTERRA_env.yml`

   `conda env create -n "TelomereHunter_env" -f TelomereHunter_env.yml`

## Install R packages for `RNAseq_quantTERRA_env`

All the package you need for the RNA-seq analysis (mainly DEseq2) can be install by executing the `install_R_packages_RNAseq_quantTERRA.R`

To install, first activate the conda enviroment:

   `conda activate RNAseq_quantTERRA_env`

### **Notice! Very important!**

You will have some error when installing the R package `devtools` and `xml2`.

For solving  `xml2`, you simply need to install `libxml2` by conda, which is automaticlly installed by the yaml file.

To handle `devtools` problem, you need to fix the libpng in the conda enviroment `lib/`

### Problem:

   libpng15 not found, when installing devtools and some others.
   
   It possible that you have already install libpng, but R can not find it.
   
   Because it usually recongizes the libpng15.so, and you probably have another version. 

### Solution:

   Before running install_R_packages_RNAseq_quantTERRA.R
   
   1. Make sure that there is libpng installed in your conda enviroment.
   
    conda install libpng 
   
   2. Find it under /your/path/to/anaconda3/env/your_env/lib/
   
    For example. I have these file under my env path 
    
    ls ~/anaconda3/env/TEST_env/lib/ | grep png
    
    libpng16.a
    libpng16.so
    libpng16.so.16
    libpng16.so.16.39.0
    libpng.a
    libpng.so
   
    The version of my libpng is 16 not 15, so R can not find it.
    
   3. Create a softlink that named "libpng15.so" but were direct to libpng16.so
   
    Build a softlink 
   
    ln -s libpng16.so.16.39.0 libpng15.so
    
   4. Now R should find libpng15 properly.

Make sure the libpng were fixed. Then you can execute `install_R_packages_RNAseq_quantTERRA.R` by Rscript:

   `Rscript install_R_packages_RNAseq_quantTERRA.R`

*This will run a verrrrry long time.*

## Install R packages for `TelomereHunter_env`

**Once you have install telomerehunter, you will find that it doesn't work. LOL**

This is because that you need to additionally install many R packages.

Firstly, activate the conda enviroment:

   `conda activate TelomereHunter_env`

Then execute the `install_R_packages_TelomereHunter.R` by Rscript.

   `Rscript install_R_packages_TelomereHunter.R`

*Strikingly, installing any version of R >= 3.0 will crash this enviroment, you can only install those package under system.*

*If root permission was not avaliable, install it as a user R lib by specifying the install prefix to /home.*

*This will also run a verrrrry long time.*

### How to fix PDF plot bug of telomerehunter?

   PDF plot have error while doing telomerehunter.
   
   It is because plenty of R script used in telomerehunter lacks `"library(ggplot2)"`
   
   Therefore the error message often seem were `"there is no function ggplot()"` or `"there is no function theme()"`

   To fix this, you need to find the R scritps of telomere hunter and edit them to add `"library(ggplot2)"`.

   R script path: 
   
   `/path/to/your/telomereHunter_env/lib/python2.7/site-packages/telomerehunter/`
   
   Find those R scripts:

   `find /path/to/your/telomereHunter_env/* -name "*.R"`

   ```

   For example, we have these R scripts:

   telomereHunter/lib/python2.7/site-packages/telomerehunter/plot_gc_content_simple.R
   telomereHunter/lib/python2.7/site-packages/telomerehunter/TVR_context_summary_tables.R
   telomereHunter/lib/python2.7/site-packages/telomerehunter/plot_tel_content.R
   telomereHunter/lib/python2.7/site-packages/telomerehunter/plot_repeat_frequency_intratelomeric.R
   telomereHunter/lib/python2.7/site-packages/telomerehunter/plot_spectrum_summary_simple.R
   telomereHunter/lib/python2.7/site-packages/telomerehunter/summary_log2.R
   telomereHunter/lib/python2.7/site-packages/telomerehunter/plot_unmapped_summary.R
   telomereHunter/lib/python2.7/site-packages/telomerehunter/plot_spectrum_simple.R
   telomereHunter/lib/python2.7/site-packages/telomerehunter/singleton_plot.R
   telomereHunter/lib/python2.7/site-packages/telomerehunter/plot_unmapped_summary_simple.R
   telomereHunter/lib/python2.7/site-packages/telomerehunter/check_R_libraries.R
   telomereHunter/lib/python2.7/site-packages/telomerehunter/combine_plots.R
   telomereHunter/lib/python2.7/site-packages/telomerehunter/plot_spectrum_summary.R
   telomereHunter/lib/python2.7/site-packages/telomerehunter/TVR_plot.R
   telomereHunter/lib/python2.7/site-packages/telomerehunter/normalize_TVR_counts.R
   telomereHunter/lib/python2.7/site-packages/telomerehunter/plot_spectrum.R
   telomereHunter/lib/python2.7/site-packages/telomerehunter/functions_for_plots.R
   telomereHunter/lib/python2.7/site-packages/telomerehunter/plot_gc_content.R

   ```

   Some of them have already load ggplot2 but some have not.

   Add "library(ggplot2)" to every R scripts is recommanded.

   After loading ggplot2, telomerehunter PDF plots can be generated.

## Use this pipeline
1. First, you need to download the SRA files by SRAToolKit manually. Do this by the `prefetch` command.
   
   ```prefetch SRR_ID -o SRR_ID.sra```
   
    _**※ This is because NCHC nodes are not allowed for connecting to the Internet.**_
    
    _**※ Otherwise, it can be downloaded and exreacted to fastq by simply doing the command:**_
   
   ``` fastq-dump --split-files SRR_ID -O /path/to/output/dir/ ```

2. Configure the `c.0_RNAseq_QuantTERRA.cfg` file.

   Edit the software path and other settings in the `c.0_RNAseq_QuantTERRA.cfg` file.

   After editing settings, run `sh 0_Configure_Setting.sh c.0_RNAseq_QuantTERRA.cfg`.

   *All pipeline scripts, `c.0_RNAseq_QuantTERRA.cfg` and `0_Configure_Setting.sh` should be under the same directory.*

   **The format of the configure file is as follow:**

   ```
   ## Genome
   CHM13GENOME:/staging/biology/ls807terra/0_genomes/star_index/CHM13_human
   
   ## SLURM setting
   PARTITION:186
   MEMORY:186
   NCORE:28
   
   ## Pipeline workdir, Please specifiy this!
   WORKDIR:../
   
   ## TERRA quantification region files.
   
   # TERRA regions for TERRA counts.
   QREGION:/staging/biology/ls807terra/0_bedfiles/hTERRA/CHM13_TERRA_region_v6.bed
   
   # Human CHM13 GTF for total gene count.
   QGTF:/staging/biology/ls807terra/0_genomes/genome_gtf/CHM13/CHM13_v2.0.gtf
   
   # CHM13 cytoband file with TERRA regions for telomerehunter.
   CYTOBAND:/staging/biology/ls807terra/0_bedfiles/hTERRA/chm13v2.0_cytobands_allchrs_Add_TERRA_v3.bed
   
   ## Software path
   
   # SRAToolKit fastq-dump
   FASTQDUMP:/opt/ohpc/Taiwania3/pkg/biology/SRAToolkit/sratoolkit_v2.11.1/bin/fastq-dump
   
   # SRAToolKit prefetch
   PREFETCH:/opt/ohpc/Taiwania3/pkg/biology/SRAToolkit/sratoolkit_v2.11.1/bin/prefetch
   
   # Trimgalore
   TRIMGALORE:/opt/ohpc/Taiwania3/pkg/biology/TrimGalore/TrimGalore_v0.6.3/trim_galore
   
   # Cutadapt
   CUTADAPT:/opt/ohpc/Taiwania3/pkg/biology/Cutadapt/Cutadapt_v2.3/bin/cutadapt
   
   # samtools
   SAMTOOLS:/opt/ohpc/Taiwania3/pkg/biology/SAMTOOLS/SAMTOOLS_v1.13/bin/samtools
   
   # STAR alignment
   STARALIGN:/opt/ohpc/Taiwania3/pkg/biology/STAR/STAR_v2.7.9a/bin/Linux_x86_64/STAR
   
   # deeptools bamcoverage
   BAMCOV:/opt/ohpc/Taiwania3/pkg/biology/deepTools/deepTools_v3.3.1/bin/bamCoverage
   
   # UCSC tools bigwig to bedgraph
   BW2BGD:/staging/biology/ls807terra/0_Programs/UCSC_tools/bigWigToBedGraph
   
   # HTseq-count
   HTSEQ:/staging/biology/ls807terra/0_Programs/anaconda3/envs/RNAseq_quantTERRA/bin/htseq-count
   
   # Telomerehunter for TERRA count
   THNTER:/staging/biology/ls807terra/0_Programs/anaconda3/envs/telomereHunter/bin/telomerehunter
   
   # BAM tools for BAM merge
   BAMTOOL:/staging/biology/ls807terra/0_Programs/bamtools/build/bin/bamtools
   ```
   ### Configure file's Rules: 
   
   1. To comment or annotate, please add a "#" at the start of a line.
   
   2. Format -> TOOL_ID:/path/to/Software , separated by ":".
   
   3. Please update the software path if they were changed.
   
   4. To rigister a new tool and its path:
   
   -> 4.1 In a pipeline script (file name: *_ps_*.sh), write:
    	       ''' software="TOOL_ID"
    	           # To use the software
    	           ${software} -options [files] ... '''
   
   -> 4.2 In this configure file, write:
    	       ''' TOOL_ID:/path/to/this/tool
   
   -> 4.3 Run the script: sh 0_Configure_Setting.sh this_configure_file.cfg
   	       This will reconginze the "TOOL_ID" in a script and replace it by "/path/to/this/tool"
   
   5. Make sure that all pipeline script (file name: *_ps_*.sh) are in the same directory with 0_Configure_Setting.sh and this configure file.

3. Sent a single SRA file to execute this pipeline:

  *Usage:* `sh 0.0_ps_Pipeline_v3.sh SRR_ID`

  *Example:* `sh 0.0_ps_Pipeline_v3.sh SRRSRR3304509`

  ## **Notice!**

  **Your SRA file need to be locate at ${workdir}/SRA!**

  **Check the configure file `c.0_RNAseq_QuantTERRA.cfg`.**

  **The workdir is usually at "../" .**

## Requirement
1. SRAToolkit (v2.11.1)
2. TrimGalore! (v0.6.3)
3. Cutadapt (v2.3)
4. fastqc (v0.12.1)
5. STAR (2.7.9)
6. samtools (v1.13)
7. deeptools (v3.3.1)
8. htseq-count (Python3.8)
9. telomerehunter (R4.2)
