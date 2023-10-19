#!/bin/bash
#SBATCH -A MST109178
#SBATCH -J BAM_merge
#SBATCH -p ngs92G
#SBATCH -c 14
#SBATCH --mem=92g
#SBATCH -o ./reports/bw_merge.out.txt
#SBATCH -e ./reports/bw_merge_err.txt

# Software
bamtool="/staging/biology/ls807terra/0_Programs/bamtools/build/bin/bamtools"

# User vars
BAM_list=$1
output=$2

# Program
$bamtool merge -list $BAM_list -out $2

