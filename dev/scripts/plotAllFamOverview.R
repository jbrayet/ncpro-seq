# Copyleft ↄ⃝ 2012 Institut Curie
# Author(s): Jocelyn Brayet, Laurene Syx, Chongjian Chen, Nicolas Servant(Institut Curie) 2012 - 2015
# Contact: bioinfo.ncproseq@curie.fr
# This software is distributed without any guarantee under the terms of the GNU General
# Public License, either Version 2, June 1991 or Version 3, June 2007.

rm(list=ls())
require(ggplot2)
require(reshape2)
require(RColorBrewer)
##require(plyr)

## were additional arguments to R CMD BATCH given ?

args <- commandArgs(TRUE)
la <- length(args)
if (la > 0){
  for (i in 1:la)
    eval(parse(text=args[[i]]))
}

## read stat table

allFam <- read.table(tabFile,header=T, row.names=1)
sampleName <- colnames(allFam)

famName <- setdiff(rownames(allFam),"microRNA")
if (length(sampleName)==1){
    allFam <- matrix(allFam[famName,], dimnames=list(famName, sampleName))
}else{
    allFam <- allFam[famName,]
}
stopifnot(nrow(allFam)>0)

## if(length(grep("microRNA",rownames(allFam)))==1){
##   ##allFam <- allFam[-grep("microRNA",rownames(allFam)),]
##   mirnaindex <- grep("microRNA",rownames(allFam))
##   allFam <- allFam[-mirnaindex,]
##   #rownames(allFam) <- rownames(allFam)[-mirnaindex]
## }

allFam<-apply(allFam,2, function(x){round(x/sum(x, na.rm=TRUE)*100,3)})

## get mapping info

allFam <- cbind(rownames(allFam),allFam)
colnames(allFam) <- c("idx", colnames(allFam)[-1])
#sampleName <- colnames(allFam)[-1]
maxNchar <- max(nchar(sampleName))


allFam.ggplot <- melt(as.data.frame(allFam),id="idx")
allFam.ggplot <- allFam.ggplot[order(allFam.ggplot$variable, allFam.ggplot$idx),]
##allFam.ggplot <- ddply(allFam.ggplot, "variable", transform, freq=(value/sum(value))*100)

## create barplot of repeats/rfam annotation

colors <- c("antiquewhite3","aquamarine3","azure3","chartreuse4","burlywood4","coral3","blueviolet","darkgoldenrod3","darkred","darkseagreen3","darkorange2","khaki2","thistle2","darkmagenta","cyan","beige","darkkhaki","chartreuse")

colourCount = length(unique(allFam.ggplot$idx))+1
#getPalette = colorRampPalette(brewer.pal(12, "Paired"))
plot.save <-ggplot(allFam.ggplot, aes(variable,as.numeric(value),fill=idx,order=-as.numeric(idx))) + geom_bar(width=.7,stat="identity") + theme_bw() + theme(axis.title=element_text(face="bold")) + xlab(NULL) + ylab(paste("Percentage of reads aligned on ",type,sep="")) + guides(fill=guide_legend(title="Type"))+ scale_fill_manual(values=colors)+ theme(axis.text.x = element_text(face = "bold",angle = 90, hjust = 1))
ggsave(filename=figFile, plot=plot.save, height=6+maxNchar*0.1, width=3+0.5*ncol(allFam))




