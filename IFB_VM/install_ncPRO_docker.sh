#!/bin/sh

mkdir -p ~/bowtie_indexes
mkdir -p ~/annotations
mkdir -p ~/data
mkdir -p ~/results

docker pull institutcuriengsintegration/ncproseq:1.6.3

echo alias ncproseq=\"docker run -i -t -v ~/bowtie_indexes/:/usr/curie_ngs/bowtie_indexes/ -v ~/annotations/:/usr/curie_ngs/annotation/ -v ~/data/:/usr/curie_ngs/rawdata/ -v ~/results/:/usr/curie_ngs/results_host/ institutcuriengsintegration/ncproseq:1.6.3\" >> ~/.bashrc

. ~/.bashrc

