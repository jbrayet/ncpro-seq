# Copyleft ↄ⃝ 2012 Institut Curie
# Author(s): Jocelyn Brayet, Laurene Syx, Chongjian Chen, Nicolas Servant(Institut Curie) 2012 - 2015
# Contact: bioinfo.ncproseq@curie.fr
# This software is distributed without any guarantee under the terms of the GNU General
# Public License, either Version 2, June 1991 or Version 3, June 2007.

rm(list=ls())
library(ggplot2)
library(grid)

### were additional arguments to R CMD BATCH given ?
args <- commandArgs(TRUE)
la <- length(args)
if (la > 0){
  for (i in 1:la)
    eval(parse(text=args[[i]]))
}

## read mapping stat table

base.cov <- read.table(baseCov,header=T,check.names=FALSE,stringsAsFactors=FALSE)
base.cov.5end <- read.table(baseCov5end,header=T,check.names=FALSE,stringsAsFactors=FALSE)
base.cov.3end <- read.table(baseCov3end,header=T,check.names=FALSE,stringsAsFactors=FALSE)
sense.len <- read.table(senseLen,header=T,check.names=FALSE,stringsAsFactors=FALSE)
anti.len <- read.table(antisenseLen,header=T,check.names=FALSE,stringsAsFactors=FALSE)
all.len <- read.table(allLen,header=T,check.names=FALSE,stringsAsFactors=FALSE)

sampleName <- colnames(all.len)[-1]

##exit if no sequences are found

print(as.matrix(all.len))

#stopifnot(sum(as.matrix(all.len))>0)

if(sum(as.matrix(all.len))==0){
  q()
}


#create the data frame for ggplot

## function to add percentages and change the format of the data.frame to use ggplot2

all <- (colSums(sense.len) + colSums(anti.len))[-1]

changePercFormat <- function(x,type="xx"){
  xsample.num <- ncol(x)-1
  xsample.type <- type
  x.data <- c()
  for(i in 1:xsample.num){
    this.sample.name <- sampleName[i]
    this.value <- (sum(x[,i+1])/all[i])*100                                                          
    this.sample.data <- cbind(this.value,this.sample.name,xsample.type)
    x.data <- rbind(x.data,this.sample.data)
  }
  colnames(x.data) <- c("Percentage","Samples","Type")
  x.data <- as.data.frame(x.data,stringsAsFactors=FALSE)
  x.data$Percentage <- as.numeric(x.data$Percentage)
  x.data$Percentage[is.na(x.data$Percentage)] <- 0
  return (x.data)
}

##function to change the format of read length  to data.frame used by ggplot2
changeLenFormat <- function(x,type="xx"){
  xsample.num <- ncol(x)-1
  xsample.type <- rep(type,nrow(x))
  x.data <- c()
  for(i in 1:xsample.num){
    this.sample.name <- sampleName[i]
    this.sample.name.col <- rep(this.sample.name,nrow(x))
    this.value <- (x[,i+1]/sum(x[,i+1]))*100  
    this.sample.data <- cbind(x[,1],this.value,this.sample.name.col,xsample.type)
    x.data <- rbind(x.data,this.sample.data)
  }
  colnames(x.data) <- c("idx","Value","Samples","Type")
  x.data <- as.data.frame(x.data,stringsAsFactors=FALSE)
  x.data$idx <- as.numeric(x.data$idx)
  x.data$Value <- as.numeric(x.data$Value)
  x.data$Value[is.na(x.data$Value)] <- 0
  return (x.data)
}

##function to change the format of basecoverage to data.frame used by ggplot2
changeBaseFormat <- function(x,type="xx"){
  xsample.num <- (ncol(x)-1)/2
  xsample.type <- rep(type,nrow(x))
  #get length of sequence
  split.str=strsplit(colnames(x)[2],"_")[[1]]
  cur.len=as.numeric(split.str[length(split.str)])
  xsample.len <- rep(cur.len,nrow(x))
  x.data <- c()
  for(i in 1:xsample.num){
    this.sample.name <- sampleName[i]
    this.sample.name.col <- rep(this.sample.name,nrow(x))
    sense.direction <- rep(paste("Sense_",this.sample.name,sep=""),nrow(x))
    this.sample.sense.data <- cbind(x[,1],x[,2*i],this.sample.name.col,xsample.type,sense.direction,xsample.len)
    antisense.direction <- rep(paste("Antisense_",this.sample.name,sep=""),nrow(x))
    this.sample.antisense.data <- cbind(x[,1],-x[,2*i+1],this.sample.name.col,xsample.type,antisense.direction,xsample.len)
    x.data <- rbind(x.data,this.sample.sense.data,this.sample.antisense.data)
  }
  colnames(x.data) <- c("idx","Value","Samples","Type","Direction","Length")
  x.data <- as.data.frame(x.data,stringsAsFactors=FALSE)
  x.data$Value <- as.numeric(x.data$Value)
  x.data$idx <- as.numeric(x.data$idx)
  x.data$Length <- as.numeric(x.data$Length)
  return (x.data)
}



