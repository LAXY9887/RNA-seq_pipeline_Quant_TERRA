#!/bin/bash

# SLURM setting
partition=53
memory=53
ncore=8

## User varibles
expID=$1
isDump=$2
fqPath=$3

## Please change the workdir in configure file!
workdir="../"

## TERRA quantification region files
qRegion="/staging/biology/ls807terra/0_bedfiles/hTERRA/CHM13_TERRA_region_v6.bed"
qGTF="/staging/biology/ls807terra/0_genomes/genome_gtf/CHM13/CHM13_v2.0.gtf"
cytoband="/staging/biology/ls807terra/0_bedfiles/hTERRA/chm13v2.0_cytobands_allchrs_Add_TERRA_v3.bed"
teloSeq_ref="./s.teloseq_v2.fa"

## A function to create folder
function mkFolder(){
folder_name=$1
if [ ! -d $workdir/$folder_name ]
then
mkdir $workdir/$folder_name
fi
}

## Create reports folder
if [ ! -d reports ]
then
mkdir reports
fi

## Check if expID was provided.
RED='\033[0;31m'
NC='\033[0m' # No Color
if [ -z $expID ]; then
 echo -e "${RED}Error:${NC} Please provide sample id!"
 exit 1
fi

## Check if need to perform fastq-dump
check_dump="not-dump"
if [ ! -z $isDump ]; then
 if [ $isDump == "is-dump" ]; then
  check_dump="dumped"
 else
  echo -e "${RED}Warning:${NC} is-dump flag was set, it must be 'is-dump' !"
  echo -e "${RED}Warning:${NC} Process was terminated!"
  exit 1
 fi
fi

## Check if fastq directory is set when isDump
fastqDIR=${workdir}/fastq
if [ $check_dump == "dumped" ] ; then
 if [ -z $fqPath ]; then
  echo -e "${RED}Error:${NC} is-dump flag was set but fastq path was not provided!"
  exit 1
 else
  fastqDIR=$fqPath
 fi
fi

## Check if need to perform fastq-dump
if [ $check_dump == "not-dump" ] ; then
 ## Run fastq-dump
 mkFolder fastq # create folder
 jid_fqdump=$(sbatch\
  -A MST109178\
  -p ngs${partition}G\
  -J fq-dump_$expID\
  -o reports/fq-dump_$expID.o.txt\
  -e reports/fq-dump_$expID.e.txt\
  -c $ncore --mem=${memory}g\
  0_ps_SRA_dump.sh ${workdir}/SRA/${expID}.sra ${workdir}/fastq)

 ## Run Trimgalore
 mkFolder trimed_fq # create folder
 jid_Trim=$(sbatch\
  -A MST109178\
  -p ngs${partition}G\
  -J trim_$expID\
  -o reports/trim_$expID.o.txt\
  -e reports/trim_$expID.e.txt\
  -c $ncore --mem=${memory}g\
  --dependency=afterok:${jid_fqdump/"Submitted batch job "/}\
  1_ps_trimQC.sh $expID $workdir/trimed_fq $fastqDIR $ncore)
else
 mkFolder trimed_fq # create folder
 jid_Trim=$(sbatch\
  -A MST109178\
  -p ngs${partition}G\
  -J trim_$expID\
  -o reports/trim_$expID.o.txt\
  -e reports/trim_$expID.e.txt\
  -c $ncore --mem=${memory}g\
  1_ps_trimQC.sh $expID $workdir/trimed_fq $fastqDIR $ncore)
fi

## Run STAR alignment************
mkFolder STAR_align # create folder
jid_STAR=$(sbatch\
 -A MST109178\
 -p ngs${partition}G\
 -J align_$expID\
 -o reports/align_$expID.o.txt\
 -e reports/align_$expID.e.txt\
 -c $ncore --mem=${memory}g\
 --dependency=afterok:${jid_Trim/"Submitted batch job "/}\
 2_ps_STAR_align.sh\
 $workdir/trimed_fq/$expID $ncore $workdir/STAR_align/$expID)

## Run bamcoverage alignment
mkFolder bamcoverage # create folder
jid_Bamcov=$(sbatch\
 -A MST109178\
 -p ngs${partition}G\
 -J bamcov_$expID\
 -o reports/bamcov_$expID.o.txt\
 -e reports/bamcov_$expID.e.txt\
 -c $ncore --mem=${memory}g\
 --dependency=afterok:${jid_STAR/"Submitted batch job "/}\
 3_ps_bamcoverage.sh\
 $workdir/STAR_align/$expID*.bam $ncore $workdir/bamcoverage $expID)

## Run HTseq-count
mkFolder HTseq_count # create folder
jid_HTseq=$(sbatch\
 -A MST109178\
 -p ngs${partition}G\
 -J HTseq_$expID\
 -o reports/HTseq_$expID.o.txt\
 -e reports/HTseq_$expID.e.txt\
 -c $ncore --mem=${memory}g\
 --dependency=afterok:${jid_STAR/"Submitted batch job "/}\
 4_ps_HTseq_count.sh\
 $workdir/STAR_align/$expID*.bam $qGTF $ncore $workdir/HTseq_count/$expID.count.txt)

## Run telomere_hunter
mkFolder telomereHunter
jid_TH=$(sbatch\
 -A MST109178\
 -p ngs${partition}G\
 -J telomereHunter_$expID\
 -o reports/telomereHunter_$expID.o.txt\
 -e reports/telomereHunter_$expID.e.txt\
 -c $ncore --mem=${memory}g\
 --dependency=afterok:${jid_STAR/"Submitted batch job "/}\
 5_ps_telomereHunter_v2.sh $cytoband \
 $workdir/STAR_align/$expID*.bam $expID $workdir/telomereHunter)

## Run BBduk for telomeric repeat contents
mkFolder bbduk_telo
jid_BBduk=$(sbatch\
 -A MST109178\
 -p ngs${partition}G\
 -J bbduk_telo_$expID\
 -o reports/bbduk_telo_$expID.o.txt\
 -e reports/bbduk_telo_$expID.e.txt\
 -c $ncore --mem=${memory}g\
 --dependency=afterok:${jid_Trim/"Submitted batch job "/}\
 7_ps_bbduk_telo_contents.sh $expID $workdir/bbduk_telo $workdir/trimed_fq/${expID} $teloSeq_ref $ncore)

## Report
CYAN='\033[0;36m'
echo -e ${CYAN}Pipeline sent at${NC} $(date "+%Y-%m-%d %H:%M:%S")

