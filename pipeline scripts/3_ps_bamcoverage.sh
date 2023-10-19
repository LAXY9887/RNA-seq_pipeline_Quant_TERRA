#!/bin/bash

## Software
bamcoverage="/opt/ohpc/Taiwania3/pkg/biology/deepTools/deepTools_v3.3.1/bin/bamCoverage"
bigwig2bdg="/staging/biology/ls807terra/0_Programs/UCSC_tools/bigWigToBedGraph"

## Inputs
BAM=$1

## User variables
ncore=$2
outdir=$3
expID=$4

# Do once without strand
$bamcoverage \
 -b $BAM \
 --normalizeUsing RPKM \
 -p $ncore \
 -o ${outdir}/${expID}.RPKM.strless.bigwig \
 -of bigwig

# Do this with stranded settings
for s in forward reverse
do
$bamcoverage \
 -b $BAM \
 --filterRNAstrand ${s} \
 --normalizeUsing RPKM \
 -p $ncore \
 -o ${outdir}/${expID}.RPKM.${s}.bigwig \
 -of bigwig
done 

# Bigwig to bedgraph
$bigwig2bdg ${outdir}/${expID}.RPKM.strless.bigwig ${outdir}/${expID}.RPKM.strless.bedgraph
