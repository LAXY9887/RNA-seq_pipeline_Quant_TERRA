#!/bin/bash

## Software
bbduk="/opt/ohpc/Taiwania3/pkg/biology/BBTools/BBTools_v37.62/bin/bbduk.sh"

## User variables
expID=$1
outdir=$2
fq_path=$3
teloSeq_ref=$4
ncore=$5

# Gather read files (Incude file path)
reads_file=$(echo $(ls $fq_path | grep ${expID} | grep .fq.gz))

# Split the read_list into an array
IFS=' ' read -ra READS <<< "$reads_file"
ReadN=${#READS[@]}

# Full file path
if [ $ReadN -eq 2 ]; then
fastq_file=$(echo ${READS[@]} | awk -v pth=$fq_path '{print pth "/" $1 " " pth "/" $2}')
elif [ $ReadN -eq 1 ]; then
fastq_file=$(echo ${READS[@]} | awk -v pth=$fq_path '{print pth "/" $1}')
fi

## Run BBduk
if [ $ReadN -eq 2 ]; then
 fq1=$(echo ${fastq_file} | awk '{print $1}')
 fq2=$(echo ${fastq_file} | awk '{print $2}')
 $bbduk overwrite=t in=$fq1 in2=$fq2 Ref=$teloSeq_ref k=24 hdist=2 threads=$ncore outm=$outdir/${expID}_telo_content_R1.fa outm2=$outdir/${expID}_telo_content_R2.fa stats=$outdir/${expID}_telo_content.stats.txt
elif [ $ReadN -eq 1 ]; then
 $bbduk overwrite=t in=${fastq_file} Ref=$teloSeq_ref k=24 hdist=2 threads=$ncore outm=$outdir/${expID}_telo_content.fa stats=$outdir/${expID}_telo_content.stats.txt
fi

