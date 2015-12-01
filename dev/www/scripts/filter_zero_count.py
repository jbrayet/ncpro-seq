#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyleft ↄ⃝ 2012 Institut Curie
# Author(s): Jocelyn Brayet, Laurene Syx, Chongjian Chen, Nicolas Servant(Institut Curie) 2012 - 2015
# Contact: bioinfo.ncproseq@curie.fr
# This software is distributed without any guarantee under the terms of the GNU General
# Public License, either Version 2, June 1991 or Version 3, June 2007.

# The script is used to add miRNAs with 0 reads in all samples in result file.

import os
import argparse


# creation du parse des arguments
parser = argparse.ArgumentParser(description="Add miRNAs with 0 reads in all samples in result file. Ex : ./filter_zero_count.py -i miRNA_aligned_file -p miRNA_annotation_file")

# declaration et configuration des arguments
parser.add_argument('-i', '--miRNA_aligned_file', type=str, action="store", default="", help="miRNA aligned file")
parser.add_argument('-p', '--miRNA_annotation_file', type=str, action="store", default="", help="miRNA annotation file")

# dictionnaire des arguments
dargs = vars(parser.parse_args())

# Open miRNA annotation file
allmiRNAfile = open(dargs["miRNA_annotation_file"],"r")

# Create allmiRNA object. It s a set type
allmiRNA = set()

# Read annotation file line by line 
for line in allmiRNAfile :

	# If line is not a comment
	if not line.startswith("#"):

		# Split line by ";" and stock element in a tab
		tabLine = line.split(";")
		# Add third tab element in allmiRNA. Replace Name= by nothing (i.e. : Name=mmu-mir-29c -> mmu-mir-29)
		allmiRNA.add(tabLine[2].replace("Name=",""))

# Close miRNA annotation file
allmiRNAfile.close()

# Open miRNA aligment file
miRNAalignedFile = open(dargs["miRNA_aligned_file"],"r")

# Create miRNAaligned object. It s a set type
miRNAaligned = set()
# Create sampleNumber object. It s an int type
sampleNumber = 0

# Read aligment file line by line 
for line in miRNAalignedFile :

	# Write line in a new file and replace \n by nothing.
	print(line.replace("\n",""))

	# If line does not start by "idx" (first line)
	if not line.startswith("idx"):

		# Split line by "\t" and stock element in a tab
		tabLine = line.split("\t")
		# Add first tab element in miRNAaligned.
		miRNAaligned.add(tabLine[0])

	# Else, if line starts by idx (first line)
	else :

		# Split line by "\t" and stock element in a tab
		tabLine = line.split("\t")
		# Count element number in tab - 1 : it s number of sample
		sampleNumber = len(tabLine) - 1

# Close miRNA aligment file
miRNAalignedFile.close()

# Difference between two sets : miRNAs don t aligned in a reference genome. 
difference = allmiRNA-miRNAaligned

# Read difference set miRNA by miRNA
for miRNA in difference:

	# Write miRNA with 0 read copy in a new file for each sample. 
	print(miRNA.replace("\n","")+str("\t0"*sampleNumber))




