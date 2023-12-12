#!/staging/biology/ls807terra/0_Programs/anaconda3/envs/RNAseq_quantTERRA/bin/Rscript

# This script plot expression heatmap

## Options
pacman::p_load("optparse")

option_list = list(
  make_option(c("-m", "--matrix"), type="character", default=NULL,
              help="Specify a expression table for plotting heatmap.", metavar="MATRIX"),
  make_option(c("-a", "--annotation"), type="character", default=NULL,
              help="Specify a sample annotation table.", metavar="ANNOTATION"),
  make_option(c("-O", "--outputDIR"), type="character", default="./",
              help="Specify a output directory. [default= %default]", metavar="OUTPUT-PATH"),
  make_option(c("-k", "--keywords"), type="character", default=NULL,
              help="Choose which columns in the annotation should be plotted on the heatmap.
		    Separate by comma if there is multiple keywords.
                    Example1: Condition ; Example2: Condition,Age", metavar="KEYWORDS"),
  make_option(c("-s", "--heatmapSize"), type="character", default="800,800",
              help="Adjust heatmap size, enter by this format: width,heigh
		    Two integer sepatated by comma. Example: 600,600
		    [default= %default]", metavar="SIZE")
)

opt_parser = OptionParser(option_list=option_list)
opt = parse_args(opt_parser)

# Option validator
if (is.null(opt$matrix)){
  print_help(opt_parser)
  stop("Please Enter expression table -m option: -m expression_table.csv", call.=FALSE)
}
if (is.null(opt$annotation)){
  print_help(opt_parser)
  stop("Please Enter annotation table -a option: -a annotation_table.csv", call.=FALSE)
}

## Load packages
pacman::p_load(rio,RColorBrewer,pheatmap,Hmisc,dplyr,ggplot2,tidyr,viridis)

## User variables
normalized_TERRA_count <- opt$matrix
sample_annotation_table <- opt$annotation
HeatmapOutputDIR <- opt$outputDIR
anno_keywords <- opt$keywords

# Handle heatmap size
input.size <- unlist(strsplit(opt$heatmapSize,","))
map_size.w <- as.integer(input.size[1])
map_size.h <- as.integer(input.size[2])

## Load normalized count data
data.df <- import(normalized_TERRA_count)
data.mat <- as.matrix(data.df[,-c(1)])
row.names(data.mat) <- data.df[,1]
data.mat <- type.convert(data.mat,numerals = "allow.loss",as.is = T)

## heatmap annotation: sample
sample_Annotation <- import(sample_annotation_table)
rownames(sample_Annotation) <- sample_Annotation[,1]

# Rank matrix as Annotation
rankMatrix <- function(mat,annotation.df){
  t_mat <- t(mat)
  t_mat <- t_mat[rownames(annotation.df),]
  return(t(t_mat))
}
data.mat <- rankMatrix(data.mat,sample_Annotation)

## Check point
# Check whether the sequence of data.mat and annotaion is the same
Check_arrange <- all(rownames(sample_Annotation)==colnames(data.mat))
checkpoint <- ifelse(Check_arrange,yes="Pass",no ="Fail")
print(paste0("Check sample arrange in annotation file:",checkpoint))

# Make colors
makeColors <- function(target){
  components <- unique(sample_Annotation[,target])
  if (length(components) > 10 & typeof(components) != "character"){
    ann.colr <- gray.colors(length(components),start = 1, end = 0)
  }
  else{
    ann.colr <- rainbow(length(components))
  }
  
  names(ann.colr) <- components
  return(ann.colr)
}

# Select which columns will be annotated
if (!is.null(anno_keywords)){
  
  # Handle input keywords
  targetList <- unlist(strsplit(anno_keywords,","))

  # Make colors for annotation
  anno.colr.list <- sapply(targetList, makeColors)

  # Select specific annotations
  selected_annotation <- data.frame(
    sample_Annotation[,targetList]
  )
  colnames(selected_annotation) <- targetList
  rownames(selected_annotation) <- rownames(sample_Annotation)

} else {

  selected_annotation <- NULL
  anno.colr.list <- NULL

}
# This script refine tree on the heatmap
# -----------------------------------------------------------------------------#
draw_dendrogram <- function(hc, gaps, horizontal = T) {
  # Define equal-length branches
  hc$height <- cumsum(rep(1/length(hc$height), length(hc$height)))
  h = hc$height/max(hc$height)/1.05
  m = hc$merge
  o = hc$order
  n = length(o)
  m[m > 0] = n + m[m > 0]
  m[m < 0] = abs(m[m < 0])
  dist = matrix(0, nrow = 2 * n - 1, ncol = 2, dimnames = list(NULL, 
                                                               c("x", "y")))
  dist[1:n, 1] = 1/n/2 + (1/n) * (match(1:n, o) - 1)
  for (i in 1:nrow(m)) {
    dist[n + i, 1] = (dist[m[i, 1], 1] + dist[m[i, 2], 1])/2
    dist[n + i, 2] = h[i]
  }
  draw_connection = function(x1, x2, y1, y2, y) {
    res = list(x = c(x1, x1, x2, x2), y = c(y1, y, y, y2))
    return(res)
  }
  x = rep(NA, nrow(m) * 4)
  y = rep(NA, nrow(m) * 4)
  id = rep(1:nrow(m), rep(4, nrow(m)))
  for (i in 1:nrow(m)) {
    c = draw_connection(dist[m[i, 1], 1], dist[m[i, 2], 1], 
                        dist[m[i, 1], 2], dist[m[i, 2], 2], h[i])
    k = (i - 1) * 4 + 1
    x[k:(k + 3)] = c$x
    y[k:(k + 3)] = c$y
  }
  x = pheatmap:::find_coordinates(n, gaps, x * n)$coord
  y = unit(y, "npc")
  if (!horizontal) {
    a = x
    x = unit(1, "npc") - y
    y = unit(1, "npc") - a
  }
  res = grid::polylineGrob(x = x, y = y, id = id)
  return(res)
}
# Replace the non-exported function `draw_dendrogram` in `pheatmap`:
assignInNamespace(x="draw_dendrogram", value=draw_dendrogram, ns="pheatmap")
# -----------------------------------------------------------------------------#

# heatmap breaks
heatmap_breaks <- c(seq(min(data.mat),max(data.mat)/1.5,0.1))
heatmap_color_gradient <- inferno(length(heatmap_breaks))

# Calculate Heatmap and cell size (px)
heatmap_width <- map_size.w
heatmap_height <- map_size.h
cell_width <- heatmap_width / ncol(data.mat)
cell_height <- heatmap_height / nrow(data.mat)

# export pdf
pdf(
  file = paste0(HeatmapOutputDIR,"/expr_heatmap.pdf"),
  width = 16, height = 16,
  colormodel = "cmyk"
)

# plot heatmap
pheatmap(
  # Input matrix
  mat = data.mat,
  
  # Style
  main = "Expression heatmap" ,
  fontsize = 12,
  fontsize_row = 12,
  fontsize_col = 12,
  cellwidth = cell_width,
  cellheight = cell_height,
  border_color = NA,
  color = heatmap_color_gradient,
  breaks = heatmap_breaks,
  
  # Annotation
  annotation_col = selected_annotation,
  annotation_colors = anno.colr.list,
  show_rownames = T, 
  show_colnames = F,
  
  # Clustering
  clustering_method =  "ward.D2",
  cluster_rows = T,
  cluster_cols = F
  # (options :"ward.D", "ward.D2", "single", "complete", "average", "mcquitty", "median" or "centroid".)
  # https://www.rdocumentation.org/packages/stats/versions/3.6.2/topics/hclust
)

dev.off()

