#!/bin/bash

# Copyleft ↄ⃝ 2012 Institut Curie
# Author(s): Jocelyn Brayet, Laurene Syx, Chongjian Chen, Nicolas Servant(Institut Curie) 2012 - 2015
# Contact: bioinfo.ncproseq@curie.fr
# This software is distributed without any guarantee under the terms of the GNU General
# Public License, either Version 2, June 1991 or Version 3, June 2007.

##
## This script aims in installing the ncPRO-seq pipeline.
## All dependencies have to be installed (see ./install_prereqs_ncPRO.sh)
## and have to pass the check (./scripts/checkConfig.sh)
##

NORMAL="\\033[0;39m" 
RED="\\033[1;31m"

die() {
    echo -e "$RED""$*""$NORMAL" 1>&2
    exit 1
}


## Check done ?
if [ ! -e config-checked ]; then
    echo -e "$RED""Error during Check process. Installation aborted. Please check the config-ssytem file using the ./scripts/checkConfig.sh script.""$NORMAL"
    exit 1
fi

################ Read config-system file ###################

while read curline; do
    if [[ $curline != \#* && ! -z $curline ]]; then
	var=`echo $curline | awk -F= '{print $1}'`
	val=`echo $curline | awk -F= '{printf $2;for (i=3;i<=NF;i++){printf "="$i};}'`
	var=${var// /}
	val=${val/# /}
	declare $var="$val"
    fi
done < config-checked

################ ncPRO-seq command-line version ###################

## Check Install Directory

if [ -d $APPLI_DIR ]; then
    echo "The $APPLI_DIR already exists. Delete the folder before installation and continue ? (y/n) [n] : ";
    read ans;
    if [ XX${ans} = XXy ]; then
	rm -rf $APPLI_DIR
	mkdir $APPLI_DIR
    else
	exit 1
    fi
else
    mkdir $APPLI_DIR || die "Cannot create installation folder"
fi

echo;
## Copy in installation folder
echo -n "Installing html files ..."
cp -r www/html $APPLI_DIR/ || die "Files installation failed"
echo "OK."
echo -n "Installing manuals ..."
cp -r manuals $APPLI_DIR/ || die "Files installation failed"
echo "OK."
echo -n "Installing scripts ..."
cp -r scripts $APPLI_DIR/ || die "Files installation failed"
echo "OK."
echo -n "Installing binaries ..."
cp -r bin $APPLI_DIR/ || die "Files installation failed"
echo "OK."
echo -n "Copying annotation files ..."
mkdir $APPLI_DIR/annotation/
cp -r annotation/* $APPLI_DIR/annotation/
echo "OK."|| die "Files installation failed"
echo -n "Copying configuration files ..."
cp Makefile config-ncrna.txt $APPLI_DIR/ || die "Files installation failed" 
mv config-checked $APPLI_DIR/config-system.txt
echo "OK."

echo -e "$RED""\nncPRO-seq Commande-line version installed with success in '$APPLI_DIR'\n""$NORMAL"

################ ncPRO-seq web version ###################

if [ $INSTALL_WWW -eq 1 ]; then

    ## APACHE
    ps aux | egrep '(apache|httpd)' | grep -v egrep > /dev/null
    if [ $? != "0" ]; then
	echo "$RED""Apache not appears to run on your system. Please check if it is installed by looking at http://localhost. Do you want to continue ? (y/n) [n]""$NORMAL"
	read ans;
	if [ XX${ans} != XXy ]; then
	    exit 1;
	fi
    fi

    ## Check Web Directory
    if [ -d $WWW_DIR ];  then
	echo "The $WWW_DIR already exists. Delete the folder before installation and continue ? (y/n) [n] : ";
	read ans;
	if [ XX${ans} = XXy ]; then
	    rm -rf $WWW_DIR
	    mkdir $WWW_DIR
	else
	    exit 1
	fi
    else
	mkdir $WWW_DIR || die "Cannot create www folder"
    fi

    if [ -d $CGI_DIR ]; then
	echo "The $CGI_DIR already exists. Delete the folder before installation and continue ? (y/n) [n] : ";
	read ans;
	if [ XX${ans} = XXy ]; then
	    rm -rf $CGI_DIR
	    mkdir $CGI_DIR
	else
	    exit 1
	fi
    else
	mkdir $CGI_DIR || die "Cannot create CGI folder"
    fi

    echo;
    
    ## Web application
    echo -n "Installing local web application ..."
    cp -r www/html/* $WWW_DIR || die "Files installation failed" 
    cp www/cgi-bin/* $CGI_DIR || die "Files installation failed" 
    
    ##Create www config file
    www_conf=$WWW_DIR/config_html.inc
    echo "<?" > $www_conf
    echo "define(\"CGI_DIR\",\"$CGI_DIR\");" >> $www_conf
    echo "?>"  >> $www_conf

    www_conf=$CGI_DIR/config_cgi.inc
    echo "INSTALL_DIR = $APPLI_DIR" > $www_conf
    echo "OUTPUT = $WWW_DIR/output" >> $www_conf
    echo "PBS_OPT = $PBS_OPT"  >> $www_conf
    echo "PBS_MODE = $PBS_MODE" >> $www_conf
    echo "PBS_PATH = $PBS_PATH" >> $www_conf
    
    if [ ! -d $WWW_RES ]; then
	mkdir $WWW_RES
    fi
    if [ ! -e $WWW_DIR/output ]; then
	ln -s $WWW_RES $WWW_DIR/output
    fi
    if [ ! -e $APPLI_DIR/install_dir ]; then
	ln -s $APPLI_DIR $WWW_DIR/install_dir
    fi
    echo -e "$RED""\nncPRO-seq Web tool installed with success in '$WWW_DIR/'""$NORMAL"
fi

