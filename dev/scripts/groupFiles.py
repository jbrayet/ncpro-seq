#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyleft ↄ⃝ 2012 Institut Curie
# Author(s): Jocelyn Brayet, Laurene Syx, Chongjian Chen, Nicolas Servant(Institut Curie) 2012 - 2015
# Contact: bioinfo.ncproseq@curie.fr
# This software is distributed without any guarantee under the terms of the GNU General
# Public License, either Version 2, June 1991 or Version 3, June 2007.

# The script is used to generate grouped file for edgeR or DEseq


import argparse

parser = argparse.ArgumentParser(description="Group subfamcov files. Ex : ./groupFiles.py -i inputfile")

parser.add_argument('-i', '--inputFile', type=str, action="store", default="", help="subfamcov file.")

dargs = vars(parser.parse_args())

subfamcovFile = open(dargs["inputFile"], "r")

for line in subfamcovFile:
	
	if not line.startswith("idx"):

		line = line.replace("\n","")
		print(line)


subfamcovFile.close()

