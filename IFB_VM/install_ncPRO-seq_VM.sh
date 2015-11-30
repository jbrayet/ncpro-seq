#!/bin/sh -x

################ Updated the VM #############################

apt-key adv --keyserver keyserver.ubuntu.com --recv-keys F7B8CEA6056E8E56
apt-get update
apt-get -y upgrade

################# Installing libraries ######################

apt-get -y install gfortran
apt-get -y install zlib1g-dev
apt-get -y install libncurses-dev
apt-get -y install python-dev
apt-get -y install libxt-dev
apt-get -y install libpango1.0-dev
apt-get -y install imagemagick
apt-get -y install apache2 php5 libapache2-mod-php5

wget http://cran.r-project.org/src/base/R-3/R-3.1.0.tar.gz -P /ifb/bin
tar -zxvf /ifb/bin/R-3.1.0.tar.gz -C /ifb/bin/
rm -rf /ifb/bin/R-3.1.0.tar.gz
cd /ifb/bin/R-3.1.0
./configure --with-readline=no
make

ln -s /ifb/bin/R-3.1.0/bin/R /usr/bin/R

wget http://sourceforge.net/projects/ncproseq/files/IFB_VM/ncPRO-seq.v1.6.3_VM.tar.gz -P /ifb/bin
tar -zxvf /ifb/bin/ncPRO-seq.v1.6.3_VM.tar.gz -C /ifb/bin/
rm -rf /ifb/bin/ncPRO-seq.v1.6.3_VM.tar.gz

mkdir /ifb/curie_ngs/
mkdir /ifb/curie_ngs/bowtie_indexes/

cd /ifb/bin/ncPRO-seq.v1.6.3_VM
make install < answers.txt

/ifb/curie_ngs/ncproseq_v1.6.3/bin/ncPRO-deploy -o /ifb/curie_ngs/ncPRO-seq_results

sed -i 's/MAIL_PATH = /MAIL_PATH = \/usr\/bin/g' /ifb/curie_ngs/ncproseq_v1.6.3/config-system.txt

cd
cp /ifb/bin/ncPRO-seq.v1.6.3_VM/README README
cp /ifb/bin/ncPRO-seq.v1.6.3_VM/init_ncPRO-seq_VM.py init_ncPRO-seq_VM.py

# cd /ifb/curie_ngs/ncPRO-seq_results/rawdata/
# wget ncPRO-seq-testdata.fastq http://sourceforge.net/projects/ncproseq/files/data/ncPRO-seq-testdata.fastq

# scp /bioinfo/users/jbrayet/myGitLab/ncPRO-seq/install_ncPRO_seq_VM.sh root@192.54.201.81:install_ncPRO_seq_VM.sh



