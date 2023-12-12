#!/staging/biology/ls807terra/0_Programs/anaconda3/envs/RNAseq_quantTERRA/bin/Rscript

# This script normalized counts by YARN package.

## Options
pacman::p_load("optparse")

option_list = list(
  make_option(c("-i", "--countFile"), type="character", default=NULL,
              help="Enter a count table file.", metavar="COUNTS"),
  make_option(c("-T", "--TERRAcountFile"), type="character", default=NULL,
              help="Enter a TERRA count table file.", metavar="TERRA-COUNTS"),
  make_option(c("-a", "--annotation"), type="character", default=NULL,
              help="Enter a sample annotation table,", metavar="ANNOTATION"),
  make_option(c("-O", "--outputDIR"), type="character", default="./",
              help="Enter a output directory. [default = %default]", metavar="OUT PATH"),
  make_option(c("-k", "--target"), type="character", default=NULL,
              help="Please specify the normalization target, it must be one of column names!", metavar="TARGET")
)

opt_parser = OptionParser(option_list=option_list)
opt = parse_args(opt_parser)

# Option validator
if (is.null(opt$countFile)){
  print_help(opt_parser)
  stop("Please Enter -i option: -i count_table.csv", call.=FALSE)
}
if (is.null(opt$TERRAcountFile)){
  print_help(opt_parser)
  stop("Please Enter -T option: -T TERRA_count_table.csv", call.=FALSE)
}
if (is.null(opt$annotation)){
  print_help(opt_parser)
  stop("Please Enter -a option: -a annotation_table.csv (.xlsx)", call.=FALSE)
}
if (is.null(opt$target)){
  print_help(opt_parser)
  stop("Please Enter -k option: -k target-column-name", call.=FALSE)
}

# install packages
# BiocManager::install('yarn')
# BiocManager::install("Biobase")

# load package
library("Biobase")
library("yarn")
pacman::p_load(rio)

# User variables
expression_table <- opt$countFile
TERRA_count_table <- opt$TERRAcountFile
annotation_table <- opt$annotation
outDir <- opt$outputDIR
normalize_target <- opt$target

## Step1: Build Expression Dataset
# load count table
exprsFile <- expression_table
counts <- as.matrix(
  read.table(exprsFile, header=TRUE, sep=",",row.names=1,as.is=TRUE)
)

# load sample annotation
annoFile <- annotation_table
annotation <- import(annoFile)
rownames(annotation) <- annotation$Sample
summary(annotation)
head(annotation)

# Rank matrix as Annotation
rankMatrix <- function(mat,annotation.df){
  t_mat <- t(mat)
  t_mat <- t_mat[rownames(annotation),]
  return(t(t_mat))
}
counts <- rankMatrix(counts,annotation)

# Check whether the sequence of exprs and annotaion is the same
Check_arrange <- all(rownames(annotation)==colnames(counts))
checkpoint <- ifelse(Check_arrange,yes="Pass",no ="Fail")
print(paste0("Check sample arrange in annotation file:",checkpoint))

# Build meta data to describe annotation
metadata <- data.frame(
  labelDescription=colnames(annotation),
  row.names=colnames(annotation)
)

# Create an Object of Annotation
AnnoData <- new("AnnotatedDataFrame",data=annotation, varMetadata=metadata)

# Create ExpressionSet
EXPSet <- ExpressionSet(assayData=counts,phenoData=AnnoData)

## Step2: Run YARN
# Filter genes < CPM threshold
EXPSet_filtered = filterLowGenes(EXPSet,normalize_target)

# Check how many genes were filtered out
dim(EXPSet)
dim(EXPSet_filtered)

# Plot density before and after filtering
png(paste0(outDir,"/No filter.png"))
plotDensity(EXPSet,normalize_target,main=paste(normalize_target,"No filter"))
dev.off()
png(paste0(outDir,"/filtered.png"))
plotDensity(EXPSet_filtered,normalize_target,main=paste(normalize_target,"filtered"))
dev.off()

# Export Filtered count table
filtered.mat <- exprs(EXPSet_filtered)
filtered.df <- data.frame(Gene = rownames(filtered.mat),filtered.mat)
export(filtered.df,paste0(outDir,"/","YARN_filter_lowExpr_WholeGene_counts.csv"),format = "csv")

# Open TERRA counts and combine into filtered table
TERRA_mat <- as.matrix(
  read.table(TERRA_count_table, header=TRUE, sep=",",row.names=1,as.is=TRUE)
)
TERRA_mat <- rankMatrix(TERRA_mat,annotation)

# Combine TERRA count table
Count_add_TERRA.mat <- rbind(TERRA_mat,filtered.mat)
combine.df <- data.frame(
  "Region" = rownames(Count_add_TERRA.mat),
  Count_add_TERRA.mat
)
export(combine.df,paste0(outDir,"/","YARN_filter_lowExpr_WholeGene_counts_with_TERRA.csv"),format = "csv")

# Create new ExpressionSet
filtered_EXPSet_with_TER <- ExpressionSet(assayData=Count_add_TERRA.mat,phenoData=AnnoData)

# Normalize by normalizeTissueAware()
normalized_EXPSet_with_TER <- normalizeTissueAware(filtered_EXPSet_with_TER,normalize_target,normalizationMethod = "qsmooth")
png(paste0(outDir,"/Normalized.png"))
plotDensity(normalized_EXPSet_with_TER,normalize_target,normalized=TRUE,main=paste(normalize_target,"Normalized"))
dev.off()

# Get Tissue normalized counts
norm.mat <- normalized_EXPSet_with_TER@assayData$normalizedMatrix
norm.df <- data.frame(Gene = rownames(norm.mat),norm.mat)
export(norm.df,paste0(outDir,"/","YARN_normalized_count_withTERRA.csv"),format = "csv")

# Get normalized TERRA counts
TERRA.norm.df <- norm.df[grep("TERRA_",norm.df$Gene),]
export(TERRA.norm.df,paste0(outDir,"/","YARN_normalized_TERRA_count.csv"),format = "csv")
