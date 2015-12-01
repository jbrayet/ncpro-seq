#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyleft ↄ⃝ 2012 Institut Curie
# Author(s): Jocelyn Brayet, Laurene Syx, Chongjian Chen, Nicolas Servant(Institut Curie) 2012 - 2015
# Contact: bioinfo.ncproseq@curie.fr
# This software is distributed without any guarantee under the terms of the GNU General
# Public License, either Version 2, June 1991 or Version 3, June 2007.

# The script is used to generate pdf repport for pipeline


from reportlab.pdfgen import canvas
import PIL
import os
import sys
import argparse
from datetime import date, time, datetime

# creation du parse des arguments
parser = argparse.ArgumentParser(description="Create PDF report. Ex : ./createPdf.py -org mm9")
 
# declaration et configuration des arguments
parser.add_argument('-org', '--organism', type=str, action="store", default="", help="Organism of the study.")
parser.add_argument('-n', '--projectName', type=str, action="store", default="", help="Name of the study.")
parser.add_argument('-s', '--sampleName', type=str, action="store", default="", help="Sample name of the study.")
parser.add_argument('-fqFormat', '--fastqFormat', type=str, nargs='+', action="store", default="", help="Fastq format.")
parser.add_argument('-nfile', '--fileNumber', type=str, nargs='+', action="store", default="", help="Raw file number of the study.")
parser.add_argument('-genBowtie', '--genomeBowtie', type=str, action="store", default="", help="Genome reference of Bowtie.")
parser.add_argument('-optBowtieCS', '--optionBowtieCS', type=str, action="store", default="", help="Bowtie options for CS file.")
parser.add_argument('-optBowtieFA', '--optionBowtieFA', type=str, action="store", default="", help="Bowtie options for FA file.")
parser.add_argument('-optBowtieFQ', '--optionBowtieFQ', type=str, action="store", default="", help="Bowtie options for FQ file.")
parser.add_argument('-annotFiles', '--annotationFiles', type=str, nargs='+', action="store", default="", help="Annotation file.")
parser.add_argument('-annotDirect', '--annotationDirection', type=str, action="store", default="", help="Annotation direction.")
parser.add_argument('-pdfDirect', '--pdfDirection', type=str, action="store", default="", help="Pdf direction.")
parser.add_argument('-picDirect', '--picDirection', type=str, action="store", default="", help="Pic direction.")

 
# dictionnaire des arguments
dargs = vars(parser.parse_args())

pageNumber=0


############### Function ##############################

def writeCenterString(canvas,y,string,font,size):
	PAGE_WIDTH  = 580
	canvas.setFont(font,size)
	canvas.drawCentredString(PAGE_WIDTH/2.0,y,string)

def writeLeftString(canvas,y,string,font,size):
	canvas.setFont(font,size)
	canvas.drawString(50,y,string)

def writeLeft_Tab_String(canvas,y,string,font,size):
	canvas.setFont(font,size)
	canvas.drawString(100,y,string)

def writePageNumber(canvas,pageNumber):
	canvas.setFont("Times-Roman",12)
	canvas.drawString(530,30,str(pageNumber))

c = canvas.Canvas("Analysis_report_ncPRO-seq.pdf")
c.setTitle("Analysis_report_ncPRO-seq")

####### page 1 ###########

#os.path.isdir() -> retourne True ou False
#os.path.isfile() -> retourne True ou False

today = datetime.now()


c.drawImage(dargs["pdfDirection"]+"/ncPRO_logo.png",230,750,width=140,height=80)
writeCenterString(c,730,"Annotation and Profiling of ncRNAs from smallRNA-seq","Times-Roman",18)
c.line(50,700,550,700)

writeCenterString(c,550,"ncPRO-seq Analysis Report","Times-Roman",18)
writeCenterString(c,520,str(today.date()),"Times-Roman",18)
writeCenterString(c,490,dargs["projectName"],"Times-Roman",18)

#if len(tabName)== 1:
writeLeftString(c,430,"Sample(s) name(s) : ","Times-Roman",18)
#else : 
#	writeLeftString(c,430,"Samples names : ","Times-Roman",18)

tabName = dargs["sampleName"].split(",")

#print(tabName)

text = ""
length = 0
ysize = 410

for sample in tabName :
	length = length + c.stringWidth(sample,"Times-Roman",18)
	
	if length < 470 :
		text = text + sample + "    "
		writeLeftString(c,ysize,text,"Times-Roman",18)
	else : 
		length = 0
		text = sample + "    "
		ysize = ysize - 20
		writeLeftString(c,ysize,text,"Times-Roman",18)


writeCenterString(c,220,"Version : 1.6.1","Times-Roman",18)
writeCenterString(c,200,"Organism : "+dargs["organism"],"Times-Roman",18)

