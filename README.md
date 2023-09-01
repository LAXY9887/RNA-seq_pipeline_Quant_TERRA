# RNA-seq_pipeline_Quant_TERRA
This repo is a RNA-seq pipeline that can quantify TERRA expression level from different samples (GEO datasets SRA).

## Workflow
### This pipeline is consists of 3 major parts, and the figure below illustrates the construction:
1. Collecting the RNA-seq read data (fastq) from NCBI GEO datasets and quality filtering (**SRA Download** and **TrimGalore!**).
2. Align the processed reads to CHM13 genome, counting gene and TERRA expression (**STAR alignment**, **HTseq-count** and **TelomereHunter**).
3. Normalize the read counts and generate the TERRA (or gene) expression heatmap (**YARN and other R packages**).
4. Additional: Convert the alignment file (BAM) to coverage file (bigwig) by **deeptools**.

![RNA-seq pipeline white](https://github.com/LAXY9887/RNA-seq_pipeline_Quant_TERRA/assets/109268110/0c013272-bc2f-4c67-8d00-1ca098fd4a5a "workflow")
