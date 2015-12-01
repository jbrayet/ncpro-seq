#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyleft ↄ⃝ 2012 Institut Curie
# Author(s): Jocelyn Brayet, Laurene Syx, Chongjian Chen, Nicolas Servant(Institut Curie) 2012 - 2015
# Contact: bioinfo.ncproseq@curie.fr
# This software is distributed without any guarantee under the terms of the GNU General
# Public License, either Version 2, June 1991 or Version 3, June 2007.

# The script is used to generate grouped file for edgeR or DEseq


import argparse

parser = argparse.ArgumentParser(description="Delete repetition in bed files. Ex : ./deleteRepetition.py -i inputfile")

parser.add_argument('-i', '--inputFile', type=str, action="store", default="", help="Bed file.")

dargs = vars(parser.parse_args())

bedFile = open(dargs["inputFile"], "r")

line = bedFile.readline()

tab_lastLine = line.split("\t")

for line in bedFile:
	
	tab_nextLine = line.split("\t")

	if not (tab_lastLine[0]==tab_nextLine[0] and tab_lastLine[1]==tab_nextLine[1] and tab_lastLine[2]==tab_nextLine[2] and tab_lastLine[3]==tab_nextLine[3]):

		print(str(tab_lastLine).replace(",","\t").replace("'","").replace("[","").replace("]","").replace("\\n",""))
		tab_lastLine = tab_nextLine

bedFile.close()