##change to ggplot2 data.frames
perc.sens <- changePercFormat(sense.len,type="Sens")
perc.anti <- changePercFormat(anti.len,type="Anti")
perc.all <- rbind(perc.sens,perc.anti)
base.cov <- changeBaseFormat(x=base.cov,type="All")
base.cov.5end <- changeBaseFormat(base.cov.5end,type="5' end")
base.cov.3end <- changeBaseFormat(base.cov.3end,type="3' end")
sense.len <- changeLenFormat(sense.len)
anti.len <- changeLenFormat(anti.len)
all.len <- changeLenFormat(all.len)

base.cov.end <- rbind(base.cov.5end,base.cov.3end)
base.cov.end$Type=factor(base.cov.end$Type, levels=c("5' end","3' end"))

##function to assign layout
vplayout <- function(x, y)
  viewport(layout.pos.row = x, layout.pos.col = y)

###plot figure for combining information for all libraries###

#change the theme of qplot

base.xlabel <- seq(0,1000,200)
cons.len <- max(base.cov$Length)
base.xname <- paste(ncFam," coordinates [nt]",sep="")

min.len <- min(all.len$idx)
max.len <- max(all.len$idx)

max.end.cov <- max(base.cov.end$Value)
min.end.cov <- min(base.cov.end$Value)

max.all.len.perc <- max(all.len$Value)
max.sense.len.perc <- max(sense.len$Value)
max.anti.len.perc <- max(anti.len$Value)

if (max.all.len.perc == -Inf) { max.all.len.perc = 0 }
if (max.sense.len.perc == -Inf) { max.sense.len.perc = 0 }
if (max.anti.len.perc == -Inf) { max.anti.len.perc = 0 }

