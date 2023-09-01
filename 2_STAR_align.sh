#!/bin/bash

## softwares
samtools=/opt/ohpc/Taiwania3/pkg/biology/SAMTOOLS/SAMTOOLS_v1.13/bin/samtools
STAR=/work/opt/ohpc/Taiwania3/pkg/biology/STAR/STAR_v2.7.9a/bin/Linux_x86_64/STAR

## Constants
gCHM13=/staging/biology/ls807terra/0_genomes/star_index/CHM13_human

## Inputs
reads=$1

## User varibles
ncore=$2
oPrefix=$3

# Split the read_list into an array
IFS=',' read -ra READS <<< "$reads"
ReadN=${#READS[@]}

## Run STAR alignment
$STAR \
 --runThreadN $ncore \
 --genomeDir $gCHM13 \
 --runMode alignReads \
 --readFilesCommand zcat \
 --readFilesIn ${READS[@]} \
 --outSAMtype BAM SortedByCoordinate \
 --outFileNamePrefix ${oPrefix}

## Run samtool indexing
$samtools index ${oPrefix}Aligned.sortedByCoord.out.bam

