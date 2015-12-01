#!/bin/bash

########################
##
## 1- Download tRNA file from UCSC
## 2- Create a gff file
#######################

## TO EDIT
DOWNLOAD=1
FORMAT=1
CLEAN=1

ORGANISM="hg38"


if [ $DOWNLOAD -eq 1 ]; then
    if [ -d "./download/" ]; then
	rm ./download/*
    else
	mkdir download
    fi
    echo 'wget -P download/ http://hgdownload.cse.ucsc.edu/goldenPath/'$ORGANISM'/database/tRNAs.txt.gz' | sh
    gunzip download/*.gz
fi


if [ $FORMAT -eq 1 ]; then
    awk -v org=$ORGANISM 'BEGIN{OFS="\t"}{split($5,info,"-");print $2,org"_tRNAs","exon",$3+1,$4,$6,$7,".","ID="info[1]";Type_Name=tRNA-"info[2]}' download/tRNAs.txt > tRNA.gff
fi

if [ $CLEAN -eq 1 ]; then
    rm -fr ./download/*
fi
