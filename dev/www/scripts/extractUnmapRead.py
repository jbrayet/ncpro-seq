#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyleft ↄ⃝ 2012 Institut Curie
# Author(s): Jocelyn Brayet, Laurene Syx, Chongjian Chen, Nicolas Servant(Institut Curie) 2012 - 2015
# Contact: bioinfo.ncproseq@curie.fr
# This software is distributed without any guarantee under the terms of the GNU General
# Public License, either Version 2, June 1991 or Version 3, June 2007.

# The script is used to extract read unmapped.

import os
import sys
import argparse

# creation du parse des arguments
parser = argparse.ArgumentParser(description="Extract read unmapped by sam files. Ex : ./extractUnmapRead.py -i samFile.sam")
 
# declaration et configuration des arguments
parser.add_argument('-i', '--inputFile', type=str, action="store", default="", help="Sam file")
 
# dictionnaire des arguments
dargs = vars(parser.parse_args())

acces = os.getcwd()+"/"
samFile = open(acces+dargs["inputFile"],"r")

#count = 0

for line in samFile :

	if not(line.startswith("@")) :

		tabLine = line.split("\t")

		if tabLine[1] == '4' :

			#tabCount = tabLine[0].split("_")
			#count = count + int(tabCount[1])
			print(tabLine[0]+"\t"+tabLine[9])

#print(count)

samFile.close()

