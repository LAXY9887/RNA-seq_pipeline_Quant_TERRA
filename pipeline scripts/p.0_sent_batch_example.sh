#!/bin/bash

## Select pipeline
pipline=0.0_ps_Pipeline_v4.sh

## User varibles (Example)
expID=SRR3304509

# Configure
sh 0_Configure_Setting.sh c.0_RNAseq_QuantTERRA.cfg

# Sent pipeline
sh $pipline $expID

