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

### Searching the database

You can search published RNA-seq datasets from [NCBI GEO datasets](https://www.ncbi.nlm.nih.gov/gds).

For example, I had search "ALT osteosarcoma RNA-seq" on the database and selected one for the analysis.

![GEO search](https://github.com/LAXY9887/RNA-seq_pipeline_Quant_TERRA/assets/109268110/14867cd0-354a-4145-a0f6-559d7dbe9d64)

By clicking into the search result, you can see the information of a dataset.

You can find the published paper on this page, indicating by the red box.

Here I had choose a study about gene fusion events in different types of human cancer cell.

I had used this dataset to analysis the TERRA (and gene) expression difference. 

![datasets info](https://github.com/LAXY9887/RNA-seq_pipeline_Quant_TERRA/assets/109268110/5e940c90-c99a-44a6-b364-3add2fcede03)

### Searching the data

To download one of the sequencing raw data, click a sample in the page.

![data samples](https://github.com/LAXY9887/RNA-seq_pipeline_Quant_TERRA/assets/109268110/599ff85d-14ba-4702-a502-2991807e4aef)

The experiment details were recorded in a sample information page. 

You can check if the tissue, cell line or experiment condition meet your requirements.

**The Dataset information page**

![sample page](https://github.com/LAXY9887/RNA-seq_pipeline_Quant_TERRA/assets/109268110/a79c1b5c-ab8d-4885-9c41-9aa6746890b5)

Click the SRA link at the bottom of the page to access the SRA ID.

![SRA ID fetch](https://github.com/LAXY9887/RNA-seq_pipeline_Quant_TERRA/assets/109268110/fa0929ef-b773-40b1-9575-7b9efeba2048)

In a SRA information page, you can see the information about sequencing library preparation.

It is very important message that will be useful in the later analysis.

The SRA ID can be found at the table below, you should record this ID for downloading.

![SRA page](https://github.com/LAXY9887/RNA-seq_pipeline_Quant_TERRA/assets/109268110/26eed5aa-319f-4e4a-afa5-da355013de3f)

You can also click the SRA Run **Selector** link at the dataset information page to select multiple datasets.

![SRA selector link](https://github.com/LAXY9887/RNA-seq_pipeline_Quant_TERRA/assets/109268110/05331d89-114d-4597-830e-ae69b260ed61)

Check any sample you want and download the SRA ID list by clicking **Accesstion list**.

To download the table format, click the **Metadata**.

![SRA selector](https://github.com/LAXY9887/RNA-seq_pipeline_Quant_TERRA/assets/109268110/92bf257a-86bd-4ab9-9f88-110b15774691)

You can get a SRA ID list (text file) that record each accession number like this:



### Downloading the data

## Reference

1. 	Mason-Osann E, Dai A, Floro J, Lock YJ et al. Identification of a novel gene fusion in ALT positive osteosarcoma. Oncotarget 2018 Aug 28;9(67):32868-32880.
