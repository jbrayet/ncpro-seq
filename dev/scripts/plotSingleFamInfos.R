# Copyleft ↄ⃝ 2012 Institut Curie
# Author(s): Jocelyn Brayet, Laurene Syx, Chongjian Chen, Nicolas Servant(Institut Curie) 2012 - 2015
# Contact: bioinfo.ncproseq@curie.fr
# This software is distributed without any guarantee under the terms of the GNU General
# Public License, either Version 2, June 1991 or Version 3, June 2007.

rm(list=ls())
require(ggplot2)
require(reshape2)
require(plyr)
require(gridExtra)

## were additional arguments to R CMD BATCH given ?
args <- commandArgs(TRUE)
la <- length(args)
if (la > 0){
  for (i in 1:la)
    eval(parse(text=args[[i]]))
}

## read tables

base.cov <- read.table(baseCov,header=T,check.names=FALSE)
base.cov.5end <- read.table(baseCov5end,header=T,check.names=FALSE)
base.cov.3end <- read.table(baseCov3end,header=T,check.names=FALSE)

sense.len <- read.table(senseLen,header=T,check.names=FALSE)
anti.len <- read.table(antisenseLen,header=T,check.names=FALSE)
all.len <- read.table(allLen,header=T,check.names=FALSE)

if(sum(as.matrix(all.len))==0){
  q()
}

sampleName <- colnames(all.len)[-1]

