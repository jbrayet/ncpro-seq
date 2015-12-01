# Copyleft ↄ⃝ 2012 Institut Curie
# Author(s): Jocelyn Brayet, Laurene Syx, Chongjian Chen, Nicolas Servant(Institut Curie) 2012 - 2015
# Contact: bioinfo.ncproseq@curie.fr
# This software is distributed without any guarantee under the terms of the GNU General
# Public License, either Version 2, June 1991 or Version 3, June 2007.

rm(list=ls())
library("gplots")

### were additional arguments to R CMD BATCH given ?
args <- commandArgs(TRUE)
la <- length(args)
if (la > 0){
  for (i in 1:la)
    eval(parse(text=args[[i]]))
}

### 

genes.selection <- function (data, thres.diff, thres.num, probs = 0.25){

    if (missing(thres.diff) && missing(thres.num)) {
        stop("** Stop. No method found.")
    }

    if (!missing(thres.diff) && !missing(thres.num)) {
        stop("** Stop. Choose one of the two options - thres.diff or thres.num")
    }

    diff.quantile <- function(x, probs = 1/length(x)) {
        vv <- quantile(x, probs = c(probs, 1 - probs), na.rm = TRUE)
        return(vv[2] - vv[1])
    }

    rangeValues <- apply(data, 1, diff.quantile, probs = probs)

    if (!missing(thres.diff)) {
        ind <- which(rangeValues >= thres.diff)
        genesList <- rownames(data[ind, ])
    }

    else if (!missing(thres.num)) {
        genesList <- names(sort(rangeValues, decreasing = TRUE)[1:thres.num])
    }

    return(genesList)
}


## read subfam rpm table

fam.rpm <- read.table(subFam,header=T,row.names=1,stringsAsFactors=FALSE)
fam.matrix <- data.matrix(fam.rpm)
nsample <- ncol(fam.matrix)
sel.row.idx <- c()

dist2 <- function(x)
  dist(x, method="euclidean")
	
hclust2 <- function(x)
  hclust(x,method="ward")

if((nsample>=2) && (nrow(fam.matrix)>=2)){

    for(i in 1:nsample){
        cur.rpm <- fam.matrix[,i]
        sort.rpm <- sort(cur.rpm, index.return=TRUE, decreasing=TRUE)
        #cur.sel.row.idx <- sort.rpm$ix[1:selNum]
        #cur.sel.row.idx <- cur.sel.row.idx[!is.na(cur.sel.row.idx)]
        #sel.row.idx <- unique(c(sel.row.idx,cur.sel.row.idx))
    }

	if(length(fam.matrix[,1]) > 50) {

		sel<-genes.selection(fam.matrix[1:length(fam.matrix[,1]),], thres.num=50)

	}
	else {

		sel<-genes.selection(fam.matrix[1:length(fam.matrix[,1]),], thres.num=(length(fam.matrix[,1])))

	}
	
    
    if(length(sel)>1){

	fam.matrix.sel <- fam.matrix[sel,]
      # fam.matrix.sel <- as.matrix(fam.matrix[sel.row.idx,], nrow=length(sel.row.idx), ncol=ncol(fam.matrix))

        famFig <- paste(figDir,"/",ncFam,"_top_exp_heatmap.png",sep="")
        png(famFig,units="in", res=300, height=8, width=8)

	# heatmap.2(fam.matrix.sel, col = redgreen(75), key=TRUE, trace="none", symkey=FALSE, density.info="none", margins=c(5,10), scale="column", distfun=dist2, hclustfun=hclust2)

	heatmap.2(fam.matrix.sel, col = redgreen(75),trace="none", margins=c(5,15), distfun=dist2, hclustfun=hclust2)

        dev.off()
    }
}
