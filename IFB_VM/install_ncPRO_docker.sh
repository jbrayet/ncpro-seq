#!/bin/sh

mkdir -p /root/bowtie_indexes
mkdir -p /root/annotations
mkdir -p /root/data
mkdir -p /root/results

docker pull institutcuriengsintegration/ncproseq:1.6.3

echo alias ncproseq=\"docker run -i -t -v /root/bowtie_indexes/:/usr/curie_ngs/bowtie_indexes/ -v /root/annotations/:/usr/curie_ngs/annotation/ -v /root/data/:/usr/curie_ngs/rawdata/ -v /root/results/:/usr/curie_ngs/results_host/ institutcuriengsintegration/ncproseq:1.6.3\" >> /root/.bashrc

. /root/.bashrc

