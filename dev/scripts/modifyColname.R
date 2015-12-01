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

##read the table
input.table <- read.table(tabFile,header=TRUE, check.names= FALSE)
input.colnames <- colnames(input.table)
input.ncol <- ncol(input.table)

for(i in 2:input.ncol){
  this.name <- input.colnames[i]
  this.name.split <- unlist(strsplit(this.name,"_"))
  this.samplename <- this.name.split[1]
  split.len <- length(this.name.split)
  if(split.len>2 & any(grep("sense",this.name.split[split.len-1]))){
    this.samplename <- paste(this.samplename,this.name.split[split.len-1],this.name.split[split.len],sep="_")
  }
  input.colnames[i] <- this.samplename
}

colnames(input.table) <- input.colnames

print(input.table)

##update the table
write.table(input.table,file=tabFile,quote=FALSE, sep="\t",row.names = FALSE)
