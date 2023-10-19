#!Rscript --vanilla --verbose

url <- 'https://cran.csie.ntu.edu.tw/'

## Install R package
install.packages("xml2", repos=url)
install.packages("BiocManager", repos=url)
install.packages("devtools", repos=url)
install.packages("pacman", repos=url)
BiocManager::install("Biobase")
BiocManager::install('yarn')
BiocManager::install("DESeq2")
BiocManager::install("apeglm")

## Download grch38 reference anno.tables
devtools::install_github("stephenturner/annotables")

## Install & Load packages by pacman
pacman::p_load(
  rio,RColorBrewer,pheatmap,Hmisc,dplyr,ggplot2,tidyr,viridis,DEGreport,
  gage,gageData,biomaRt,DBI,annotables,org.Hs.eg.db,DOSE,pathview,enrichplot,
  clusterProfiler, AnnotationHub,ensembldb,tidyverse,ggnewscale
)

# load package
library("Biobase")
library("yarn")
library("DESeq2")
