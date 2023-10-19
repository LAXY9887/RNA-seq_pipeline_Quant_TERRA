#!/bin/bash
#SBATCH -A MST109178
#SBATCH -J BAM_merge
#SBATCH -p ngs92G
#SBATCH -c 14
#SBATCH --mem=92g
#SBATCH -o ./reports/mergeBamC.out.txt
#SBATCH -e ./reports/mergeBamC_err.txt

# Software
samtool="/opt/ohpc/Taiwania3/pkg/biology/SAMTOOLS/SAMTOOLS_v1.13/bin/samtools"
bamcoverage="/opt/ohpc/Taiwania3/pkg/biology/deepTools/deepTools_v3.3.1/bin/bamCoverage"

# User vars
mergeBAM=$1
outDir=$2

# Program
$samtool sort -@ 14 ${mergeBAM} -o ${mergeBAM/.bam/.sorted.bam}
$samtool index -@ 14 ${mergeBAM/.bam/.sorted.bam}

for s in forward reverse
do
$bamcoverage -b ${mergeBAM/.bam/.sorted.bam} --filterRNAstrand $s --binSize 30 -p 14 --normalizeUsing RPKM --skipNAs \
 -o ${outDir}/$(basename ${mergeBAM/.bam/}).RPKM.${s}.bw
done

