# RNA-seq_pipeline_Quant_TERRA
This repo is a RNA-seq pipeline that can quantify TERRA expression level from different samples (GEO datasets SRA).

## Download this pipeline
<https://github.com/LAXY9887/RNA-seq_pipeline_Quant_TERRA/archive/refs/heads/main.zip>

## Usage
1. First, you need to download the SRA files by SRAToolKit manually. Do this by the `prefetch` command.
   
```prefetch SRR_ID -o SRR_ID.sra```

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
