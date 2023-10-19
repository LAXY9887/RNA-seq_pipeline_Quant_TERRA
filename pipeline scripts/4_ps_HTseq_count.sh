#!/bin/bash

## Softwares
htseq="/staging/biology/ls807terra/0_Programs/anaconda3/envs/RNAseq_quantTERRA/bin/htseq-count"

## User variable
BAM=$1
GTF=$2
ncore=$3
outFile=$4

# Run HTseq-count
$htseq -f bam -s reverse -t exon --idattr gene_name \
 -m intersection-nonempty --nonunique all -n $ncore \
 $BAM $GTF > $outFile

