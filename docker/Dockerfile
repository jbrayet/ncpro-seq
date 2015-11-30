# Dockerfile to install ncPRO-seq pipeline. 
# Jocelyn Brayet
# wget Dockerfile http://sourceforge.net/projects/ncproseq/files/docker/Dockerfile
# docker build -t ncpro:1.0 - < Dockerfile
# mkdir /var/lib/docker/bowtie_indexes
# mkdir /var/lib/docker/annotations
# mkdir /var/lib/docker/data
# mkdir /var/lib/docker/results
# wget ncPRO-seq-testdata.fastq http://sourceforge.net/projects/ncproseq/files/data/ncPRO-seq-testdata.fastq
# wget bowtie_indexes_mm10.tar.gz http://zerkalo.curie.fr:8080/partage/galaxy_test_jbrayet/ncPRO-seq/bowtie_indexes_mm10.tar.gz
# docker run -i -t -v /var/lib/docker/bowtie_indexes/:/usr/curie_ngs/bowtie_indexes/ -v /var/lib/docker/annotations/:/usr/curie_ngs/annotation/ -v /var/lib/docker/data/:/usr/curie_ngs/rawdata/ -v /var/lib/docker/results/:/usr/curie_ngs/results_host/ ncpro:1.0

# ncPRO-seq
# Copyleft ↄ⃝ 2012 Institut Curie
# Author(s): Jocelyn Brayet, Laurene Syx, Chongjian Chen, Nicolas Servant(Institut Curie) 2012 - 2015
# Contact: bioinfo.ncproseq@curie.fr
# This software is distributed without any guarantee under the terms of the GNU General
# Public License, either Version 2, June 1991 or Version 3, June 2007.

FROM ubuntu

MAINTAINER Jocelyn Brayet <jocelyn.brayet@curie.fr>

RUN apt-get update && apt-get install -y \
    wget \
    gfortran \
    zlib1g-dev \
    libncurses-dev \
    python-dev \
    libxt-dev \
    libpango1.0-dev \
    imagemagick \
    apache2 \
    php5 \
    libapache2-mod-php5 \
    unzip \
    python-setuptools \
    libjpeg62 \
    python-imaging \
    libjpeg62-dev \
    libfreetype6 \
    libfreetype6-dev

RUN wget http://cran.r-project.org/src/base/R-3/R-3.1.0.tar.gz -P /usr/bin
RUN tar -zxvf /usr/bin/R-3.1.0.tar.gz -C /usr/bin/
RUN rm -rf /usr/bin/R-3.1.0.tar.gz
WORKDIR /usr/bin/R-3.1.0
RUN ./configure --with-readline=no
RUN make

RUN ln -s /usr/bin/R-3.1.0/bin/R /usr/bin/R

RUN wget http://sourceforge.net/projects/ncproseq/files/docker/ncPRO-seq.v1.6.3_Docker.tar.gz -P /usr/bin
RUN tar -zxvf /usr/bin/ncPRO-seq.v1.6.3_Docker.tar.gz -C /usr/bin/
RUN rm -rf /usr/bin/ncPRO-seq.v1.6.3_Docker.tar.gz

RUN mkdir /usr/curie_ngs/
RUN mkdir /usr/curie_ngs/bowtie_indexes/

WORKDIR /usr/bin/ncPRO-seq.v1.6.3_Docker
RUN service apache2 start && make install < answers.txt

RUN /usr/curie_ngs/ncproseq_v1.6.3/bin/ncPRO-deploy -o /usr/curie_ngs/ncPRO-seq_results

RUN ln -s /usr/lib/x86_64-linux-gnu/libjpeg.so /usr/lib
RUN ln -s /usr/lib/x86_64-linux-gnu/libfreetype.so /usr/lib
RUN ln -s /usr/lib/x86_64-linux-gnu/libz.so /usr/lib
RUN ln -s /usr/include/freetype2 /usr/include/freetype2/freetype

RUN wget http://effbot.org/media/downloads/Imaging-1.1.7.tar.gz -P /usr/bin/
RUN tar -zxvf /usr/bin/Imaging-1.1.7.tar.gz -C /usr/bin/
RUN rm -rf /usr/bin/Imaging-1.1.7.tar.gz
RUN cd /usr/bin/Imaging-1.1.7; python setup.py install --user

RUN sed -i 's/MAIL_PATH = /MAIL_PATH = \/usr\/bin/g' /usr/curie_ngs/ncproseq_v1.6.3/config-system.txt

# Expose port 80 (webserver), 21 (FTP server), 8800 (Proxy)
EXPOSE :80
EXPOSE :21
EXPOSE :8800

ENTRYPOINT ["python","/usr/bin/ncPRO-seq.v1.6.3_Docker/ncPRO-seq.py"]



