# Copyleft ↄ⃝ 2012 Institut Curie
# Author(s): Jocelyn Brayet, Laurene Syx, Chongjian Chen, Nicolas Servant(Institut Curie) 2012 - 2015
# Contact: bioinfo.ncproseq@curie.fr
# This software is distributed without any guarantee under the terms of the GNU General
# Public License, either Version 2, June 1991 or Version 3, June 2007.

rm(list=ls())
library(ggplot2)
library(grid)
library(plyr)

### were additional arguments to R CMD BATCH given ?
args <- commandArgs(TRUE)
la <- length(args)
if (la > 0){
  for (i in 1:la)
    eval(parse(text=args[[i]]))
}

## read distance table
read.distance <- read.table(distanceFile,header=T,check.names=FALSE,stringsAsFactors=FALSE)
read.distance <- as.data.frame(read.distance,stringsAsFactors=FALSE)
sub.read.distance <- subset(read.distance, Distance<=30)

##exit if no info in the table
if(nrow(read.distance)==0){
  q()
}

#change the theme of qplot
previous_theme <- theme_set(theme_bw())

figFile <- paste(figDir,"/",ncinfo,"_read_distance_",covType,"_facet.png",sep="")
png(figFile,units="in", res=300, height=10, width=12)

ggplot(sub.read.distance, aes(Distance, Coverage, group = Direction, color= Direction)) + theme_bw() +  geom_line() + scale_y_continuous(name="Coverage (RPM)") + geom_hline(yintercept=0, linetype="dashed") + facet_wrap(~ Read_length, ncol = 6)
dev.off()

summary.data <- ddply(sub.read.distance,.(Direction,Distance),summarise,Coverage=sum(Coverage))
figFile <- paste(figDir,"/",ncinfo,"_read_distance_",covType,".png",sep="")
png(figFile,units="in", res=300, height=10, width=12)

ggplot(summary.data, aes(Distance, Coverage, group = Direction, color= Direction)) + theme_bw() +  geom_line()+ ylab("Coverage (RPM)") + geom_hline(yintercept=0, linetype="dashed")
dev.off()
