#!/bin/bash

## Softwares
htseq=/home/ls807terra/Programs/anaconda3/envs/env_Python3.8/bin/htseq-count

## User variable
BAM=$1
GTF=$2
ncore=$3
outFile=$4

# Run HTseq-count
$htseq -f bam -s reverse -t transcript --idattr gene_name \
 -m intersection-nonempty --nonunique all -n $ncore \
 $BAM $GTF > $outFile

