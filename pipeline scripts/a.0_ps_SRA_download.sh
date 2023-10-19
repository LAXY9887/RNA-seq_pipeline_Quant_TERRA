#!/bin/bash

# Program
SRA_prefetch="/opt/ohpc/Taiwania3/pkg/biology/SRAToolkit/sratoolkit_v2.11.1/bin/prefetch"

# User vars
SRRID_file=$1
outDIR=$2

# Download
while read line
do
$SRA_prefetch ${line} -o ${outDIR}/${line}.sra &
done < $SRRID_file