if (multi == 0) {
  
  for(i in 1:length(sampleName)){
  sens <- sense.len[which(sense.len[,3]==sampleName[i]),]
  anti <- anti.len[which(anti.len[,3]==sampleName[i]),]
  all <- all.len[which(all.len[,3]==sampleName[i]),]
  base.all <- base.cov[which(base.cov[,3]==sampleName[i]),]
  base.end <- base.cov.end[which(base.cov.end[,3]==sampleName[i]),]
  base.5end <- base.cov.5end[which(base.cov.5end[,3]==sampleName[i]),]
  base.3end <- base.cov.3end[which(base.cov.3end[,3]==sampleName[i]),]
  perc <- perc.all[which(perc.all[,2]==sampleName[i]),]
  
  famFig <- paste(figDir,"/",sampleName[i],"_",ncFam,"_",covType,".png",sep="")
  png(famFig,units="in", res=300, height=10, width=12)
  grid.newpage()
  pushViewport(viewport(layout = grid.layout(3,2)))
  
  baseplot <- ggplot(base.all, aes(idx, Value, group = Direction)) + theme_bw() +  geom_line(colour="#3288BD") + ggtitle("Base coverage") + theme(plot.title = element_text(size = 11,face = "bold")) + scale_x_continuous(breaks=base.xlabel, labels=ceiling(base.xlabel/1000*cons.len), name=base.xname) + ylab("Coverage (RPM)") + geom_hline(yintercept=0, linetype="dashed") 
  print(baseplot, vp = vplayout(1, 1))
  
  baseplot <- ggplot(base.end, aes(idx, Value, group = Direction)) + theme_bw() + ylim(min.end.cov,max.end.cov) + geom_line(colour="#3288BD") + facet_grid(Type ~ .) + ggtitle("End coverage") + theme(plot.title = element_text(size = 11,face = "bold")) + scale_x_continuous(breaks=base.xlabel, labels=ceiling(base.xlabel/1000*cons.len), name=base.xname) + ylab("Coverage (RPM)") + geom_hline(yintercept=0, linetype="dashed")
  print(baseplot, vp = vplayout(2, 1))
  
  if(length(max.all.len.perc)!=0){
    lenplot <- ggplot(all, aes(idx, Value))+ geom_line(colour="#3288BD") + geom_point(colour="#3288BD") + theme_bw() + ylim(0,max.all.len.perc)  + ggtitle("Length distribution of all reads") + theme(plot.title = element_text(size = 11,face = "bold")) + ylab("Percentage of reads") + xlim(min.len,max.len) + xlab("Reads length [nt]")
    print(lenplot, vp = vplayout(1, 2))
  }
  
  if(length(max.sense.len.perc)!=0){
    lenplot <- ggplot(sens, aes(idx, Value)) + geom_line(colour="#3288BD") + geom_point(colour="#3288BD") + theme_bw() + ylim(0,max.sense.len.perc) +  ggtitle("Length distribution of sense reads") + theme(plot.title = element_text(size = 11,face = "bold")) + ylab("Percentage of reads") + xlim(min.len,max.len) +xlab("Reads length [nt]")
    print(lenplot, vp = vplayout(2, 2))
  }
  
  if(length(max.anti.len.perc)!=0){
  lenplot <- ggplot(anti, aes(idx, Value)) +  geom_line(colour="#3288BD") + geom_point(colour="#3288BD")+ theme_bw() + ylim(0,max.anti.len.perc)  + ggtitle("Length distribution of antisense reads") + theme(plot.title = element_text(face="bold",size = 11)) + ylab("Percentage of reads") + xlim(min.len,max.len) + xlab("Reads length [nt]")
  print(lenplot, vp = vplayout(3, 2))
  }
  
  percplot <- ggplot(perc, aes(Type, Percentage,fill="Type")) + geom_bar(width=0.7,stat="identity",fill=c("#4FA9AF","#3288BD")) + theme_bw() + ylim(0,100) + theme(plot.title = element_text(size=11,face="bold")) + ylab("Percentage of reads") + xlab(NULL) + ggtitle("Sense/antisense reads ratio") + scale_x_discrete(labels = c("Antisense","Sense"))
  print(percplot, vp = vplayout(3, 1))
  
  dev.off()
  }
}else{    
  
  famFig <- paste(figDir,"/",ncFam,"_",covType,".png",sep="")
  png(famFig,units="in", res=300, height=10, width=12)
  grid.newpage()
  pushViewport(viewport(layout = grid.layout(3, 2)))
  
  baseplot <- ggplot(base.cov, aes(idx, Value, group = Direction, colour= Samples)) + theme_bw() + theme(plot.title = element_text(size = 11,face = "bold")) +  geom_line() + ggtitle("Base coverage in all samples")+ scale_x_continuous(breaks=base.xlabel, labels=ceiling(base.xlabel/1000*cons.len), name=base.xname) + ylab("Coverage (RPM)") + geom_hline(yintercept=0, linetype="dashed") + scale_colour_brewer(palette="Set1")
  print(baseplot, vp = vplayout(1, 1))
          
  baseplot <- ggplot(base.cov.end, aes(idx, Value, group = Direction, colour= Samples)) + theme_bw() + theme(plot.title = element_text(size = 11,face = "bold")) + ylim(min.end.cov,max.end.cov) + geom_line() + facet_grid(Type ~ .) + ggtitle("End coverage in all samples") + scale_x_continuous(breaks=base.xlabel, labels=ceiling(base.xlabel/1000*cons.len), name=base.xname) + ylab("Coverage (RPM)") + geom_hline(yintercept=0, linetype="dashed") + scale_colour_brewer(palette="Set1")
  print(baseplot, vp = vplayout(2, 1))
          
  if(length(max.all.len.perc)!=0){
     lenplot <- ggplot(all.len, aes(idx, Value, group = Samples, colour= Samples)) + theme_bw() + theme(plot.title = element_text(size = 11,face = "bold")) + ylim(0,max.all.len.perc) + geom_line() + ggtitle("Length distribution of all reads in all samples")+ ylab("Percentage of reads") + geom_point() + scale_x_continuous(breaks = seq(min.len,max.len), name="Reads length [nt]") + scale_colour_brewer(palette="Set1")
     print(lenplot, vp = vplayout(1, 2))
     }
          
  if(length(max.sense.len.perc)!=0){
     lenplot <- ggplot(sense.len, aes(idx, Value, group = Samples, colour= Samples)) + theme_bw() + theme(plot.title = element_text(size = 11,face = "bold")) + ylim(0,max.sense.len.perc) +  geom_line() + ggtitle("Length distribution of sense reads in all samples") + ylab("Percentage of reads") + geom_point() + scale_x_continuous(breaks = seq(min.len,max.len), name="Reads length [nt]") + scale_colour_brewer(palette="Set1")
     print(lenplot, vp = vplayout(2, 2))
     }
          
  if(length(max.anti.len.perc)!=0){
     lenplot <- ggplot(anti.len, aes(idx, Value, group = Samples, colour= Samples)) + theme_bw() + theme(plot.title = element_text(size = 11,face = "bold")) + ylim(0,max.anti.len.perc) +  geom_line() + ggtitle("Length distribution of antisense reads in all samples")+ ylab("Percentage of reads") + geom_point() + scale_x_continuous(breaks = seq(min.len,max.len), name="Reads length [nt]") + scale_colour_brewer(palette="Set1")
     print(lenplot, vp = vplayout(3, 2))
     }
          
  percplot <- ggplot(perc.all, aes(Samples, Percentage,fill=Type),height=30, width=10) + geom_bar(width=0.1,stat="identity") + theme_bw() + ylim(0,100) + theme(axis.text.x =element_text(angle = 90, hjust = 1),plot.title = element_text(size=11,face="bold")) + ylab("Percentage of reads") + xlab(NULL) + ggtitle("Sense/antisense reads ratio in all samples") + guides(color=guide_legend(title="Reads"))+ scale_fill_manual(values=c("darkblue","#4FA9AF"))
  print(percplot, vp = vplayout(3, 1))
          
  dev.off()
} 
  
