# Copyleft ↄ⃝ 2012 Institut Curie
# Author(s): Jocelyn Brayet, Laurene Syx, Chongjian Chen, Nicolas Servant(Institut Curie) 2012 - 2015
# Contact: bioinfo.ncproseq@curie.fr
# This software is distributed without any guarantee under the terms of the GNU General
# Public License, either Version 2, June 1991 or Version 3, June 2007.

rm(list=ls())

require(seqLogo)

### were additional arguments to R CMD BATCH given ?
args <- commandArgs(TRUE)
la <- length(args)
if (la > 0){
  for (i in 1:la)
    eval(parse(text=args[[i]]))
}

icscale <- ifelse(icscale==1,TRUE,FALSE)

### letter N, a placeholder for all the other letters
letterN <- function(x.pos,y.pos,ht,wt,id=NULL){
  
  x <- c(0.5,  2.5, 7.5, 7.5,9.5,9.5, 7.5, 2.5, 2.5, 0.5)
  y <- c(10,10, 2,10,10, 0, 0, 8, 0, 0)
  x <- 0.1*x
  y <- 0.1*y

  x <- x.pos + wt*x
  y <- y.pos + ht*y

  if (is.null(id)){
    id <- rep(1,length(x))
  }else{
    id <- rep(id,length(x))
  }
  fill <- "slategrey"
  list(x=x,y=y,id=id,fill=fill)
}



### Plot Logo from seqLogo package - Allow several graphs on the same display
seqLogo <- function (pwm, ic.scale = FALSE, xaxis = TRUE, yaxis = TRUE, xfontsize = 15,  yfontsize = 15){
    if (class(pwm) == "pwm") {
        pwm <- pwm@pwm
    }
    else if (class(pwm) == "data.frame") {
        pwm <- as.matrix(pwm)
    }
    else if (class(pwm) != "matrix") {
        stop("pwm must be of class matrix or data.frame")
    }
    if (any(abs(1 - apply(pwm, 2, sum)) > 0.01)) 
        stop("Columns of PWM must add up to 1.0")
    chars <- c("A", "C", "G", "T", "N")
    letters <- list(x = NULL, y = NULL, id = NULL, fill = NULL)
    npos <- ncol(pwm)
    if (ic.scale) {
        ylim <- 2
        ylab <- "Information content"
        facs <- seqLogo:::pwm2ic(pwm)
    }
    else {
        ylim <- 1
        ylab <- "Probability"
        facs <- rep(1, npos)
    }
    wt <- 1
    x.pos <- 0
    for (j in 1:npos) {
        column <- pwm[, j]
        hts <- 0.95 * column * facs[j]
        letterOrder <- order(hts)
        y.pos <- 0
        for (i in 1:5) {
            letter <- chars[letterOrder[i]]
            ht <- hts[letterOrder[i]]
            if (ht > 0){
              #add N character
              if (letter == "N") {
                letter <- letterN(x.pos,y.pos,ht,wt)
                letters$x <- c(letters$x,letter$x)
                letters$y <- c(letters$y,letter$y)
                lastID <- ifelse(is.null(letters$id),0,max(letters$id))
                letters$id <- c(letters$id,lastID+letter$id)
                letters$fill <- c(letters$fill,letter$fill)
              }
              else {
                letters <- seqLogo:::addLetter(letters, letter, x.pos, y.pos, ht, wt)
              }
            }                
            y.pos <- y.pos + ht + 0.01
        }
        x.pos <- x.pos + wt
    }
    ##grid.newpage()
    bottomMargin = ifelse(xaxis, 2 + xfontsize/3.5, 2)
    leftMargin = ifelse(yaxis, 2 + yfontsize/3.5, 2)
    pushViewport(plotViewport(c(bottomMargin, leftMargin, 2, 
        2)))
    pushViewport(dataViewport(0:ncol(pwm), 0:ylim, name = "vp1"))
    grid.polygon(x = unit(letters$x, "native"), y = unit(letters$y, 
        "native"), id = letters$id, gp = gpar(fill = letters$fill, 
        col = "transparent"))
    if (xaxis) {
        grid.xaxis(at = seq(0.5, ncol(pwm) - 0.5), label = 1:ncol(pwm), 
            gp = gpar(fontsize = xfontsize))
        grid.text("Position", y = unit(-3, "lines"), gp = gpar(fontsize = xfontsize))
    }
    if (yaxis) {
        grid.yaxis(gp = gpar(fontsize = yfontsize))
        grid.text(ylab, x = unit(-3, "lines"), rot = 90, gp = gpar(fontsize = yfontsize))
    }
    popViewport()
    popViewport()
    par(ask = FALSE)
}





## function to draw Logo   
plotLogo <- function(selPWM, Type, icscale){
  readNum <- max(colSums(selPWM))
  if(readNum!=0){
#      if(length(grep("N",rownames(selPWM)))){
#        selPWM <- selPWM[-grep("N",rownames(selPWM)),1:minLen]
#     }
      selPWM <- selPWM/matrix(colSums(selPWM),nrow=nrow(selPWM), ncol=ncol(selPWM),byrow=TRUE)
      #png(paste(figDir,"/",prefix,"_",direction,"_",Type,"_LOGO.png",sep=""), res=300, units="in", width=6, height=5)
      seqLogo(selPWM, ic.scale=icscale, xfontsize=7, yfontsize=7)
      leg <- paste("based on ",readNum," reads - ",prefix," (",Type,")",sep="")
      grid.text(leg, x = unit(0.5, "npc"), y = unit(0.05, "npc"), just = "centre", gp = gpar(font=4, cex=0.5, col="darkblue"))
      #dev.off()
  }
}

## read table
all.matrix.file <- paste(dataDir,"/",prefix,"_",direction,"_logomatrix_all_",readtype,".data",sep="")
if(!file.exists(all.matrix.file)){
  q()
}
all.matrix <- read.table(paste(dataDir,"/",prefix,"_",direction,"_logomatrix_all_",readtype,".data",sep=""),check.names=FALSE)
sense.matrix <- read.table(paste(dataDir,"/",prefix,"_",direction,"_logomatrix_sense_",readtype,".data",sep=""),check.names=FALSE)
anti.matrix <- read.table(paste(dataDir,"/",prefix,"_",direction,"_logomatrix_anti_",readtype,".data",sep=""),check.names=FALSE)

#get minimum read length
#len.matrix <- read.table(lenFile,check.names=FALSE,header=T,row.names=1)
#min.len <- as.numeric(rownames(len.matrix)[1])

#draw plots
ncRNA <- prefix
if(nchar(ref_cs)!=0){
  ncRNA <- sub(paste("_",ref_cs,sep=""),"",ncRNA)
}
if(nchar(ref)!=0){
  ncRNA <- sub(paste("_",ref,sep=""),"",ncRNA)
}

png(paste(figDir,"/",ncRNA,"_",direction,"_",readtype,"_LOGO.png",sep=""), res=300, units="in", width=5, height=7)
## Set up the page
grid.newpage()
pushViewport(viewport(layout = grid.layout(3,1)))

pushViewport(viewport(layout.pos.col=1, layout.pos.row=1))
print(plotLogo(all.matrix,"all", icscale), newpage=FALSE)
popViewport(1)

pushViewport(viewport(layout.pos.col=1, layout.pos.row=2))
print(plotLogo(sense.matrix,"sens", icscale), newpage=FALSE)
popViewport(1)

pushViewport(viewport(layout.pos.col=1, layout.pos.row=3))
print(plotLogo(anti.matrix,"antisens", icscale), newpage=FALSE)
popViewport()
dev.off()
