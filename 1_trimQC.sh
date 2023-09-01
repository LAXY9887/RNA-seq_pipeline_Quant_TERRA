#!/bin/bash

## Software
trim=/opt/ohpc/Taiwania3/pkg/biology/TrimGalore/TrimGalore_v0.6.3/trim_galore
cutadapt=/opt/ohpc/Taiwania3/pkg/biology/Cutadapt/Cutadapt_v2.3/bin/cutadapt

## User variables
expID=$1
outdir=$2
reads=$3
ncore=$4

## Separate reads
IFS=',' read -ra READS <<< "$reads"
readN=${#READS[@]}

## Run trimgalore
if [ $readN -eq 2 ]; then
$trim -j $ncore -q 30 --illumina --paired --gzip --path_to_cutadapt $cutadapt ${READS[@]} -o $outdir/$expID
elif [ $readN -eq 1 ]; then
$trim -j $ncore -q 30 --illumina --gzip --path_to_cutadapt $cutadapt $READS -o $outdir/$expID
fi
