#!/bin/bash

# Software
fastqdump="/opt/ohpc/Taiwania3/pkg/biology/SRAToolkit/sratoolkit_v2.11.1/bin/fastq-dump"

# User vars
SRA_file=$1
fastq_Path=$2

# Program
$fastqdump --split-files --gzip --outdir $fastq_Path $SRA_file

