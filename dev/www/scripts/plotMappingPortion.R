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
    for (i in 1:la){
        eval(parse(text=args[[i]]))
    }
}

print(args)

## read mapping stat table

map.matrix <- read.table(mapFile,header=T,check.names=FALSE,row.names=1)

## get mapping info

stopifnot(is.element(c("unmapped","mapped"),rownames(map.matrix)))

if (Type=="genome"){
  sampleName <- colnames(map.matrix)
  
  if (length(sampleName)==1){
  n.unmap <- matrix(map.matrix[which(rownames(map.matrix)=="unmapped"),],dimnames=list("unmapped", sampleName))
  n.map <- matrix(map.matrix[which(rownames(map.matrix)=="mapped"),],dimnames=list("mapped", sampleName))
  u.map <-  matrix(map.matrix[which(rownames(map.matrix)=="uniq_mapped"),],dimnames=list("uniq_mapped", sampleName))
  m.map <- matrix(map.matrix[which(rownames(map.matrix)=="multi_mapped"),],dimnames=list("multi_mapped", sampleName))
  }else{
    n.unmap <- map.matrix[which(rownames(map.matrix)=="unmapped"),]
    n.map <- map.matrix[which(rownames(map.matrix)=="mapped"),]
    u.map <-  map.matrix[which(rownames(map.matrix)=="uniq_mapped"),]
    m.map <- map.matrix[which(rownames(map.matrix)=="multi_mapped"),]
  }
    
  map.matrix.ggplot <- rbind(u.map,m.map,n.unmap)

	print(map.matrix.ggplot)
  
  ## get percentage
  perc <- apply(map.matrix.ggplot,2, function(x){round(as.numeric(x)/sum(as.numeric(x), na.rm=TRUE)*100,3)})
  pos <- apply(map.matrix.ggplot,2, function(x){cumsum(as.numeric(x))-(as.numeric(x)/2)})
  perc <- as.data.frame(cbind(rownames(map.matrix.ggplot), perc))
  pos <- as.data.frame(cbind(rownames(map.matrix.ggplot), pos))
  colnames(perc)<- colnames(pos) <- c("idx", sampleName)
  
  map.matrix.ggplot <- cbind(rownames(map.matrix.ggplot),map.matrix.ggplot)
  colnames(map.matrix.ggplot) <- c("idx",sampleName)
  map.matrix.melt <- melt(as.data.frame(map.matrix.ggplot), id="idx")
  map.ggplot.perc <- melt(perc,id="idx")
  map.matrix.melt$freq <- map.ggplot.perc$value
  map.ggplot.pos <- melt(pos,id="idx")
  map.matrix.melt$pos <- map.ggplot.pos$value
  
  ### draw barplot 


####################### Recup uniq_mapped + multi_mapped for each sample for the plot ###############################
	count = 1
	freqMapped = c()
	posMapped = c()

	for (i in 1:(length(map.matrix.melt$variable)/3)){

		freqMapped <- c(freqMapped,rep(as.numeric(map.matrix.melt[count,4]) + as.numeric(map.matrix.melt[count+1,4]),3))
		
		
		sumPosMapped <- as.numeric(map.matrix.melt[count,3]) + as.numeric(map.matrix.melt[count+1,3]) + as.numeric(map.matrix.melt[count+2,3])
		sumPosMapped <- sumPosMapped + 1/50*sumPosMapped
		posMapped <- c(posMapped,rep(sumPosMapped,3))
		

		count = count + 3
	}

maxPosMapped <- max(posMapped)+1/30*max(posMapped)

#######################################################################################################################

print(maxPosMapped)
print(map.matrix.melt)
cols <- c("red","gray61","#4FA9AF","#3288BD")
typeName <- c("Total matches","unmapped","multi_mapped","uniq_mapped")


  plot.save <- ggplot(map.matrix.melt, aes(variable,as.numeric(value),fill=idx))  + geom_bar(width=.7,stat="identity") + theme_bw() + theme(axis.title=element_text(face="bold")) + xlab(NULL) + ylab("Number of reads") + geom_bar(width=.7,stat="identity") + scale_fill_manual("Type", values=cols, limits=typeName) + geom_text(aes(x=variable, y=as.numeric(pos), label=paste(round(as.numeric(freq),1),"%")),fontface="bold",size=4.5) + theme(axis.text.x = element_text(face = "bold",angle = 90, hjust = 1))+ geom_text(aes(x=variable, y=as.numeric(posMapped), label=paste(round(as.numeric(freqMapped),2),"%")),fontface="bold",colour="red") 


  ggsave(file.path(picDir,"plotGenomeMapping.png"), plot=plot.save, height=5+max(nchar(colnames(map.matrix)))*0.1, width=3+0.5*length(sampleName))

  }else if(Type=="premiRNA") {
  
  ### read miRNAs stat table
  
  mir.matrix <- read.table(mirnaFile,header=T,check.names=FALSE, row.names=1)
  sampleName <- colnames(mir.matrix)
  
  ### draw barplot
  if (length(sampleName)==1){
  m.map <- matrix(mir.matrix["premiRNA",],dimnames=list("premiRNA", sampleName))
  m.unmapped <- matrix(map.matrix[which(rownames(map.matrix) == "mapped"), colnames(mir.matrix)]-(m.map),dimnames=list("mapped", sampleName))
  }else{
  m.map <- mir.matrix["premiRNA",]
  m.unmapped <- map.matrix[which(rownames(map.matrix) == "mapped"), colnames(mir.matrix)]-(m.map)
  }  
  
  #m.map.perc <- round(100*m.map/map.matrix[which(rownames(map.matrix) == "mapped"), colnames(mir.matrix)], digits=1)

  mat <- rbind(m.map,m.unmapped)
  
  ## Get percentage
  perc <- apply(mat,2, function(x){round(as.numeric(x)/sum(as.numeric(x), na.rm=TRUE)*100,3)})
  pos <- apply(mat,2, function(x){cumsum(as.numeric(x))-(as.numeric(x)/2)})
  
  perc <- as.data.frame(cbind(rownames(mat), perc))
  pos <- as.data.frame(cbind(rownames(mat), pos))
  colnames(perc)<- colnames(pos) <- c("idx", sampleName)
  
  ## Get percentage
  mat <- cbind(rownames(mat), mat)
  colnames(mat) <- c("idx", sampleName)
  mat.ggplot <- melt(as.data.frame(mat),id="idx")
  mat.ggplot.perc <- melt(perc,id="idx")
  mat.ggplot$freq <- mat.ggplot.perc$value
  mat.ggplot.pos <- melt(pos,id="idx")
  mat.ggplot$pos <- mat.ggplot.pos$value

  #mat.ggplot <- ddply(mat.ggplot, "variable", transform, freq=(as.numeric(value)/sum(as.numeric(value)))*100, pos=(cumsum(value)-(value/2)))

cols <- c("gray61","#4FA9AF")

  plot.save <-ggplot(mat.ggplot, aes(variable,as.numeric(value),fill=idx)) + geom_bar(stat="identity", width=.7) + theme_bw() + theme(axis.title=element_text(face="bold")) + xlab(NULL) +
      ylab("Number of reads") + scale_fill_manual("Type", breaks=c("mapped","premiRNA"),values=cols, labels = c("Not matching","Matching sense premiRNA")) +
          geom_text(aes(x=variable, y=as.numeric(pos), label=paste(round(as.numeric(freq),1),"%")),fontface="bold",size=4.5) + theme(axis.text.x = element_text(face = "bold",angle = 90, hjust = 1))
    
  ggsave(file.path(picDir,paste("plotmiRNAmapping.png", sep="")), plot=plot.save, height=5+max(nchar(colnames(map.matrix)))*0.1, width=3+0.5*ncol(mir.matrix))
  }
