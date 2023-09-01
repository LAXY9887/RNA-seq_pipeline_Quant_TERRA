# RNA-seq_pipeline_Quant_TERRA
This repo is a RNA-seq pipeline that can quantify TERRA expression level from different samples (GEO datasets SRA).

## Workflow

This pipeline is consists of 3 major parts, and the figure below illustrates the construction:

1. Collecting the RNA-seq read data (fastq) from NCBI GEO datasets and quality filtering.

   (**SRA Download and TrimGalore!**)
   
2. Align the processed reads to CHM13 genome, counting gene and TERRA expression.

   (**STAR, HTseq-count and TelomereHunter**)

3. Normalize the read counts and generate the TERRA (or gene) expression heatmap.

   (**YARN and other R packages**)

◆ Additional: Convert the alignment file (BAM) to coverage file (bigwig) by **deeptools**.

![RNA-seq pipeline white](https://github.com/LAXY9887/RNA-seq_pipeline_Quant_TERRA/assets/109268110/69872114-15ac-49f2-9945-c6223f4ecb88 "workflow")

## Part1: Collect data from NCBI
