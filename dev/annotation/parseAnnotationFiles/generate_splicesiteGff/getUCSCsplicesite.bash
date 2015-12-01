#!/bin/bash

########################
##
## 1- Download REFGENE file from UCSC
## 2- Create a gff file
#######################

## TO EDIT
DOWNLOAD=1
FORMAT=1
CLEAN=1

##extended bases
EXTEND=100

##Mouse
#ORGANISM="mm9"

##Human
ORGANISM="hg38"


REFGENE_FILE=$ORGANISM"_refgene"


if [ $DOWNLOAD -eq 1 ]; then
	
	if [ -d "./download/" ]; then
	    rm ./download/*
	else
	    mkdir download
	fi
	
	if [ -f $REFGENE_FILE ]; then
	    rm $REFGENE_FILE
	fi
	
	echo "##bin\tname\tchrom\tstrand\ttxStart\ttxEnd\tcdsStart\tcdsEnd\texonCount\texonStarts\texonEnds\tscore\tname2\tcdsStartStat\tcdsEndStat\texonFrames" > $REFGENE_FILE
	echo 'wget -P download/ http://hgdownload.cse.ucsc.edu/goldenPath/'$ORGANISM'/database/refGene.txt.gz' | sh
	gunzip download/*.gz
	grep -v "random" download/refGene.txt > $REFGENE_FILE
fi


if [ $FORMAT -eq 1 ]; then
	generateExtendSpliceSite.pl -i $REFGENE_FILE -e $EXTEND
fi


if [ $CLEAN -eq 1 ]; then
    rm ./download/* $REFGENE_FILE
fi
