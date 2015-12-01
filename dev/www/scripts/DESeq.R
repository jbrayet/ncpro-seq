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

library("DESeq")

## read fam cov table
famcov.table <- read.table(famcovFile,header=T,check.names=FALSE)
famcov.colname <- colnames(famcov.table)

# libs in each group
lib.group <- unlist(strsplit(group,";"))
group1.lib <- unlist(strsplit(lib.group[1],","))
group2.lib <- unlist(strsplit(lib.group[2],","))

#condition of lib groups
group.lib <- c(group1.lib,group2.lib)
group.mark <- factor(c(rep("T",length(group1.lib)),rep("N",length(group2.lib))))

#number of group lib
group.lib.n <- length(group1.lib)+length(group2.lib)

#save group lib in lib.deseq
lib.deseq <- mat.or.vec(nrow(famcov.table),group.lib.n)

for(i in 1:group.lib.n){
  cur.lib <- group.lib[i]
  cur.lib <- basename(cur.lib) #remove dir if any
  cur.lib.idx <- which(famcov.colname %in% cur.lib)
  cur.lib.data <- famcov.table[,cur.lib.idx]
  lib.deseq[,i] <- cur.lib.data
}

#coerce values in dataframe to integer type
for(i in 1:nrow(famcov.table)){
  for(j in 1:group.lib.n){
    lib.deseq[i,j] <- as.integer(lib.deseq[i,j])
  }
}

#rownames of lib
rownames(lib.deseq) <- famcov.table[,1]

#use DESeq to identify differentially expressed genes
cds <- newCountDataSet(lib.deseq, group.mark )
#with replicates or partial replicates
if(group.lib.n>=3){
  cds <- estimateSizeFactors(cds)
  cds <- estimateDispersions(cds)
}
#without replicates
else{
  cds <- estimateDispersions(cds, method="blind", sharingMode="fit-only" )
}

res <- nbinomTest( cds, "T", "N" )
res <- res[order(res$pval),]

write.table(res, file=deseqOut",sep="\t",quote=FALSE,row.names=FALSE)
