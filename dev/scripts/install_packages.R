# Copyleft ↄ⃝ 2012 Institut Curie
# Author(s): Jocelyn Brayet, Laurene Syx, Chongjian Chen, Nicolas Servant(Institut Curie) 2012 - 2015
# Contact: bioinfo.ncproseq@curie.fr
# This software is distributed without any guarantee under the terms of the GNU General
# Public License, either Version 2, June 1991 or Version 3, June 2007.

## Install R packages for ncPRO-seq


##########################################
## CRAN

## RColorBrewer
install.packages("RColorBrewer", repos="http://cran.us.r-project.org", dependencies=TRUE)
install.packages("ggplot2", repos="http://cran.us.r-project.org", dependencies=TRUE)
install.packages("gplots", repos="http://cran.us.r-project.org", dependencies=TRUE)
install.packages("reshape2", repos="http://cran.us.r-project.org", dependencies=TRUE)
install.packages("gridExtra", repos="http://cran.us.r-project.org", dependencies=TRUE)

##########################################
## BioConductor
source("http://bioconductor.org/biocLite.R")

## seqLogo
biocLite("seqLogo")

## girafe
biocLite("girafe")
