#!Rscript --vanilla --verbose

url <- 'https://cran.csie.ntu.edu.tw/'

## Install R package
install.packages("ggplot2", repos=url)
install.packages("reshape2", repos=url)
install.packages("gridExtra", repos=url)
install.packages("cowplot", repos=url)
install.packages("svglite", repos=url)
install.packages("dplyr", repos=url)

# load package
library("ggplot2")
library("reshape2")
library("gridExtra")
library("cowplot")
library("svglite")
library("dplyr")