## coverage part

  ### set the same ylim for all basecoverage plot

  sense.base.cov.max <- max(base.cov[,grep("_sense", colnames(base.cov))])
  antisense.base.cov.max <- max(base.cov[,grep("_antisense", colnames(base.cov))])

  ### get consensus length info

  cons.len <-as.numeric(sapply(colnames(base.cov),function(x){
    split.str=strsplit(x,"_")[[1]]
    if(length(split.str)==1){
     0
    }
    else{
      cur.len=split.str[length(split.str)]
      cur.len
    }
   }))

  ### get column names in base covage file without consensus length information

  colnames(base.cov) <- as.character(sapply(colnames(base.cov),function(x){
    split.str=strsplit(x,"_")[[1]]
    if(length(split.str)==1){
      x
    }
    else{
      sub.str=paste(split.str[1:length(split.str)-1],collapse="_")
      sub.str
   }
  }))

  colnames(base.cov.5end) <- as.character(sapply(colnames(base.cov.5end),function(x){
   split.str=strsplit(x,"_")[[1]]
    if(length(split.str)==1){
     x
    }
    else{
     sub.str=paste(split.str[1:length(split.str)-1],collapse="_")
     sub.str
    }
  }))

  colnames(base.cov.3end) <- as.character(sapply(colnames(base.cov.3end),function(x){
    split.str=strsplit(x,"_")[[1]]
    if(length(split.str)==1){
     x
    }
    else{
      sub.str=paste(split.str[1:length(split.str)-1],collapse="_")
      sub.str
   }
  }))

  ### transformation to use ggplot
  
  lapply(as.list(sampleName),function(x){

  base.sense.cov <- which(colnames(base.cov)==paste(x,"sense",sep="_"))
  cur.base.sense.cov <- base.cov[,c(1,base.sense.cov)]
  cur.base.sense.cov[,3] <- c("base.sense.cov")
  colnames(cur.base.sense.cov) <- c("idx","sample","type")
   
  base.anti.cov <- which(colnames(base.cov)==paste(x,"antisense",sep="_"))
  cur.base.anti.cov <- base.cov[,c(1,base.anti.cov)]
  cur.base.anti.cov[,3] <- c("base.anti.cov")
  colnames(cur.base.anti.cov) <- c("idx","sample","type")
  cur.base.anti.cov$sample <- -(cur.base.anti.cov$sample)
  
  base.5end.sense.cov <- which(colnames(base.cov.5end)==paste(x,"sense",sep="_"))
  cur.base.5end.sense.cov <- base.cov.5end[,c(1,base.5end.sense.cov)]
  cur.base.5end.sense.cov[,3] <- c("base.5end.sense.cov")
  colnames(cur.base.5end.sense.cov) <- c("idx","sample","type")
  
  base.5end.anti.cov <- which(colnames(base.cov.5end)==paste(x,"antisense",sep="_"))
  cur.base.5end.anti.cov <- base.cov.5end[,c(1,base.5end.anti.cov)]
  cur.base.5end.anti.cov[,3] <- c("base.5end.anti.cov")
  colnames(cur.base.5end.anti.cov) <- c("idx","sample","type")
  cur.base.5end.anti.cov$sample <- -(cur.base.5end.anti.cov$sample)
  
  base.3end.sense.cov <- which(colnames(base.cov.3end)==paste(x,"sense",sep="_"))
  cur.base.3end.sense.cov <- base.cov.3end[,c(1,base.3end.sense.cov)]
  cur.base.3end.sense.cov[,3] <- c("base.3end.sense.cov")
  colnames(cur.base.3end.sense.cov) <- c("idx","sample","type")
  
  base.3end.anti.cov <- which(colnames(base.cov.3end)==paste(x,"antisense",sep="_"))
  cur.base.3end.anti.cov <- base.cov.3end[,c(1,base.3end.anti.cov)]
  cur.base.3end.anti.cov[,3] <- c("base.3end.anti.cov")
  colnames(cur.base.3end.anti.cov) <- c("idx","sample","type")
  cur.base.3end.anti.cov$sample <- -(cur.base.3end.anti.cov$sample)
 
  cur.cons.len <- cons.len[which(colnames(base.cov)==paste(x,"sense",sep="_"))]
  
  all.table.cov.ggplot <- rbind(cur.base.sense.cov,cur.base.anti.cov, cur.base.5end.sense.cov,cur.base.5end.anti.cov,cur.base.3end.sense.cov,cur.base.3end.anti.cov)
  all.table.cov.ggplot$idx <- all.table.cov.ggplot$idx/1000*cur.cons.len
  
  ### plot base coverage

  fig.name <- paste(figDir,"/",x,"_",ncFam,"_",covType,".png",sep="")  
  plot.save <- ggplot(all.table.cov.ggplot, aes(idx,sample,colour=type)) + geom_line() + theme_bw() + theme(axis.title=element_text(face="bold")) + xlab(paste(ncFam,"coordinates [nt]")) + ylab("Coverage") + guides(colour=guide_legend(title="Type"))+ xlim(0,max(all.table.cov.ggplot$idx)) + ylim(-antisense.base.cov.max, sense.base.cov.max)+  scale_colour_manual(name="Type",breaks=c("base.3end.anti.cov","base.3end.sense.cov","base.5end.anti.cov","base.5end.sense.cov","base.anti.cov","base.sense.cov"),labels=c("3' end (anti)", "3' end (sens)","5' end (anti)", "5' end (sens)", "All positions (anti)", "All positions (sens)"),values=c("#330099","#6633CC","navyblue","#377EB8","darkred","tomato3"))
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              

  ### plot length distribution (all, sense, antisense)

  cur.sense.len <- sense.len[,c("idx",x)]
  cur.anti.len <- anti.len[,c("idx",x)]
  cur.all.len <- all.len[,c("idx",x)]
  
  cur.sense.len[,3] <- c("sense.len")
  colnames(cur.sense.len)[3] <- "type"

  cur.anti.len[,3] <- c("anti.len")
  colnames(cur.anti.len)[3] <- "type"
  
  cur.all.len[,3] <- c("all.len")
  colnames(cur.all.len)[3] <- "type"
  
  all.table.len <- rbind(cur.sense.len, cur.anti.len, cur.all.len)
  all.table.len.ggplot <- melt(all.table.len,id=c("idx","type"))
  all.table.len.ggplot <- all.table.len.ggplot[order(all.table.len.ggplot$type, all.table.len.ggplot$idx),]
  all.table.len.ggplot <- ddply(all.table.len.ggplot, "type", transform, freq=(value/sum(value))*100)
  
  x.limits <- range(c(sense.len$idx,anti.len$idx,all.len$idx))
  max.perc <- max(all.table.len.ggplot$freq)
  
  plot.save2 <- ggplot(all.table.len.ggplot, aes(idx,freq,colour=type)) + geom_line() + geom_point() + theme_bw() + theme(axis.title=element_text(face="bold")) + xlab("Read length [nt]") + ylab("Percentage of reads") + guides(colour=guide_legend(title="Type"))+ scale_colour_manual(values=c("darkred","tomato3", "#377EB8"), labels = c("All reads", "Antisens reads","Sens reads"))+ xlim(x.limits) + ylim(0,max.perc)
  
  ### plots in the same file
 
  fig.name <- paste(figDir,"/",x,"_",ncFam,"_",covType,".png",sep="")
  png(fig.name,units="in", res=300, height=4, width=10)
  par(font.lab=2, mai=c(1,.8, 0.2, 0.3),mfrow=c(1,2))
  grid.arrange(plot.save,plot.save2, ncol=2)
  dev.off()
  })

