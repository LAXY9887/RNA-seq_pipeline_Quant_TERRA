#!/bin/bash

## softwares
samtools="/opt/ohpc/Taiwania3/pkg/biology/SAMTOOLS/SAMTOOLS_v1.13/bin/samtools"
STAR="/opt/ohpc/Taiwania3/pkg/biology/STAR/STAR_v2.7.9a/bin/Linux_x86_64/STAR"

## Constants
gCHM13="/staging/biology/ls807terra/0_genomes/star_index/CHM13_human"

## Inputs
fq_path=$1

## User varibles
ncore=$2
oPrefix=$3

# Gather read files (Incude file path)
reads_file=$(echo $(ls $fq_path | grep .fq.gz))

# Split the read_list into an array
IFS=' ' read -ra READS <<< "$reads_file"
ReadN=${#READS[@]}

# Full file path
if [ $ReadN -eq 2 ]; then
fastq_file=$(echo ${READS[@]} | awk -v pth=$fq_path '{print pth "/" $1 " " pth "/" $2}')
elif [ $ReadN -eq 1 ]; then
fastq_file=$(echo ${READS[@]} | awk -v pth=$fq_path '{print pth "/" $1}')
fi

## Run STAR alignment
$STAR \
 --runThreadN $ncore \
 --genomeDir $gCHM13 \
 --runMode alignReads \
 --readFilesCommand zcat \
 --readFilesIn ${fastq_file[@]} \
 --outSAMtype BAM SortedByCoordinate \
 --outFileNamePrefix ${oPrefix}

## Run samtool indexing
$samtools index ${oPrefix}Aligned.sortedByCoord.out.bam

