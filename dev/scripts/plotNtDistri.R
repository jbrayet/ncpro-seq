# Copyleft ↄ⃝ 2012 Institut Curie
# Author(s): Jocelyn Brayet, Laurene Syx, Chongjian Chen, Nicolas Servant(Institut Curie) 2012 - 2015
# Contact: bioinfo.ncproseq@curie.fr
# This software is distributed without any guarantee under the terms of the GNU General
# Public License, either Version 2, June 1991 or Version 3, June 2007.

rm(list=ls())
require(RColorBrewer)

### were additional arguments to R CMD BATCH given ?
args <- commandArgs(TRUE)
la <- length(args)
if (la > 0){
  for (i in 1:la)
    eval(parse(text=args[[i]]))
}

## function to draw Logo   
plotLogo <- function(selPWM,Type){
  selPWM <- t(selPWM)
  readNum <- max(rowSums(selPWM))
  selPWM <- selPWM/matrix(rowSums(selPWM),ncol=ncol(selPWM), nrow=nrow(selPWM),byrow=FALSE)
  sel.colours <- brewer.pal(ncol(selPWM), "Dark2")
  leg <- paste(lprefix,"\n",readNum," reads"," (",Type,")",sep="")
  plot(x=0, y=0, type="n", pch=16, xaxt="n", frame=FALSE, ylim=c(0,1), xlim=c(1,nrow(selPWM)), xlab="Position", ylab="Fraction of nucleotide",main=leg)
  axis(side=1, pos=0)
  axis(side=2)
  for (i in 1:ncol(selPWM)){
    thisNt <- selPWM[,i]
    lines(x=as.integer(sub("X","",rownames(selPWM))), y=thisNt, col=sel.colours[i], type="o", pch=16, lwd=2)
}
legend(x="right", fill=sel.colours, cex=0.6, inset=0.01, legend=colnames(selPWM))
}

## read table
all.matrix <- read.table(paste(dataDir,"/",lprefix,"_",rprefix,"_logomatrix_all.data",sep=""),check.names=FALSE)
sense.matrix <- read.table(paste(dataDir,"/",lprefix,"_",rprefix,"_logomatrix_sense.data",sep=""),check.names=FALSE)
anti.matrix <- read.table(paste(dataDir,"/",lprefix,"_",rprefix,"_logomatrix_anti.data",sep=""),check.names=FALSE)

## draw three plots tegother
png(figFile, res=300, units="in", width=6, height=6)
par(mar=c(4.1, 4.1, 1.5, 1.5), font.lab=2, mfrow=c(2,2),font.main=2,cex.main=0.8)
plotLogo(all.matrix,"all")
plotLogo(sense.matrix,"sense")
plotLogo(anti.matrix,"antisense")
dev.off()
