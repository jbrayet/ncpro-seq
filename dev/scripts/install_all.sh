#!/bin/bash

# Copyleft ↄ⃝ 2012 Institut Curie
# Author(s): Jocelyn Brayet, Laurene Syx, Chongjian Chen, Nicolas Servant(Institut Curie) 2012 - 2015
# Contact: bioinfo.ncproseq@curie.fr
# This software is distributed without any guarantee under the terms of the GNU General
# Public License, either Version 2, June 1991 or Version 3, June 2007.

##
## This script aims in installing most of the dependies of the ncPRO-seq tool.
## Serval checks are done to ensure compilation of code.
## In case of error, please look at the ncPRO manual for additional informations.
##
##


NORMAL="\\033[0;39m"
RED="\\033[0;31m"
BLUE="\\033[0;34m"

NCPRO=ncproseq_v1.6.5

die() {
    echo -e "$RED""Exit - ""$*""$NORMAL" 1>&2
    exit 1
}

function usage {
    echo -e "Usage : ./install_all.sh"
    echo -e "-c"" <configuration file>"
    echo -e "-h"" <help>"
    exit;
}

echo -e "$RED""Make sure internet connection works for your shell prompt under current user's privilege ...""$NORMAL";
echo -e "$BLUE""Starting ncPRO-seq installation ...""$NORMAL";


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

################### Read the config file ###################

