#!/bin/sh

mkdir ~/bowtie_indexes
mkdir ~/annotations
mkdir ~/data
mkdir ~/results

docker pull institutcuriengsintegration/ncproseq:1.6.3

echo "alias ncproseq='docker run -i -t -v ~/bowtie_indexes/:/usr/curie_ngs/bowtie_indexes/ -v ~/annotations/:/usr/curie_ngs/annotation/ -v ~/data/:/usr/curie_ngs/rawdata/ -v ~/results/:/usr/curie_ngs/results_host/ institutcuriengsintegration/ncproseq:1.6.3" >> ~/.bashrc'"

source .bashrc
