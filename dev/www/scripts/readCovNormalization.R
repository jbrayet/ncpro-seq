# Copyleft ↄ⃝ 2012 Institut Curie
# Author(s): Jocelyn Brayet, Laurene Syx, Chongjian Chen, Nicolas Servant(Institut Curie) 2012 - 2015
# Contact: bioinfo.ncproseq@curie.fr
# This software is distributed without any guarantee under the terms of the GNU General
# Public License, either Version 2, June 1991 or Version 3, June 2007.

rm(list=ls())

### were additional arguments to R CMD BATCH given ?
args <- commandArgs(TRUE)
la <- length(args)
if (la > 0){
  for (i in 1:la)
    eval(parse(text=args[[i]]))
}

## read mapping stat table to get mapping info 
map.matrix <- read.table(mapFile,row.names=1,header=T,check.names=FALSE)
n.map <- map.matrix[which(rownames(map.matrix)=="mapped"),]

## read read cov table
cov.matrix <- read.table(covFile,row.names=1,header=T,check.names=FALSE)
cov.sample.header <- c("idx",colnames(cov.matrix))
cov.type <- rownames(cov.matrix)

cov.norm <- c()
##calculate rpm
if(Type=="basecov"){
  cov.norm <- 1000000*cov.matrix/matrix(as.numeric(rbind(as.numeric(n.map),as.numeric(n.map))),ncol=ncol(cov.matrix),nrow=nrow(cov.matrix),byrow=TRUE)
}
if(Type=="subfam"){
  cov.norm <- 1000000*cov.matrix/matrix(as.numeric(n.map),ncol=length(n.map), nrow=nrow(cov.matrix),byrow=TRUE)
}
##matrix(as.numeric(n.map),ncol=length(n.map), nrow=nrow(cov.matrix),byrow=TRUE)

##do tranformation
cov.norm <- cbind(cov.type,cov.norm)
colnames(cov.norm) <- cov.sample.header

##output
write.table(cov.norm,file=outFile,quote=FALSE,row.names=FALSE, sep="\t")
