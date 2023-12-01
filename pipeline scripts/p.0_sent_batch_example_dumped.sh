#!/bin/bash

## Select pipeline
pipline=0.0_ps_Pipeline_v4.sh

## User varibles (Example)
expID=SRR3304509
fastqDIR=../fastq

# Sent pipeline
$pipline $expID is-dump $fastqDIR