while read curline_read; do
    curline=${curline_read// /}
    if [[ $curline != \#* && ! -z $curline ]]; then
	var=`echo $curline | awk -F= '{print $1}'`
	val=`echo $curline | awk -F= '{print $2}'`

	if [[ $var =~ "_PATH" ]]
	then
	    if [[ ! -z $val ]]; then
		export PATH=$PATH:$val
	    fi
	fi
    fi
done < $ncrna_conf

################### Search standard tools ###################

#check for make
which make > /dev/null;
if [ $? != "0" ]; then
	echo -e "$RED""Can not proceed without make, please install and re-run (Mac users see: http://developer.apple.com/technologies/xcode.html)""NORMAL"
	exit 1;
fi

#check for g++
which g++ > /dev/null;
if [ $? != "0" ]; then
	echo -e "$RED""Can not proceed without g++, please install and re-run""NORMAL"
	exit 1;
fi

# check for unzip (bowtie)
which unzip > /dev/null;
if [ $? != "0" ]; then
    echo -e "$RED""Can not proceed without unzip, please install and re-run""NORMAL"
    exit 1;
fi

# C++ libraries
if [ ! -e /usr/include/zlib.h ]; then
    echo -e "$RED""Warning : zlib.h not found. Needed for samtools and BEDTools compilation""$NORMAL"
    exit 1;
fi

if [ ! -e /usr/include/ncurses.h ]; then
    echo -e "$RED""Warning : ncurses.h not found. Needed for samtools and BEDTools compilation""$NORMAL"
    exit 1;
fi

# awk
which awk > /dev/null;
if [ $? != "0" ]; then
    echo -e "$RED""Can not proceed without awk, please install and re-run""NORMAL"
    exit 1;
fi

# perl
which perl > /dev/null;
if [ $? != "0" ]; then
    echo -e "$RED""Can not proceed without Perl, please install and re-run""NORMAL"
    exit 1;
fi

############################## rajout 2015 ########################################

# python

which python > /dev/null;
if [ $? != "0" ]; then
    echo -e "$RED""Can not proceed without Python, please install and re-run""NORMAL"
    exit 1;
fi

###################################################################################

#check OS (Unix/Linux or Mac)
os=`uname`;

# get the right download program
if [ "$os" = "Darwin" ]; then
	# use curl as the download program 
	get="curl -L -o"
else
	# use wget as the download program
	get="wget --no-check-certificate -O"
fi

if [ -d ./tmp_ncPRO ]; then
    rm -r ./tmp_ncPRO
fi
mkdir ./tmp_ncPRO
cd ./tmp_ncPRO

################ Install dependencies  ###################

PREFIX_BIN=/usr/bin

if [ ! -w $PREFIX_BIN ]; then
    PREFIX_BIN=${HOME}/bin;
fi

echo "Where should missing software prerequisites be installed ? [$PREFIX_BIN] "
read ans
ans=${ans:-$PREFIX_BIN}
PREFIX_BIN=$ans
if [ ! -d $PREFIX_BIN ]; then
    echo "Directory $PREFIX_BIN does not exist!"
    echo -n "Do you want to create $PREFIX_BIN folder ? (y/n) [n] : "
    read ans
    if [ XX${ans} = XXy ]; then
        mkdir $PREFIX_BIN || die "Cannot create  $PREFIX_BIN folder. Maybe missing super-user (root) permissions"
    else
        die "Must specify a directory to install required softwares!"
    fi
fi

if [ ! -w $PREFIX_BIN ]; then
    die "Cannot write to directory $PREFIX_BIN. Maybe missing super-user (root) permissions to write there.";
fi 

export PATH=$PREFIX_BIN:$PREFIX_BIN/convert/bin:$PATH

################  R/BioConductor  ###################

echo;
wasInstalled=0;
which R > /dev/null;
if [ $? == "0" ]; then
    #some R tests
    echo "Checking R installation ..."
    R CMD BATCH ../scripts/install_packages_check.R > install_packages_check.Rout
    check=`grep proc.time install_packages_check.Rout`;
    if [ $? == "0" ]; then
	echo -n -e "$BLUE""The required R packages appear to be already installed. ""$NORMAL"
	wasInstalled=1;
    fi
else
    echo -e "$RED""Can not proceed without R, please install and re-run""NORMAL"
    exit 1;
fi

echo -n "Would you like to install/re-install the R packages [RColorBrewer, girafe, seqLogo] ? (y/n) [n] : "
read ans
if [ XX${ans} = XXy ]; then
    echo "Installing new packages ..."
    R CMD BATCH ../scripts/install_packages.R install_packages.Rout
    wasInstalled=0;
fi

#some R tests
if [ $wasInstalled == 0 ]; then
    R CMD BATCH ../scripts/install_packages_check.R > install_packages_check.Rout
    check=`grep proc.time install_packages_check.Rout`;
    if [ $? == "0" ]; then
	echo -e "$BLUE""R/BioConductor packages appear to be installed successfully""$NORMAL"
    else
	echo -e "$RED""R/BioConductor packages NOT installed successfully. Look at the tmp_ncPRO/install_packages.Rout for additional informations""$NORMAL"; exit 1;
    fi
fi
################ Bowtie ###################
echo;
echo  "Checking dependencies ... "

#is already installed
wasInstalled=0;
which bowtie > /dev/null;
if [ $? = "0" ]; then
	echo -e -n "$BLUE""Bowtie Aligner appears to be already installed. ""$NORMAL"
	wasInstalled=1;
fi

echo -n "Would you like to install/re-install Bowtie? (y/n) [n] : "
read ans
if [ XX${ans} = XXy ]; then
    $get bowtie-1.1.2-src.zip http://sourceforge.net/projects/bowtie-bio/files/bowtie/1.1.2/bowtie-1.1.2-src.zip
    unzip bowtie-1.1.2-src.zip
    cd bowtie-1.1.2
    make
    cp bowtie* $PREFIX_BIN
    cd ..
    wasInstalled=0;
fi
 
#some bowtie tests
if [ $wasInstalled == 0 ]; then
    check=`bowtie --version 2>&1`;
    if [ $? = "0" ]; then
	echo -e "$BLUE""Bowtie Aligner appears to be installed successfully""$NORMAL"
    else
	echo -e "$RED""Bowtie Aligner NOT installed successfully""$NORMAL"; exit 1;
    fi
fi

#set BOWTIE_INDEXES variable
if [ -z "$BOWTIE_INDEXES" ]; then
    echo "The BOWTIE_INDEXES has to be set up in your environment (see http://bowtie-bio.sourceforge.net/tutorial.shtml)."
    echo "Please enter the path to the Bowtie index files : "
    read ans
    export BOWTIE_INDEXES=$ans
    chmod 755 $ans
fi			
echo "BOWTIE_INDEXES=$BOWTIE_INDEXES"


################ BEDTools  ###################

#echo;
# is already installed
wasInstalled=0;
which bedtools > /dev/null
if [ $? = "0" ]; then
    bedtools_version=`bedtools --version | cut -d" " -f2`;
    echo -n -e "$BLUE""BEDTools ($bedtools_version) appears to be already installed. Version >2.15 is required. ""$NORMAL"
    wasInstalled=1;
fi

echo -n "Would you like to install/re-install BEDTools ? (y/n) [n] : "
read ans
if [ XX${ans} = XXy ]; then
    #From sources
    $get BEDTools.v2.16.2.tar.gz http://bedtools.googlecode.com/files/BEDTools.v2.16.2.tar.gz
    tar -zxvf BEDTools.v2.16.2.tar.gz
    cd BEDTools-Version-2.16.2
    make clean
    make all
    cp bin/* $PREFIX_BIN
    cd ..
    wasInstalled=0;
fi
  
#some BEDTools tests
if [ $wasInstalled == 0 ]; then
    check=`bedtools 2>&1`;
    if [ $? = "0" ]; then
	echo -e "$BLUE""BEDTools appears to be installed successfully""$NORMAL"
    else
	echo -e "$RED""BEDTools NOT installed successfully""$NORMAL"; exit 1;
    fi
fi


################ BamMapCount  ###################

#echo;
#is already installed
wasInstalled=0;
which bamMapCount > /dev/null
if [ $? = "0" ]; then
    echo -n  -e "$BLUE""BamMapCounts appears to be already installed. ""$NORMAL"
    wasInstalled=1;
fi

echo -n "Would you like to install/re-install the BamMapCount program ? (y/n) [n] : "
read ans
if [ XX${ans} = XXy ]; then
    #From sources
    $get BEDTools_MapCount_ColorTag.tar.gz http://ncpro.curie.fr/src/soft/BEDTools_MapCount_ColorTag.tar.gz
    tar -zxvf BEDTools_MapCount_ColorTag.tar.gz
    cd BEDTools-Version-2.10.0
    make
    cp bin/bamMapCount $PREFIX_BIN
    cd ..
    wasInstalled=0;
fi

if [ $wasInstalled == 0 ]; then
    #some BamMapCount tests
    check=`bamMapCount -h 2>&1 | grep -i options`;
    if [ $? = "0" ]; then
	echo -e "$BLUE""BamMapCounts appears to be installed successfully""$NORMAL"
    else
	echo -e "$RED""BamMapCounts NOT installed successfully""$NORMAL"; exit 1;
    fi
fi

################ samtools  ###################

#echo;
#is already installed
wasInstalled=0;
which samtools > /dev/null
if [ $? = "0" ]; then
	echo -n -e "$BLUE""Samtools appears to be already installed. ""$NORMAL"
	wasInstalled=1;
fi

echo -n "Would you like to install/re-install the Samtools program ? (y/n) [n] : "
read ans
if [ XX${ans} = XXy ]; then
    #From sources
    $get samtools-0.1.18.tar.bz2  http://sourceforge.net/projects/samtools/files/samtools/0.1.18/samtools-0.1.18.tar.bz2/download?use_mirror=freefr
    tar -xvjpf samtools-0.1.18.tar.bz2
    cd samtools-0.1.18
    make
    cp samtools $PREFIX_BIN
    cp bcftools/bcftools $PREFIX_BIN
    cd ..
    wasInstalled=0;
fi

if [ $wasInstalled == 0 ]; then
    check=`samtools view -h 2>&1 | grep -i options`;
    if [ $? = "0" ]; then
	echo -e "$BLUE""samtools appears to be installed successfully""$NORMAL"
    else
	echo -e "$RED""samtools NOT installed successfully""$NORMAL"; exit 1;
    fi
fi

################ imageMagick  ###################

#echo;
wasInstalled=0;
which convert > /dev/null
if [ $? = "0" ]; then
	echo -e -n "$BLUE""Convert appears to be already installed. ""$NORMAL"
fi

echo -n "Would you like to install/re-install the ImageMagick program ? (y/n) [n] : "
read ans
if [ XX${ans} = XXy ]; then

    ##install png decode delegate
    #From sources
    $get libpng-1.5.12.tar.gz http://sourceforge.net/projects/libpng/files/libpng15/older-releases/1.5.12/libpng-1.5.12.tar.gz
    tar -zxvf libpng-1.5.12.tar.gz
    cd libpng-1.5.12
    ./configure --prefix=$PREFIX_BIN/convert
    make check
    make install
    cd ..

    #From sources    
    $get ImageMagick.tar.gz http://www.imagemagick.org/download/ImageMagick.tar.gz
    tar -zxvf ImageMagick.tar.gz
    cd ImageMagick*
    #./configure --prefix=$PREFIX_BIN/convert  CPPFLAGS=-I$PREFIX_BIN/convert/include
    ./configure --prefix=$PREFIX_BIN/convert  CPPFLAGS=-I$PREFIX_BIN/convert/include LDFLAGS="-L${PREFIX_BIN}/convert/lib -R${PREFIX_BIN}/convert/lib"
    make
    make install
    cd ..
    #ldconfig /usr/local/lib
    wasInstalled=0;
fi

if [ $wasInstalled == 0 ]; then
    check=`convert -help 2>&1 | grep -i usage`
    if [ $? = "0" ]; then
	echo -e "$BLUE""ImageMagick appears to be installed successfully""$NORMAL"
    else
	echo -e "$RED""ImageMagick NOT installed successfully""$NORMAL"; exit 1;
    fi
fi



################ reportLab ########################################"


wasInstalled=0;
python -c "import reportlab"
if [ $? = "0" ]; then
    echo -n  -e "$BLUE""reportLab appears to be already installed. ""$NORMAL"
    wasInstalled=1;
fi

echo -n "Would you like to install/re-install the reportLab module ? (y/n) [n] : "
read ans
if [ XX${ans} = XXy ]; then
    #From sources
    $get reportlab-2.7.tar.gz https://pypi.python.org/packages/source/r/reportlab/reportlab-2.7.tar.gz
    tar -zxvf reportlab-2.7.tar.gz
    cd reportlab-2.7
    python setup.py install --user
    cd ..
    wasInstalled=0;
fi

if [ $wasInstalled == 0 ]; then
    #some reportLab tests
    python -c "import reportlab"
    if [ $? = "0" ]; then
	echo -e "$BLUE""reportLab appears to be installed successfully""$NORMAL"
    else
	echo -e "$RED""reportLab NOT installed successfully""$NORMAL"; exit 1;
    fi
fi


########################################################

# clean up
cd ..
rm -rf ./tmp_ncPRO



################ ncPRO installation  ###################
echo;
echo  "Ready to install ncPRO-seq ... "
echo  "Where do you want to install ncPRO-seq ? [$HOME/]"
read ans
ans=${ans:-$HOME}
APPLI_DIR=$ans/$NCPRO

################ ncPRO-seq command-line version ###################

## Check Install Directory
echo;
if [ -d $APPLI_DIR ]; then
    echo -n "The $APPLI_DIR already exists. Delete the folder before installation and continue ? (y/n) [n] : ";
    read ans;
    if [ XX${ans} = XXy ]; then
    rm -rf $APPLI_DIR || die "Cannot delete $APPLI_DIR folder"
	mkdir $APPLI_DIR
    else
	exit 1
    fi
else
    echo -n "Creating installation folder ..."
    mkdir $APPLI_DIR || die "Cannot create installation folder"
    echo "OK."
fi

## Copy in installation folder
echo -n "Installing html files ..."
cp -r www/html $APPLI_DIR/ || die "Files installation failed"
echo "OK."
echo -n "Installing pdf files ..."
cp -r www/pdf $APPLI_DIR/ || die "Files installation failed"
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

echo -e "$RED""\nncPRO-seq Commande-line version installed with success in '$APPLI_DIR'\n""$NORMAL"

################ ncPRO-seq web version ###################
INSTALL_WWW=0
echo -e "$RED""You need have super-user (root) privileges to install web version of ncPRO-seq\n""$NORMAL";
echo -n "Do you want to install the local web version ? (y/n) [n] "
read ans
if [ XX${ans} = XXy ]; then
    INSTALL_WWW=1
fi

if [ $INSTALL_WWW -eq 1 ]; then

    ## default path
    if [ "$os" = "Darwin" ]; then
	WWW_DEF=/Library/WebServer/Documents/
	CGI_DEF=/Library/WebServer/CGI-Executables/
    else
	WWW_DEF=/var/www/
	CGI_DEF=/usr/lib/cgi-bin/
    fi

    ## APACHE
    ps aux | egrep '(apache|httpd)' | grep -v egrep > /dev/null
    if [ $? != "0" ]; then
	echo -n -e "$RED""Apache not appears to run on your system. Please check if it is installed by looking at http://localhost. Do you want to continue ? (y/n) [n] : ""$NORMAL"
	read ans;
	if [ XX${ans} != XXy ]; then
	    exit 1;
	fi
    fi

    echo  "Please, enter the web document root path (more information at http://ncpro.curie.fr/faq.html) ? [$WWW_DEF] "
    read ans
    ans=${ans:-$WWW_DEF}
    WWW_DIR=$ans/$NCPRO

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

    echo "Please, enter the CGI path (more information at http://ncpro.curie.fr/faq.html) ? [$CGI_DEF] "
    read ans
    ans=${ans:-$CGI_DEF}
    CGI_DIR=$ans/$NCPRO

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
    
    ### web results directory
    echo "Where do you want to store the analysis results of the ncPRO local-web version ? [$WWW_DIR/results] "
    read ans
    ans=${ans:-$WWW_DIR/results}
    WWW_RES=$ans

    ## Web application
    echo;
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
    
    chmod 777 $WWW_RES
    chmod 777 $WWW_DIR/output

    echo -e "$RED""\nncPRO-seq local-web version installed with success\n""$NORMAL"
fi

################ Create the config-system file ###################
echo  "Check ncPRO-seq configuration ... "

echo "#######################################################################" > config-system.txt
echo "## Installation Configuration" >> config-system.txt
echo "#######################################################################" >> config-system.txt

echo "INSTALL_WWW = $INSTALL_WWW" >> config-system.txt


echo "#######################################################################" >> config-system.txt
echo "## System settings" >> config-system.txt
echo "#######################################################################" >> config-system.txt

echo "## MANDATORY" >> config-system.txt
echo "APPLI_DIR = $APPLI_DIR" >> config-system.txt

echo "## OPTIONAL - WEB VERSION" >> config-system.txt
echo "WWW_DIR = $WWW_DIR" >> config-system.txt
echo "CGI_DIR = $CGI_DIR" >> config-system.txt
echo "WWW_RES = " >> config-system.txt
echo "PBS_MODE = 0" >> config-system.txt
echo "PBS_OPT = " >> config-system.txt
echo "PBS_PATH = " >> config-system.txt

echo "#######################################################################" >> config-system.txt
echo "## Required Software - Specified the DIRECTORY name of the executables" >> config-system.txt
echo "## If not specified, the program will try to locate the executable" >> config-system.txt
echo "## using the 'which' command" >> config-system.txt
echo "#######################################################################" >> config-system.txt

echo "## MANDATORY" >> config-system.txt

which R > /dev/null
if [ $? = "0" ]; then
    echo "R_PATH = "`dirname $(which R)` >> config-system.txt
else
    die "R_PATH not found. Exit." 
fi
which awk > /dev/null
if [ $? = "0" ]; then
    echo "AWK_PATH = "`dirname $(which awk)`  >> config-system.txt
else
    die "AWK_PATH not found. Exit." 
fi
which bowtie > /dev/null
if [ $? = "0" ]; then
    echo "BOWTIE_PATH = "`dirname $(which bowtie)`  >> config-system.txt
else
    die "BOWTIE_PATH not found. Exit." 
fi
echo "BOWTIE_INDEXES_PATH = $BOWTIE_INDEXES"  >> config-system.txt
which bedtools > /dev/null
if [ $? = "0" ]; then
    echo "BEDTOOLS_PATH = "`dirname $(which bedtools)`  >> config-system.txt
else
    die "BEDTOOLS_PATH not found. Exit." 
fi
which samtools > /dev/null
if [ $? = "0" ]; then
    echo "SAMTOOLS_PATH = "`dirname $(which samtools)`  >> config-system.txt
else
    die "SAMTOOLS_PATH not found. Exit." 
fi
which convert > /dev/null
if [ $? = "0" ]; then
    echo "CONVERT_PATH = "`dirname $(which convert)`  >> config-system.txt
else
    die "CONVERT_PATH not found. Exit." 
fi
which bamMapCount > /dev/null
if [ $? = "0" ]; then
    echo "BAM_MAPCT_PATH = "`dirname $(which bamMapCount)`  >> config-system.txt
else
    die "BAM_MAPCT_PATH not found. Exit." 
fi
which perl > /dev/null
if [ $? = "0" ]; then
    echo "PERL_PATH = "`dirname $(which perl)`  >> config-system.txt
else
    die "PERL_PATH not found. Exit." 
fi
which python > /dev/null
if [ $? = "0" ]; then
    echo "PYTHON_PATH = "`dirname $(which python)`  >> config-system.txt
else
    die "PYTHON_PATH not found. Exit." 
fi
which mail > /dev/null
if [ $? = "0" ]; then
    echo "MAIL_PATH = "`dirname $(which mail)`  >> config-system.txt
else
    echo -e "$RED""Warning : mail not found. The notification at the end of the ncPRO-seq analyses will be disabled ...""$NORMAL"
    echo "MAIL_PATH = "  >> config-system.txt
fi


echo -n "Copying configuration files ..."
cp Makefile config-ncrna.txt $APPLI_DIR/ || die "Files installation failed" 
cp config-system.txt $APPLI_DIR/config-system.txt
echo "OK."

################ End of the installation ###################
echo;
echo -e "$RED""done !""$NORMAL"

