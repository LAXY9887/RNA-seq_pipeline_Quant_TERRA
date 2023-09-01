#!/bin/bash

# Program
SRA_prefetch=/home/ls807terra/Programs/SRA_Toolkit/SRAToolkit_v2.11.1/bin/prefetch

# User vars
SRRID_file=$1
outDIR=$2

# Download
while read line
do
$SRA_prefetch ${line} -o ${outDIR}/${line}.sra &
done < $SRRID_file

