# Copyleft ↄ⃝ 2012 Institut Curie
# Author(s): Jocelyn Brayet, Laurene Syx, Chongjian Chen, Nicolas Servant(Institut Curie) 2012 - 2015
# Contact: bioinfo.ncproseq@curie.fr
# This software is distributed without any guarantee under the terms of the GNU General
# Public License, either Version 2, June 1991 or Version 3, June 2007.

#The R script is used to detect significant region by fitting selected model

rm(list=ls())

require(girafe)

### were additional arguments to R CMD BATCH given ?
args <- commandArgs(TRUE)
la <- length(args)
if (la > 0){
  for (i in 1:la)
    eval(parse(text=args[[i]]))
}

##len and win file name
lenFile <- paste(dataDir,"/",prefix,"_lendistr.data",sep="")
winFile <- paste(dataDir,"/",prefix,"_window.data",sep="")

## read table
bkg.len <- read.table(lenFile)
win.info <- read.table(winFile,header=T)

if(is.logical(win.info[,1])){
    write.table(win.info[,1], file=file.path(docDir,paste(prefix,"_sigReg.data", sep="")), col.names=FALSE, row.names=FALSE, sep="\t", quote=FALSE)
    q()
  }

pCutoff <- as.numeric(pCutoff)
class(win.info) <- c(class(win.info),"slidingWindowSummary")

## fit model
resWins <- addNBSignificance(win.info, estimate=fitMethod, correct="BY")

## draw plot to check the model fit
FitplotFig <- paste(prefix,"_plotReadModelFit.png",sep="")
png(file.path(picDir, FitplotFig), units="in",res=300, width=6, height=5)
plotNegBinomFit(resWins)
dev.off()

## determine read number threshold
nb <- attr(resWins,"NBparams")
stopifnot(!is.null(nb))
min.hits <- qnbinom(pCutoff, nb$size, mu=nb$mu, lower.tail = FALSE)

## take significant subset
sigWins <- subset(resWins, p.value < pCutoff)

## add additional information
sigWins$frac.plus <- round(sigWins$frac.plus,digits=2)
coords <- with(sigWins,paste(chr,start,end,n.overlap,sep="."))
sigWins <- sigWins[!duplicated(coords),,drop=FALSE]
sigWins$cutoff <- rep(min.hits,nrow(sigWins))
#sigWins$lib <- rep(, nrow(sigWins))

## add library information
lib <- sub("_window.data","",strsplit(winFile,"/")[[1]][2])
rnames <- strsplit(readnames,",")[[1]]
lib <- rnames[which(pmatch(rnames,lib,nomatch=0)==1)]
sigWins$lib <- rep(lib, nrow(sigWins))

## do chi-square test to compare the difference of read length distribution between each window and the whole genome
min.bkg.len <- as.numeric(rownames(bkg.len)[1])
max.bkg.len <- as.numeric(rownames(bkg.len)[nrow(bkg.len)])
win.len.pval <- lapply(as.character(sigWins[,11]),function(x){
  cur.str <- as.numeric(gsub("L","",strsplit(x,":")[[1]]))
  ## get min and max read length in the window
  cur.min.len <- cur.str[1]
  cur.max.len=cur.str[length(cur.str)]
  ## get length distribuion in the window
  cur.len.distr <- cur.str[2:(length(cur.str)-1)]
  ## add 0 to read length which is not present in the window
  if(cur.min.len>min.bkg.len){
    cur.len.distr <- c(rep(0,cur.min.len-min.bkg.len),cur.len.distr)
  }
  if(cur.max.len<max.bkg.len){
    cur.len.distr <- c(cur.len.distr,rep(0,max.bkg.len-cur.max.len))
  }
  ##do chi-square test
  suppressWarnings(chisq.test(cur.len.distr,p=bkg.len[,1]/sum(bkg.len[,1]))$p.value)  
})

## correct p-value for multiple tests
sigWins$len.chisq <- p.adjust(win.len.pval, "bonferroni")

## output the result table
write.table(sigWins, file=file.path(docDir,paste(prefix,"_sigReg.data", sep="")), col.names=TRUE, row.names=FALSE, sep="\t", quote=FALSE)
