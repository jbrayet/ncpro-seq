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

gc.matrix <- read.table(gcFile,header=T,check.names=FALSE)

## get mapping info

gc.size <- gc.matrix[,1]

## table transformation to ggplot

gc.matrix.ggplot <- melt(gc.matrix, id = "idx")
gc.matrix.ggplot <- gc.matrix.ggplot[order(gc.matrix.ggplot$idx),]

mypalette<-colorRampPalette(brewer.pal(8,"Set1"))(ncol(gc.matrix)-1)

## draw

plot.save <- ggplot(gc.matrix.ggplot, aes(x=idx, y=value, colour=variable)) + geom_line() + geom_point() + theme_bw() + theme(axis.title=element_text(face="bold")) + xlab("Position in reads") + ylab("GC content") + xlim(gc.size[1],gc.size[length(gc.size)]) + ylim(0,100) + scale_colour_manual(values=mypalette) + guides(color=guide_legend(title="Samples"))
ggsave(filename=figFile, plot=plot.save, width=7, height=5)