fileAnnot = open(dargs["annotationDirection"]+"/"+dargs["organism"]+"/annotation.version","r")
for line in fileAnnot : 
	tab = line.split("\t")
	
	if tab[0] == "mature_miRNA" : 
		writeCenterString(c,180,"miRBase version : "+tab[1].replace("\n",""),"Times-Roman",18)
	if tab[0] == "rfam" : 
		writeCenterString(c,160,"rfam version : "+tab[1].replace("\n",""),"Times-Roman",18)

fileAnnot.close()


c.line(50,80,550,80)
writeCenterString(c,50,"© Institut Curie - 2012 | Last modified: January 2015 | Contact : bioinfo-ncproseq@curie.fr","Times-Roman",14)

c.showPage()

####### page 2 ###########

# Mettre des paramètres

pageNumber = c.getPageNumber()

writeLeftString(c,780,"Parameters","Times-Italic",18)
writeLeftString(c,730,"Number of raw file(s) : "+str(len(dargs["fileNumber"])),"Times-Roman",12)

nbrSolexa = 0
nbrSolexa1_3 = 0
nbrPhred33 = 0

for formatFile in dargs["fastqFormat"]:
	if formatFile=="solexa":
		nbrSolexa = nbrSolexa + 1
	if formatFile=="solexa1.3":
		nbrSolexa1_3 = nbrSolexa1_3 + 1
	if formatFile=="phred33":
		nbrPhred33 = nbrPhred33 + 1

writeLeftString(c,710,"Fastq format (solexa) : " + str(nbrSolexa),"Times-Roman",12)
writeLeftString(c,690,"Fastq format (solexa1.3) : "+ str(nbrSolexa1_3),"Times-Roman",12)
writeLeftString(c,670,"Fastq format (phred33) : "+ str(nbrPhred33),"Times-Roman",12)
writeLeftString(c,650,"Bowtie : ","Times-Roman",12)
writeLeft_Tab_String(c,630,"- genome reference : "+ dargs["genomeBowtie"],"Times-Roman",12)
writeLeft_Tab_String(c,610,"- options (fasta) : "+ dargs["optionBowtieFA"],"Times-Roman",12)
writeLeft_Tab_String(c,590,"- options (fastq) : "+ dargs["optionBowtieFQ"],"Times-Roman",12)
writeLeft_Tab_String(c,570,"- options (color space) : "+ dargs["optionBowtieCS"],"Times-Roman",12)
writeLeftString(c,550,"Annotation files : ","Times-Roman",12)
writeLeft_Tab_String(c,530,"- organism reference : "+ dargs["organism"],"Times-Roman",12)


numberAnnotFile = 4
tabFlag = [0] * numberAnnotFile

for annotationFile in dargs["annotationFiles"]:
	tabAnno = annotationFile.split("/")
	if "precursor_miRNA.gff" in tabAnno:
		tabFlag[0] = 1
	if "rfam.gff" in tabAnno:
		tabFlag[1] = 1
	if "rmsk.gff" in tabAnno:
		tabFlag[2] = 1
	if "coding_gene.gff" in tabAnno:
		tabFlag[3] = 1

if tabFlag[0] == 1 :
	writeLeft_Tab_String(c,510,"- precursor miRNA file : yes","Times-Roman",12)
else : 
	writeLeft_Tab_String(c,510,"- precursor miRNA file : no","Times-Roman",12)

if tabFlag[1] == 1 :
	writeLeft_Tab_String(c,490,"- rfam file : yes","Times-Roman",12)
else : 
	writeLeft_Tab_String(c,490,"- rfam file : no","Times-Roman",12)

if tabFlag[2] == 1 :
	writeLeft_Tab_String(c,470,"- rmsk file : yes","Times-Roman",12)
else : 
	writeLeft_Tab_String(c,470,"- rmsk file : no","Times-Roman",12)

if tabFlag[3] == 1 :
	writeLeft_Tab_String(c,450,"- coding gene file : yes","Times-Roman",12)
else : 
	writeLeft_Tab_String(c,450,"- coding gene file : no","Times-Roman",12)


writePageNumber(c,pageNumber)
c.showPage()

####### page 3 ###########

pageNumber = c.getPageNumber()

writeLeftString(c,780,"I - Raw Data Quality Control","Times-Italic",18)
writeLeftString(c,750,"1) Base Composition Information","Times-BoldItalic",15)
writeLeftString(c,730,"The base composition across all positions is represented of the read in each library. ","Times-Roman",12)
writeLeftString(c,710,"All base frequencies at each position are expected to be done to 25%.","Times-Roman",12)
c.drawImage(dargs["picDirection"]+"/plotBase.png",80,410,width=450,height=250)
c.drawImage(dargs["picDirection"]+"/plotBaseGC.png",97,60,width=450,height=300)

writePageNumber(c,pageNumber)
c.showPage()

####### page 4 ###########

pageNumber = c.getPageNumber()

