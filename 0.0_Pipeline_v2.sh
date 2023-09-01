#!/bin/bash

# SLURM setting
partition=92
memory=92
ncore=14

## User varibles
expID=$1

## Please change the workdir!
workdir=../

## TERRA quantification region files
qRegion=/staging/biology/ls807terra/0_bedfiles/hTERRA/CHM13_TERRA_region_v6.bed
qGTF=/staging/biology/ls807terra/0_genomes/genome_gtf/CHM13/CHM13_v2.0_add_TERRA_region_v6.gtf
cytoband=/staging/biology/ls807terra/0_bedfiles/hTERRA/chm13v2.0_cytobands_allchrs_Add_TERRA_v3.bed

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


## Run fastq-dump
mkFolder fastq # create folder
jid_fqdump=$(sbatch\
 -A MST109178\
 -p ngs${partition}G\
 -J fq-dump_$expID\
 -o reports/fq-dump_$expID.o.txt\
 -e reports/fq-dump_$expID.e.txt\
 -c $ncore --mem=${memory}g\
 0_SRA_dump.sh ${workdir}/SRA/${expID}.sra ${workdir}/fastq)

# Gather read files (Incude file path)
fq_path=${workdir}/fastq
reads_file=$(echo $(ls $fq_path | grep $expID))

# Split the read_list into an array
IFS=' ' read -ra READS <<< "$reads_file"
ReadN=${#READS[@]}

# Full file path
if [ $ReadN -eq 2 ]; then
fastq_file=$(echo ${READS[@]} | awk -v pth=$fq_path '{print pth "/" $1 "," pth "/" $2}')
elif [ $ReadN -eq 1 ]; then
fastq_file=$(echo ${READS[@]} | awk -v pth=$fq_path '{print pth "/" $1}')
fi

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
 1_trimQC.sh $expID $workdir/trimed_fq $fastq_file $ncore)

## Run STAR alignment************
mkFolder STAR_align # create folder
if [ $ReadN -eq 2 ]
then
jid_STAR=$(sbatch\
 -A MST109178\
 -p ngs${partition}G\
 -J align_$expID\
 -o reports/align_$expID.o.txt\
 -e reports/align_$expID.e.txt\
 -c $ncore --mem=${memory}g\
 --dependency=afterok:${jid_Trim/"Submitted batch job "/}\
 2_STAR_align.sh\
 $workdir/trimed_fq/$expID/*1.fq.gz,$workdir/trimed_fq/$expID/*2.fq.gz\
 $ncore $workdir/STAR_align/$expID)
elif [ $ReadN -eq 1 ]
then
jid_STAR=$(sbatch\
 -A MST109178\
 -p ngs${partition}G\
 -J align_$expID\
 -o reports/align_$expID.o.txt\
 -e reports/align_$expID.e.txt\
 -c $ncore --mem=${memory}g\
 --dependency=afterok:${jid_Trim/"Submitted batch job "/}\
 2_STAR_align.sh\
 $workdir/trimed_fq/$expID/*trimmed.fq.gz\
 $ncore $workdir/STAR_align/$expID)
fi

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
 3_bamcoverage.sh\
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
 4_HTseq_count.sh\
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
 5_telomereHunter_v2.sh $cytoband \
 $workdir/STAR_align/$expID*.bam $expID $workdir/telomereHunter)

## Report
echo Pipeline sent at $(date "+%Y-%m-%d %H:%M:%S")

