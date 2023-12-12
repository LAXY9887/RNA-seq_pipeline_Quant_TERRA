#!/staging/biology/ls807terra/0_Programs/anaconda3/envs/RNAseq_quantTERRA/bin/Rscript

## Options
pacman::p_load("optparse")

option_list = list(
  make_option(c("-c", "--counts"), type="character", default=NULL,
              help="Enter a directory that contains count files.", metavar="COUNTS"),
  make_option(c("-o", "--output"), type="character", default="./raw_counts_table",
              help="Specify a output count table file. [default= %default]", metavar="OUTPUT"),
  make_option(c("-f", "--format"), type="character", default="csv",
              help="Specify output file format. Possible: csv xlsx [default= %default]", metavar="FORMAT"),
  make_option(c("-k", "--keyword"), type="character", default=".count",
              help="If the count files did not name as *.count*, specify a common name of those count files. 
		    Example: .txt [default= %default]", metavar="KEYWORD"),
  make_option(c("-d", "--removeRow"), type="character", default="__",
              help="Specify a pattern to remove from gene list. 
		    For example, hTseq-count output contains summary information within the count list, 
		    which should be removed. If you don't want to remove anything, please specify -x [default= %default]", metavar="REMOVE"),
  make_option(c("-x", "--noRemove"), action="store_true", default=FALSE,
              help="Do not remove anything from the gene column.", metavar="NO_REMOVE")
)

opt_parser = OptionParser(option_list=option_list)
opt = parse_args(opt_parser)

# Option validator
if (is.null(opt$counts)){
  print_help(opt_parser)
  stop("Please Enter at least -c option: -c count_path/", call.=FALSE)
}
if (opt$format != "csv" & opt$format != "xlsx"){
  stop("Output format only support csv or xlsx", call.=FALSE)
}

## Loading packages
pacman::p_load(rio)

## Loading files
countDir <- opt$counts
files <- paste0(countDir,"/",grep(opt$keyword,list.files(countDir),value = T))

## Making dataFrame & clean up data
counts.df <- import(files[1],format = "csv")
if (!opt$noRemove){
  remove_idx <- grep(opt$removeRow, counts.df$V1)
}

## Load count data
my_import <- function(file){
  return(import(file,format = "csv"))
}
counts.df <- lapply(files, my_import)
counts.df <- data.frame(counts.df)
select_i <- seq(0,ncol(counts.df),by = 2)
if (!opt$noRemove){
  counts.df <- counts.df[-remove_idx,c(1,select_i)]
} else {
  counts.df <- counts.df[,c(1,select_i)]
}

## Rename column
strip_dot <- function(name){
  new_name <- unlist(strsplit(name, "\\."))[1]
  return(new_name)
}
re_col <- c("Gene",grep(opt$keyword,list.files(countDir),value = T))
re_col <- unlist(lapply(re_col,strip_dot))
colnames(counts.df) <- re_col

## Export raw counts table
export(counts.df,opt$output,format = opt$format)

