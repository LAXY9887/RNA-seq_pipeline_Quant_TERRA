#!/bin/bash

## Software
trim="/opt/ohpc/Taiwania3/pkg/biology/TrimGalore/TrimGalore_v0.6.3/trim_galore"
cutadapt="/opt/ohpc/Taiwania3/pkg/biology/Cutadapt/Cutadapt_v2.3/bin/cutadapt"

## User variables
expID=$1
outdir=$2
fq_path=$3
ncore=$4

# Gather read files (Incude file path)
reads_file=$(echo $(ls $fq_path | grep $expID))

# Split the read_list into an array
IFS=' ' read -ra READS <<< "$reads_file"
ReadN=${#READS[@]}

# Full file path
if [ $ReadN -eq 2 ]; then
fastq_file=$(echo ${READS[@]} | awk -v pth=$fq_path '{print pth "/" $1 " " pth "/" $2}')
elif [ $ReadN -eq 1 ]; then
fastq_file=$(echo ${READS[@]} | awk -v pth=$fq_path '{print pth "/" $1}')
fi

## Run trimgalore
if [ $ReadN -eq 2 ]; then
$trim -j $ncore -q 30 --fastqc --illumina --paired --gzip --path_to_cutadapt $cutadapt ${fastq_file[@]} -o $outdir/$expID
elif [ $ReadN -eq 1 ]; then
$trim -j $ncore -q 30 --fastqc --illumina --gzip --path_to_cutadapt $cutadapt $fastq_file -o $outdir/$expID
fi

