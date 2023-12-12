#!/bin/bash
#SBATCH -A MST109178
#SBATCH -J YARN
#SBATCH -p ngs186G
#SBATCH -c 28
#SBATCH --mem=186g
#SBATCH -o YARN_out.txt
#SBATCH -e YARN_err.txt

# Step1. Summary counts in a table.
./01_summaryCounts.R -c ../counts/ -o ../meta/raw_counts_table.csv 
./01_summaryCounts.R -x -c ../TH_counts/ -o ../meta/TERRA_counts_table.csv

# Step2. Normalize count by YARN
./02_YARN_normalize_with_TERRA.R \
 -i ../meta/raw_counts_table.csv \
 -T ../meta/TERRA_counts_table.csv \
 -a ../meta/HGPS_annotation.xlsx \
 -O ../results/ \
 -k Condition

# Step3. Plot heatmap
./03_plotHeatmap.R \
 -m ../results/YARN_normalized_TERRA_count.csv \
 -a ../meta/HGPS_annotation.xlsx \
 -O ../results/ \
 -k Condition,Age \
 -s 800,800

