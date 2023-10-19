#!/bin/bash

# Software and settings
telomerehunter="/staging/biology/ls807terra/0_Programs/anaconda3/envs/telomereHunter/bin/telomerehunter"

# User vars
cytoband=$1
tBAM=$2
expID=$3
outDIR=$4

# -ibt sorted BAM with index .bai in the same folder
# -p Name prefix
# -o Outdir
# -b Cytoband bed file, this can be modified!
# -pl : To use multi-threads
# -rt 4 -rl : search at least 4x repeats in a read

# Program
$telomerehunter -ibt ${tBAM} -p ${expID} -o ${outDIR} -b ${cytoband} -pl -rt 4 -rl -mqt 1

# summary TERRA counts
grep 'TERRA_chr' ${outDIR}/${expID}/tumor_TelomerCnt_*/*readcount.tsv | awk '{print $2"\t"$3}' \
 > ${outDIR}/${expID}/${expID}_TERRA_region_TH_count.tab
