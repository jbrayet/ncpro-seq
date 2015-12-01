# Copyleft ↄ⃝ 2012 Institut Curie
# Author(s): Jocelyn Brayet, Laurene Syx, Chongjian Chen, Nicolas Servant(Institut Curie) 2012 - 2015
# Contact: bioinfo.ncproseq@curie.fr
# This software is distributed without any guarantee under the terms of the GNU General
# Public License, either Version 2, June 1991 or Version 3, June 2007.

## Install R packages for ncPRO-seq

rcb<-require("RColorBrewer")
p1<-require("seqLogo")
p2<-require("girafe")
p3<-require("ggplot2")
p4<-require("reshape2")
p5<-require("gridExtra")
p6<-require("gplots")


if(p1 & p2 & p3 & p4 & p5 & p6){
     print("SUCCESS IN LOADING PACKAGES")
}else{
     stop("ERROR IN LOADING PACKAGES")	
}
	
