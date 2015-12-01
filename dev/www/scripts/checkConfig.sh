#!/bin/bash

# Copyleft ↄ⃝ 2012 Institut Curie
# Author(s): Jocelyn Brayet, Laurene Syx, Chongjian Chen, Nicolas Servant(Institut Curie) 2012 - 2015
# Contact: bioinfo.ncproseq@curie.fr
# This software is distributed without any guarantee under the terms of the GNU General
# Public License, either Version 2, June 1991 or Version 3, June 2007.

##
## This script is used to check the config-sytem file before installation
## Each required tool is tested, as well as apache system
##


NORMAL="\\033[0;39m" 
RED="\\033[1;31m"
BLUE="\\033[0;34m"


## Check environment variable
function searchENV {
    var=$1
    envvar="\$$3"
    if [ -n "${envvar:-x}" ]; then
	val=`eval echo ${envvar}`
	#export $var=$val
	echo "$var = $val" >> config-checked
	echo -e "\nWarning : '$1' not found - replaced by ENV variable '$3'"
    else
	echo -e "$RED""\nError : '$1' not found at '$2'""$NORMAL"
	rm config-checked
	exit 1
    fi			
}
##searchEnv

## Check executable variable
function searchBIN {
    binname=$3
    nval=`which $binname`

    if [[ $nval != "" ]]; then
	nval=`dirname $nval`
    	val=$nval
	#export $1=$nval
	echo "$1 = $nval" >> config-checked
	echo -e "\nWarning : '$1' not found at '$2' - replaced by '$nval'"
    else
	echo -e "$RED""\nError : '$1' not found at '$2'""$NORMAL"
	rm config-checked
	exit 1
    fi
}
##searchBIN

## Usage
function usage {
    echo -e "Usage : ./checkConfig.sh"
    echo -e "-c"" <configuration file>"
    echo -e "-h"" <help>"
    exit;
}


################### Initialize ###################

set -- $(getopt c: "$@")
while [ $# -gt 0 ]
do
    case "$1" in
	(-c) ncrna_conf=$2; shift;;
	(-h) usage;;
	(--) shift; break;;
	(-*) echo "$0: error - unrecognized option $1" 1>&2; exit 1;;
	(*)  break;;
    esac
    shift
done

if [ -e config-checked ]; then
    rm config-checked
fi

################### Read the config file ###################

while read curline_read; do
    curline=${curline_read// /}
    if [[ $curline != \#* && ! -z $curline ]]; then
	var=`echo $curline | awk -F= '{print $1}'`
	val=`echo $curline | awk -F= '{print $2}'`

	if [[ $var == "" ]]
	then
	    val=" "
	fi

	if [[ $var =~ "_PATH" ]]
	then
	    echo -e -n "\nChecking $var ... "
	    if [[ ! -e $val && ! -h $val ]]; then
## R
		if [[ $var == "R_PATH" ]]; then
		    searchBIN "$var" "$val" "R"		    
## BEDTOOLS		
		elif [[ $var == "BEDTOOLS_PATH" ]]; then
		    searchBIN "$var" "$val" "intersectBed"
## BOWTIE INDEXES
 		elif [[ $var == "BOWTIE_INDEXES_PATH" ]]; then
		    searchENV "$var" "$val" "BOWTIE_INDEXES"
## BOWTIE
		elif [[ $var =~ "BOWTIE_PATH" ]]; then
		    searchBIN "$var" "$val" "bowtie"
## CONVERT
		elif [[ $var =~ "CONVERT_PATH" ]]; then
	       	    searchBIN "$var" "$val" "convert"
## AWK
		elif [[ $var =~ "AWK_PATH" ]]; then
		    searchBIN "$var" "$val" "awk"
## SAMTOOLS
		elif [[ $var =~ "SAMTOOLS_PATH" ]]; then
		    searchBIN "$var" "$val" "samtools"
## bamMapCount
		elif [[ $var =~ "BAM_MAPCT_PATH" ]]; then
		    searchBIN "$var" "$val" "bamMapCount"
## PERL
		elif [[ $var =~ "PERL_PATH" ]]; then
		    searchBIN "$var" "$val" "perl"
## python
		elif [[ $var =~ "PYTHON_PATH" ]]; then
		    searchBIN "$var" "$val" "python"


		else
## Optional config
		    if [[ $var != "MAILX_PATH" && $var != "PBS_PATH" ]]
		    then
			echo -e "\nError : Unknown System variable $var."
			rm config-checked
			exit
		    fi
		fi
	    else
		echo -n "OK."
		#export $var=$val
		if [[ $var == "BEDTOOLS_PATH" ]]; then
		    export PATH=$PATH:$val
		elif [[ $var == "BOWTIE_INDEXES_PATH" ]]; then
		    export BOWTIE_INDEXES=$val
		fi
		
		echo $curline_read >> config-checked
	    fi
	else
	    echo $curline_read >> config-checked  
	fi
    else
	echo $curline_read >> config-checked
    fi
done < $ncrna_conf

### Check LANG
if [ "$LANG" != "C" ]; then
    echo -e "\nWarning : Changing LANG setting to 'C'."
    export LANG=C
fi

echo -e "System check OK."




