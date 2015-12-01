#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyleft ↄ⃝ 2012 Institut Curie
# Author(s): Jocelyn Brayet, Laurene Syx, Chongjian Chen, Nicolas Servant(Institut Curie) 2012 - 2015
# Contact: bioinfo.ncproseq@curie.fr
# This software is distributed without any guarantee under the terms of the GNU General
# Public License, either Version 2, June 1991 or Version 3, June 2007.

# The script is used to generate grouped file (no repetition) for edgeR or DEseq


import argparse


parser = argparse.ArgumentParser(description="Group subfamcov files. Ex : ./groupFiles.py -i inputfile")

parser.add_argument('-i', '--inputFile', type=str, action="store", default="", help="global subfamcov file.")

dargs = vars(parser.parse_args())

subfamcovFile = open(dargs["inputFile"], "r")

readsDict = {}
firstline = ""

for line in subfamcovFile:
    
    if not line.startswith("idx"):

        line = line.replace("\n","")
        tabline = line.split("\t")
        
        if not tabline[0] in readsDict:
            readsDict[tabline[0]] = tabline[1]
        else:
            value = float(readsDict[tabline[0]])+float(tabline[1])
            readsDict[tabline[0]] = value

    else :

        firstline = line.replace("\n","")


subfamcovFile.close()


#print firstline

for read in readsDict:

    print(str(read)+"\t"+str(readsDict[read]))










