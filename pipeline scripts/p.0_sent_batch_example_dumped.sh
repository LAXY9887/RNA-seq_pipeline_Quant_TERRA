#!/bin/bash

## Select pipeline
pipline=0.0_ps_Pipeline_v4.sh

## User varibles (Example)
expID=TERRAPCR-4_22HMN2LT3
fastqDIR=/staging/biology/ls807terra/0_fastq/22thlane_TERRA

# Configure
sh 0_Configure_Setting.sh c.0_RNAseq_QuantTERRA.cfg

# Sent pipeline
sh $pipline $expID is-dump $fastqDIR

