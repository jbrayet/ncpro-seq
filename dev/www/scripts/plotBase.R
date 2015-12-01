# Copyleft ↄ⃝ 2012 Institut Curie
# Author(s): Jocelyn Brayet, Laurene Syx, Chongjian Chen, Nicolas Servant(Institut Curie) 2012 - 2015
# Contact: bioinfo.ncproseq@curie.fr
# This software is distributed without any guarantee under the terms of the GNU General
# Public License, either Version 2, June 1991 or Version 3, June 2007.

rm(list=ls())
require(ggplot2)
require(reshape2)
require(gridExtra)

## were additional arguments to R CMD BATCH given ?

args <- commandArgs(TRUE)
la <- length(args)
if (la > 0){
  for (i in 1:la)
    eval(parse(text=args[[i]]))
}

## read mapping stat table

base.files <- list.files(dataDir, pattern=".*\\_basestat\\.data$")
nfiles <- length(base.files)
if (nfiles==0L){
  stop("No basestat files found in directory ", dataDir,"!\n")
}

## table transformation to ggplot / draw

my.plots <- lapply(base.files, function(thisfile){
  base.matrix <- read.table(paste(dataDir,"/",thisfile,sep=""),header=T,check.names=FALSE)
  filename <- sub("_basestat.data","",thisfile)
  base.size <- base.matrix[,1]
  max.perc <- max(base.matrix)
  base.matrix.ggplot <- melt(base.matrix,id="idx")
  base.matrix.ggplot <- base.matrix.ggplot[order(base.matrix.ggplot$idx),]
  ggplot(base.matrix.ggplot, aes(x=idx, y=value, colour=variable)) + geom_line() + geom_point() + theme_bw() + theme(axis.text=element_text(size=7),legend.text = element_text(size = 7), axis.title=element_text(face="bold",size = 7), legend.title = element_text(face="bold",size = 7), plot.title = element_text(face="bold",size = 8)) + xlab("Position in reads") + ylab("Base content") + xlim(base.size[1],base.size[length(base.size)]) + ylim(0,max.perc) + scale_colour_manual(breaks=c("A","T","G","C","N"),values=c("darkred","tomato3","navyblue","#377EB8","gray40")) + guides(color=guide_legend(title="Bases"))+ ggtitle(filename)
})

png(figFile,units="in", res=300, height=ceiling(nfiles/2)*4, width=((nfiles>1)+1)*4)
#par(font.lab=2, mai=c(1,.8, 0.2, 0.3),mfrow=c(ceiling(nfiles/2),(nfiles>1)+1))
save.plots <- do.call("grid.arrange", c(my.plots,ncol=(nfiles>1)+1))
dev.off()

