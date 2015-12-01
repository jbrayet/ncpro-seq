# Copyleft ↄ⃝ 2012 Institut Curie
# Author(s): Jocelyn Brayet, Laurene Syx, Chongjian Chen, Nicolas Servant(Institut Curie) 2012 - 2015
# Contact: bioinfo.ncproseq@curie.fr
# This software is distributed without any guarantee under the terms of the GNU General
# Public License, either Version 2, June 1991 or Version 3, June 2007.

rm(list=ls())
require(ggplot2)
require(reshape2)
require(RColorBrewer)

## were additional arguments to R CMD BATCH given ?
args <- commandArgs(TRUE)
la <- length(args)
if (la > 0){
  for (i in 1:la)
    eval(parse(text=args[[i]]))
}

## read mapping stat table
#len.matrix <- read.table(lenFile,header=T,check.names=FALSE)

len.matrix <- read.table(lenFile,header=T,check.names=FALSE, row.names=1)

## get mapping info

##len.perc <- 100*len.matrix[,-1]/matrix(colSums(len.matrix[,-1]),ncol=ncol(len.matrix[,-1]), nrow=nrow(len.matrix[,-1]),byrow=TRUE)
##len.perc <- cbind(len.matrix[1],len.perc)
##colnames(len.perc) <- c("idx",colnames(len.matrix)[-1])

len.perc <- 100*len.matrix/matrix(colSums(len.matrix),ncol=ncol(len.matrix), nrow=nrow(len.matrix),byrow=TRUE)
len.perc <- cbind(as.numeric(rownames(len.matrix)),len.perc)

colnames(len.perc) <- c("idx",colnames(len.matrix))
len.size <- len.perc[,1]
max.perc <- max(len.perc[,-1])

## table transformation to ggplot

len.perc.ggplot <- melt(len.perc, id = "idx")
len.perc.ggplot <- len.perc.ggplot[order(len.perc.ggplot$idx),]

mypalette<-colorRampPalette(brewer.pal(8,"Set1"))(ncol(len.matrix))

## get graph type

if (type=="distinct"){
  xl <- "Distinct reads length [nt]"
}else{
  xl <- "Reads length [nt]"
}

## draw

plot.save <- ggplot(len.perc.ggplot, aes(x=idx, y=value, colour=variable))+ geom_line() + geom_point() + theme_bw() + theme(axis.title=element_text(face="bold")) + xlab(xl) + ylab("Percentage of reads") + xlim(len.size[1],len.size[length(len.size)]) + ylim(0,max.perc) + scale_colour_manual(values=mypalette) + guides(color=guide_legend(title="Samples"))
ggsave(filename=figFile, plot=plot.save, width=7, height=5)