writeLeftString(c,780,"2) Quality Score","Times-BoldItalic",15)
writeLeftString(c,760,"The mean quality across all positions is represented of the read in each library.","Times-Roman",12)
writeLeftString(c,740,"The better is the quality, the better are the libraries.","Times-Roman",12)
c.drawImage(dargs["picDirection"]+"/plotMeanQuality.png",90,430,width=450,height=300)
writeLeftString(c,410,"3) Distinct Reads Length Distribution","Times-BoldItalic",15)
writeLeftString(c,390,"Distribution of distinct sequences length in all libraries.","Times-Roman",12)
c.drawImage(dargs["picDirection"]+"/plotDistinctReadSize.png",90,80,width=450,height=300)

writePageNumber(c,pageNumber)
c.showPage()

####### page 5 ###########

pageNumber = c.getPageNumber()

writeLeftString(c,780,"4) Abundant Reads Length Distribution","Times-BoldItalic",15)
writeLeftString(c,760,"Distribution of reads length in all librairies.","Times-Roman",12)
c.drawImage(dargs["picDirection"]+"/plotReadSize.png",90,430,width=450,height=300)

writePageNumber(c,pageNumber)
c.showPage()

####### page 6 ###########

pageNumber = c.getPageNumber()

writeLeftString(c,780,"II - Reads Mapping on Reference Genome","Times-Italic",18)
writeLeftString(c,750,"1) Mapping Proportion","Times-BoldItalic",15)
writeLeftString(c,730,"Proportions of reads that can be mapped to the reference genome for each library.","Times-Roman",12)
c.drawImage(dargs["picDirection"]+"/plotGenomeMapping.png",100,190,width=450,height=500)

writePageNumber(c,pageNumber)
c.showPage()

####### page 7 ###########

pageNumber = c.getPageNumber()

writeLeftString(c,780,"2) Distinct Reads Length Distribution","Times-BoldItalic",15)
writeLeftString(c,760,"Distribution of aligned distinct sequences length in all librairies.","Times-Roman",12)
c.drawImage(dargs["picDirection"]+"/plotGenomeMappingDistinctReadSize.png",90,430,width=450,height=300)
writeLeftString(c,410,"3) Abundant Reads Length Distribution","Times-BoldItalic",15)
writeLeftString(c,390,"Distribution of aligned reads length in all libraries.","Times-Roman",12)
c.drawImage(dargs["picDirection"]+"/plotGenomeMappingReadSize.png",90,80,width=450,height=300)

writePageNumber(c,pageNumber)
c.showPage()

####### page 8 ###########

pageNumber = c.getPageNumber()

writeLeftString(c,780,"III - Annotation of non-conding RNAs","Times-Italic",18)
writeLeftString(c,750,"1) Reads Annotation Overview","Times-BoldItalic",15)
writeLeftString(c,730,"Proportions of reads that were associated to genomic features in each library.","Times-Roman",12)
c.drawImage(dargs["picDirection"]+"/plotReadAnnOverview.png",100,190,width=450,height=500)

writePageNumber(c,pageNumber)
c.showPage()

####### page 9 ###########

pageNumber = c.getPageNumber()

writeLeftString(c,780,"2) Precursor miRNAs Annotation","Times-BoldItalic",15)
writeLeftString(c,760,"Proportions of reads that were associated to pre-miRNAs features in each library.","Times-Roman",12)
c.drawImage(dargs["picDirection"]+"/plotmiRNAmapping.png",100,220,width=450,height=500)

writePageNumber(c,pageNumber)
c.showPage()

####### page 10 ###########

pageNumber = c.getPageNumber()

writeLeftString(c,780,"3) Annotation of ncRNAs from RFAM","Times-BoldItalic",15)
writeLeftString(c,760,"Detailed composition of ncRNAs associated reads.","Times-Roman",12)
c.drawImage(dargs["picDirection"]+"/plotRfamClassOverviewExp.png",100,220,width=450,height=500)

writePageNumber(c,pageNumber)
c.showPage()

####### page 11 ###########

pageNumber = c.getPageNumber()

writeLeftString(c,780,"4) Annotation of Repetitive Regions","Times-BoldItalic",15)
writeLeftString(c,760,"Detailed composition of repeats associated reads.","Times-Roman",12)
c.drawImage(dargs["picDirection"]+"/plotRmskClassOverviewExp.png",100,220,width=450,height=500)

writePageNumber(c,pageNumber)
c.showPage()

########## page si heatmap #############

listFiles = os.listdir(dargs["picDirection"]+"/")

flag = 0

for i in listFiles : 
	if "miRNA" in i and "heatmap" in i :

		pageNumber = c.getPageNumber()

		if flag == 0 :
			writeLeftString(c,780,"5) Hierarchical clustering","Times-BoldItalic",15)
			writeLeftString(c,760,"Hierarchical clustering from the most variant miRNAs (euclidean, ward).","Times-Roman",12)
		
		c.drawImage(dargs["picDirection"]+"/"+i,80,100,width=550,height=600)

		writePageNumber(c,pageNumber)
		c.showPage()
		flag = 1


####### Fermeture du PDF ###########

c.save()


	






