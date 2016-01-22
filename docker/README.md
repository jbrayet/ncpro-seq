# ncPRO-seq 
## Docker image

### What is ncPRO-seq ?

ncPRO-seq (Non-Coding RNA PROfiling in sRNA-seq) is a tool for annotation and profiling of ncRNAs using
deep-sequencing data developed by the Bioinformatics Laboratory of the institut Curie. This comprehensive
and flexible ncRNA analysis pipeline, aims in interrogating and performing detailed analysis on small
RNAs derived from annotated non-coding regions in miRBase, Rfam and repeatMasker, and regions defined 
by users. The ncPRO-seq pipeline also has a module to identify regions significantly enriched with short
reads that can not be classified as known ncRNA families.

ncPRO-seq is developped in the context of a collaborative project involving the following partners :

* Institut Curie - Platforme Bioinformatique (France, Paris)
* Genetique et biologie du d developpement (France, Paris) - Institut Curie - UMR 3215 CNRS - U934 Inserm
* Arabidopsis Epigenetics and Epigenomics group (France, Paris) - CNRS UMR8197 - INSERM U1024 - Institut de Biologie de l’Ecole Normale Superieure
* Institut de Biologie Mol?culaire des Plantes du CNRS - UPR2357 (France, Strasbourg)
* Department of Biology - Swiss Federal Institute of Technology Zurich (Suisse, Zurich)

If you use the ncPRO-seq tool for your analyses, please cite the following paper :

Chen C., Servant N., Toedling J., Sarazin A., Marchais A., Duvernois-Berthet E., Cognat V., Colot
V., Voinnet V., Heard E., Ciaudo C. and Barillot E. ncPRO-seq: a tool for annotation and profiling of
ncRNAs in sRNA-seq data.
[pubmed](http://www.ncbi.nlm.nih.gov/pubmed/23044543)

### Genome

hg19 | taeGut1 | ornAna1 | canFam2 | mm10 | galGal3 | monDom5 | dm3 | mm9 | rn4 | rheMac2 | bosTau4 | 
Zv9 | rn5 | equCab2 | ce6 | TAIR9

### Usage

At first you need to install docker. Please follow the very good instructions from the Docker project.

After the successful installation, you must create ncpro image :

```
cd /var/lib/docker
wget https://github.com/jbrayet/ncpro-seq/raw/master/docker/Dockerfile
docker build -t ncproseq:1.6.5 -f Dockerfile .
```

Create local folder

```
mkdir bowtie_indexes
mkdir annotations
mkdir data
mkdir results
```

Add your data in data folder and your Bowtie indexes in bowtie_indexes folder.

Run ncPro-seq image : 

```
docker run -i -t -v /your/local/path/bowtie_indexes/:/usr/curie_ngs/bowtie_indexes/ -v /your/local/path/annotations/:/usr/curie_ngs/annotation/ -v /your/local/path/data/:/usr/curie_ngs/rawdata/ -v /your/local/path/results/:/usr/curie_ngs/results_host/ ncpro:1.6.5
```

Your results are in /your/local/path/results folder. 
