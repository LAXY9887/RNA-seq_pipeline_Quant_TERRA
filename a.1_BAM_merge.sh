#!/bin/bash
#SBATCH -A MST109178
#SBATCH -J BAM_merge
#SBATCH -p ngs92G
#SBATCH -c 14
#SBATCH --mem=92g
#SBATCH -o ./reports/bw_merge.out.txt
#SBATCH -e ./reports/bw_merge_err.txt

# Software
bamtool=/home/ls807terra/Programs/bamtools/build/bin/bamtools

# User vars
BAM_list=/staging/biology/ls807terra/Nanopore_seq/script/RNAseq_TERRA_pipeline_Tissue_batch3/BAM_file_young.txt

# Program
$bamtool merge -list $BAM_list -out /staging/biology/ls807terra/Nanopore_seq/Pipelines/Pipeline_Tissue_batch3/bamMerge/STAR_align_young_samples_merge.bam

