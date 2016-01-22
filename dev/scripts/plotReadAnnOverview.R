# Copyleft ↄ⃝ 2012 Institut Curie
# Author(s): Jocelyn Brayet, Laurene Syx, Chongjian Chen, Nicolas Servant(Institut Curie) 2012 - 2015
# Contact: bioinfo.ncproseq@curie.fr
# This software is distributed without any guarantee under the terms of the GNU General
# Public License, either Version 2, June 1991 or Version 3, June 2007.

rm(list=ls())
require(ggplot2)
require(reshape2)
##require(plyr)

## were additional arguments to R CMD BATCH given ?

args <- commandArgs(TRUE)
la <- length(args)
if (la > 0){
  for (i in 1:la)
    eval(parse(text=args[[i]]))
}

## read stat table
allAnn <- read.table(annFile,header=T, row.names=1)
allMap <- read.table(mapFile,header=T, row.names=1)
stopifnot(nrow(allAnn)>0)

allAnnNames <- rownames(allAnn)

print(allAnn)
print(allMap)

print(length(allMap[1,]))

for(i in 1:length(allMap[1,])){
	allMap["mapped",i] <- allMap["mapped",i]-sum(allAnn[,i])
}

allAnn <- rbind(allAnn,allMap["mapped",])

print(allAnn)


## Get percentage
allAnn<-apply(allAnn,2, function(x){round(x/sum(x, na.rm=TRUE)*100,3)})

rownames(allAnn) <- c(allAnnNames, "unknown")

print(allAnn)

## get mapping info
famName <-rownames(allAnn)
#famName <- sub("rmsk_rRNA","rRNA",famName)
#famName <- sub("rmsk","repeat",famName)
#famName <- 
allAnn <- cbind(rownames(allAnn),allAnn)
colnames(allAnn) <- c("idx", colnames(allAnn)[-1])
sampleName <- colnames(allAnn)[-1]
maxNchar <- max(nchar(sampleName))

allAnn.ggplot <- melt(as.data.frame(allAnn),id="idx")
allAnn.ggplot <- allAnn.ggplot[order(allAnn.ggplot$variable, allAnn.ggplot$idx),]
#allAnn.ggplot <- ddply(allAnn.ggplot, "variable", transform, freq=(value/sum(value))*100)

print(allAnn.ggplot)

colors <- c("antiquewhite3","aquamarine3","azure3","chartreuse4","burlywood4","coral3","blueviolet","darkgoldenrod3","darkred","darkseagreen3","khaki2","thistle2")
## create barplot of repeats/rfam annotation

plot.save <-ggplot(allAnn.ggplot, aes(x=variable, as.numeric(value), fill=idx,order=-as.numeric(idx))) + geom_bar(width=.7, stat="identity")+
    theme_bw() + theme(axis.title=element_text(face="bold")) + xlab(NULL) + ylab("Percentage of reads") +
    guides(fill=guide_legend(title="Type"))+ scale_fill_manual(values=colors)+ theme(axis.text.x = element_text(face = "bold",angle = 90, hjust = 1))
ggsave(filename=file.path(picDir,paste("plotReadAnnOverview.png", sep="")), plot=plot.save, height=6+maxNchar*0.1, width=3+0.5*(ncol(allAnn)-1))
       
## write table
write.table(allAnn,file=annFile,quote=FALSE, sep="\t", row.names = FALSE)
