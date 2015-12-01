## MAKEFILE FOR NCRNA PIPELINE

# Copyleft ↄ⃝ 2012 Institut Curie
# Author(s): Jocelyn Brayet, Laurene Syx, Chongjian Chen, Nicolas Servant(Institut Curie) 2012 - 2015
# Contact: bioinfo.ncproseq@curie.fr
# This software is distributed without any guarantee under the terms of the GNU General
# Public License, either Version 2, June 1991 or Version 3, June 2007.

## DO NOT EDIT THE REST OF THIS FILE!!

include $(CONFIG_SYS)
include $(CONFIG_FILE)

## special characters
comma := ,
space :=
space +=
slash := |
underscore := _
period := .

## text color

## Appli directory
SCRIPT_DIR = $(APPLI_DIR)/scripts

## raw read file
READSFILE_FQ := $(subst $(underscore),$(period),$(wildcard $(RAW_DIR)/*.f*q))
READSFILE_FA := $(subst $(underscore),$(period),$(wildcard $(RAW_DIR)/*.fa))
READSFILE_FA += $(subst $(underscore),$(period),$(wildcard $(RAW_DIR)/*.fas))
READSFILE_FA += $(subst $(underscore),$(period),$(wildcard $(RAW_DIR)/*.fasta))
READSFILE_CS := $(subst $(underscore),$(period),$(wildcard $(RAW_DIR)/*.csfasta))
READSFILES := $(READSFILE_FQ) $(READSFILE_FA) $(READSFILE_CS)

## raw read file, probably with underscore in the filename
READSFILE_FQ_US := $(wildcard $(RAW_DIR)/*.f*q)
READSFILE_FA_US := $(wildcard $(RAW_DIR)/*.fa)
READSFILE_FA_US += $(wildcard $(RAW_DIR)/*.fas)
READSFILE_FA_US += $(wildcard $(RAW_DIR)/*.fasta)
READSFILE_CS_US := $(wildcard $(RAW_DIR)/*.csfasta)
READSFILES_US := $(READSFILE_FQ_US) $(READSFILE_FA_US) $(READSFILE_CS_US)

## Annotation files
GENOME_DESC_FILE = $(ANNOT_DIR)/$(ORGANISM)/chrom.sizes
RFAM_GFF = $(ANNOT_DIR)/$(ORGANISM)/rfam.gff
RMSK_GFF = $(ANNOT_DIR)/$(ORGANISM)/rmsk.gff
MATURE_MIRNA_GFF = $(ANNOT_DIR)/$(ORGANISM)/mature_miRNA.gff
TRNA_GFF = $(ANNOT_DIR)/$(ORGANISM)/tRNA.gff
PRECURSOR_MIRNA_GFF = $(ANNOT_DIR)/$(ORGANISM)/precursor_miRNA.gff
ACA_SNORNA_ITEM = $(ANNOT_DIR)/ACA_snoRNA.item
CD_SNORNA_ITEM = $(ANNOT_DIR)/CD_snoRNA.item
PROTEIN_GENE_GFF = $(ANNOT_DIR)/$(ORGANISM)/coding_gene.gff

## input bam file
INPUT_BAM := $(subst $(underscore),$(period),$(wildcard $(RAW_DIR)/*.bam))

## input bam file, probably with underscore in the filename
INPUT_BAM_US := $(wildcard $(RAW_DIR)/*.bam)

## separate multiple fastq format by space
FASTQ_FORMAT := $(subst $(comma),$(space),$(FASTQ_FORMAT))

##annotations used to catalogue reads
##ANNO_CATALOG := $(PRECURSOR_MIRNA_GFF) $(foreach r, $(basename $(notdir $(RMSK_GFF))), $(PRO_GFF_DIR)/$(r)_rRNA.gff) $(RFAM_GFF) $(RMSK_GFF) $(PROTEIN_GENE_GFF) 
ANNO_CATALOG_EXCLU = $(patsubst %, $(DATA_DIR)/%_exclusive.bed, $(notdir $(basename $(ANNO_CATALOG))))

## if the number of fastq file and the fastq format item is not the same, the first fastq format will be chosen for all fastq files
ifneq ($(words $(READSFILE_FQ)),$(words $(FASTQ_FORMAT)))
FASTQ_FORMAT :=$(foreach r, $(notdir $(READSFILE_FQ)), $(firstword $(FASTQ_FORMAT)))
endif

##pseudo-function of incrementation which is used to assign the right fastq format to the current processing fastq file.
increment= x $1

## read length and quality score
SAMPLE_READLEN := $(patsubst %, $(DATA_DIR)/%_readlen.data, $(basename $(notdir $(READSFILES))))
SAMPLE_DISTINCT_READLEN := $(patsubst %, $(DATA_DIR)/%_distinct_readlen.data, $(basename $(notdir $(READSFILES))))
SAMPLE_MEANQS := $(patsubst %, $(DATA_DIR)/%_meanquality.data, $(basename $(notdir $(READSFILE_FQ))))
SAMPLE_NAME := $(subst $(space),$(comma),$(basename $(notdir $(READSFILES) $(INPUT_BAM))))
SAMPLE_READGC := $(patsubst %, $(DATA_DIR)/%_baseGCstat.data, $(basename $(notdir $(READSFILES))))


## SAM/BAM/BED files after alignment
ALNSAM_GENOME := $(patsubst %, $(BOWTIE_RESULTS_DIR)/%_$(basename $(BOWTIE_GENOME_REFERENCE)).sam, $(basename $(notdir $(READSFILE_FQ))))
ALNSAM_GENOME += $(patsubst %, $(BOWTIE_RESULTS_DIR)/%_$(basename $(BOWTIE_GENOME_REFERENCE)).sam, $(basename $(notdir $(READSFILE_FA))))
ALNSAM_GENOME += $(patsubst %, $(BOWTIE_RESULTS_DIR)/%_$(basename $(BOWTIE_GENOME_REFERENCE_CS)).sam, $(basename $(notdir $(READSFILE_CS))))

UNALNBAM_GENOME := $(patsubst %, $(BOWTIE_RESULTS_DIR)/unsorted_%.bam, $(basename $(notdir $(ALNSAM_GENOME))))
ALNBAM_GENOME := $(patsubst %, $(BOWTIE_RESULTS_DIR)/%.bam, $(basename $(notdir $(ALNSAM_GENOME))))
INPUT_BAM_PROC := $(subst $(RAW_DIR),$(BOWTIE_RESULTS_DIR),$(INPUT_BAM))

## all bam files 
ALNBAM_GENOME := $(ALNBAM_GENOME) $(INPUT_BAM_PROC)

## Reads sequence
ALNREAD_SEQ := $(patsubst %, $(DATA_DIR)/%.fas, $(basename $(notdir $(ALNBAM_GENOME))))

## All ncrna items and gff files
#ALL_NCRNA := $(NCRNA_RFAM),$(NCRNA_RFAM_EX),$(NCRNA_RMSK),$(NCRNA_RMSK_EX),$(MATURE_MIRNA),$(PRECURSOR_MIRNA),$(TRNA_UCSC)
OTHER_NCRNA_GFF := $(subst $(comma),$(space),$(OTHER_NCRNA_GFF))
PROCESS_NCRNA := $(basename $(notdir $(OTHER_NCRNA_GFF)))
PROCESS_NCRNA += $(foreach nc_item,$(subst $(comma),$(space),$(NCRNA_RFAM_EX)),$(patsubst %, %_$(nc_item), $(basename $(notdir $(RFAM_GFF)))))
PROCESS_NCRNA += $(foreach nc_item,$(subst $(comma),$(space),$(NCRNA_RMSK_EX)),$(patsubst %, %_$(nc_item), $(basename $(notdir $(RMSK_GFF)))))
PROCESS_NCRNA += $(foreach nc_item,$(subst $(comma),$(space),$(MATURE_MIRNA)),$(patsubst %, %_$(nc_item), $(basename $(notdir $(MATURE_MIRNA_GFF)))))
PROCESS_NCRNA += $(foreach nc_item,$(subst $(comma),$(space),$(PRECURSOR_MIRNA)),$(patsubst %, %_$(nc_item), $(basename $(notdir $(PRECURSOR_MIRNA_GFF)))))
PROCESS_NCRNA += $(foreach nc_item,$(subst $(comma),$(space),$(TRNA_UCSC)), $(patsubst %, %_$(nc_item), $(basename $(notdir $(TRNA_GFF)))))
ALL_NCRNA := $(PROCESS_NCRNA)
ALL_NCRNA += $(foreach nc_item,$(subst $(comma),$(space),$(NCRNA_RFAM)),$(patsubst %, %_$(nc_item), $(basename $(notdir $(RFAM_GFF)))))
ALL_NCRNA += $(foreach nc_item,$(subst $(comma),$(space),$(NCRNA_RMSK)),$(patsubst %, %_$(nc_item), $(basename $(notdir $(RMSK_GFF)))))

MATURE_MIRNA_TEST := $(foreach nc_item,$(subst $(comma),$(space),$(MATURE_MIRNA)),$(patsubst %, %_$(nc_item), $(basename $(notdir $(MATURE_MIRNA_GFF)))))
PRECURSOR_MIRNA_TEST := $(foreach nc_item,$(subst $(comma),$(space),$(PRECURSOR_MIRNA)),$(patsubst %, %_$(nc_item), $(basename $(notdir $(PRECURSOR_MIRNA_GFF)))))

PRO_NCGFF_FILE := $(patsubst %, $(PRO_GFF_DIR)/%.gff, $(PROCESS_NCRNA))

##Annotated files
ALNBED_RMSK := $(patsubst %, $(DATA_DIR)/%_$(basename $(notdir $(RMSK_GFF))).bed, $(basename $(notdir $(ALNBAM_GENOME))))
ALNBED_RFAM := $(patsubst %, $(DATA_DIR)/%_$(basename $(notdir $(RFAM_GFF))).bed, $(basename $(notdir $(ALNBAM_GENOME))))

ALNBED_NCRNA := $(foreach gbam, $(ALNBAM_GENOME),$(foreach gfile,$(PRO_NCGFF_FILE),$(patsubst %.bam,%_$(notdir $(basename $(gfile)))_ncRNA.bed, $(DATA_DIR)/$(notdir $(gbam)))))
ALNBED_NCRNA += $(foreach rmsk_item,$(subst $(comma),$(space),$(NCRNA_RMSK)),$(foreach rmsk_bed, $(ALNBED_RMSK),$(basename $(rmsk_bed))_$(rmsk_item)_ncRNA.bed))
ALNBED_NCRNA += $(foreach rfam_item,$(subst $(comma),$(space),$(NCRNA_RFAM)),$(foreach rfam_bed, $(ALNBED_RFAM),$(basename $(rfam_bed))_$(rfam_item)_ncRNA.bed))

PROC_MIRNA := $(foreach nc_item,$(subst $(comma),$(space),$(MATURE_MIRNA)),$(patsubst %, %_$(nc_item), $(basename $(notdir $(MATURE_MIRNA_GFF)))))
PROC_MIRNA += $(foreach nc_item,$(subst $(comma),$(space),$(PRECURSOR_MIRNA)),$(patsubst %, %_$(nc_item), $(basename $(notdir $(PRECURSOR_MIRNA_GFF)))))

ALNBED_MIRNA := $(foreach gbam, $(ALNBAM_GENOME),$(foreach gfile,$(PROC_MIRNA),$(patsubst %.bam,%_$(notdir $(basename $(gfile)))_ncRNA.bed, $(DATA_DIR)/$(notdir $(gbam)))))
#ALNBED_MIRNA := $(foreach gbam, $(ALNBAM_GENOME),$(foreach gfile,$(ALNBED_PREMIRNA),$(patsubst %.bam,%_$(notdir $(basename $(gfile)))_ncRNA.bed, $(DATA_DIR)/$(notdir $(gbam)))))


RMSK_FAMCOV_ABUNDANT := $(patsubst %, $(DATA_DIR)/%_famcov_abundant.data, $(basename $(notdir $(ALNBED_RMSK))))
RMSK_FAMCOV_DISTINCT := $(patsubst %, $(DATA_DIR)/%_famcov_distinct.data, $(basename $(notdir $(ALNBED_RMSK))))
RFAM_FAMCOV_ABUNDANT := $(patsubst %, $(DATA_DIR)/%_famcov_abundant.data, $(basename $(notdir $(ALNBED_RFAM))))
RFAM_FAMCOV_DISTINCT := $(patsubst %, $(DATA_DIR)/%_famcov_distinct.data, $(basename $(notdir $(ALNBED_RFAM))))

SAMPLE_GENOME_READLEN := $(patsubst %, $(DATA_DIR)/%_genome_mapping_readlen.data, $(basename $(notdir $(ALNBAM_GENOME))))
SAMPLE_GENOME_DISTINCT_READLEN := $(patsubst %, $(DATA_DIR)/%_genome_mapping_distinct_readlen.data, $(basename $(notdir $(ALNBAM_GENOME))))
SAMPLE_MAPPING_STAT := $(patsubst %, $(DATA_DIR)/%_mappingstat.data, $(basename $(notdir $(ALNBAM_GENOME))))
SAMPLE_DISTINCT_MAPPING_STAT := $(patsubst %, $(DATA_DIR)/%_distinct_mappingstat.data, $(basename $(notdir $(ALNBAM_GENOME))))
SAMPLE_MIRNA_STAT := $(patsubst %, $(DATA_DIR)/%_mirnastat.data, $(basename $(notdir $(ALNBAM_GENOME))))

PROFILE_TYPE := all 5end 3end

SIG_REGION_ANN := $(filter-out $(EXCLUDE_ANN_GFF),$(RFAM_GFF) $(RMSK_GFF) $(OTHER_NCRNA_GFF) $(PROTEIN_GENE_GFF))
SIG_FILE_PREFIX := $(foreach gbam, $(ALNBAM_GENOME), $(foreach filter_item, $(subst $(slash),$(space),$(subst $(space),,$(SIG_READ_OPTIONS))), $(basename $(notdir $(gbam)))$(subst =,_,$(subst min,,$(subst max_copy=,_,$(subst max_len=,_,$(subst $(comma),,$(filter_item))))))))

## Logs files
BOWTIE_GENOME_LOGFILE = $(LOGS_DIR)/bowtie_$(BOWTIE_GENOME_REFERENCE).log
SAMTOOLS_LOGFILE = $(LOGS_DIR)/samtools.log
GET_FAMGFF_LOGFILE = $(LOGS_DIR)/create_fam_gff.log

all: configCheck reset processRead mapGenome mapGenomeStat mapAnnOverview overviewRmsk overviewRfam generateNcgff ncrnaProcess ncrnaTracks genomeTracks sigRegion html_builder pdf_builder clean_sam

## for each sample, group reads and also calcualte read length distribution, mean quality score, GC content and base biases for each base
processRead: inputCheck processread_fa processread_fq processread_cs readlength distinctreadlength meanquality readbasegc readbase

processBam : inputCheck groupBam addmulticounttag

## Aligned reads against genome
mapGenome: inputCheck mapgenome_fa mapgenome_fq mapgenome_cs convertgenome_sam processBam


## read statistics for all samples, and mapping statistics of all mapped reads
mapGenomeStat: inputCheck mapping_read_seq mapping_read_length mapping_distinct_read_length mapping_stat mapping_stat_distinct

## overview of read annotation
#mapAnnOverview: inputCheck intersectbam_genegff intersectbam_premirgff select_rrna_bed read_anno_overview
mapAnnOverview: inputCheck generate_exclusivegff intersectbam_glob read_anno_overview subfamcov_glob

## read mapping overview of all classes in repeatmasker
overviewRmsk: inputCheck intersectbam_rmskgff rmsk_class_overview

## read mapping overview of all subfamilies in rfam
overviewRfam: inputCheck intersectbam_rfamgff rfam_ncrna_overview mirna_stat

## Create gff file for special ncrna family
generateNcgff: rfam_ncrna_ex_gff rmsk_ncrna_ex_gff mirbase_mature_gff mirbase_precursor_gff ucsc_trna_gff

## ncrna family analyses, including read coverage, read length distribution, read coverage in subfamilies, sequence logo
ncrnaProcess: select_rmsk_class_bed select_rfam_class_bed intersectbam_subgff ncrna_read_basecov ncrna_read_length ncrna_subfam_coverage plotSingleFamInfos seq_logo_matrix plotCombinedFamProfile plotExpDynamic sRNA_distance

## detect significant regions
sigRegion: sig_region_detect sig_region_ann sig_region_track


#systemCheck:
#        ifeq ($(CONFIG_SYS),)
#	$(error Unable to load CONFIG_SYS file)
#        endif
#	$(SCRIPT_DIR)/checkConfig.sh -c $(CONFIG_SYS)

configCheck:
	@echo "--------------------------------------------"
	@date
	
        ifeq ($(CONFIG_FILE),)
	$(error Unable to load CONFIG_FILE file)
        endif

annoCheck:
        ifeq ("$(wildcard $(PRECURSOR_MIRNA_GFF))","")  
	@echo "XXNNN	1	2" > $(PRECURSOR_MIRNA_GFF)
        endif
        ifeq ("$(wildcard $(MATURE_MIRNA_GFF))","")  
	@echo "XXNNN	1	2" > $(MATURE_MIRNA_GFF)
        endif
        ifeq ("$(wildcard $(RFAM_GFF))","") 
	@echo "XXNNN	1	2" >  $(RFAM_GFF)
        endif
        ifeq ("$(wildcard $(RMSK_GFF))","") 
	@echo "XXNNN	1	2" >  $(RMSK_GFF)
        endif
        ifeq ("$(wildcard $(PROTEIN_GENE_GFF))","")
	@echo "XXNNN    1       2" >  $(PROTEIN_GENE_GFF)
        endif
        ifeq ("$(wildcard $(TRNA_GFF))","")
	@echo "XXNNN    1       2" >  $(TRNA_GFF)
        endif

#allCheck: systemCheck configCheck

# install: 
#         #ifeq ($(CONFIG_SYS),)
# 	$(error Unable to load CONFIG_SYS file)
#         endif
# 	./scripts/checkConfig.sh -c $(CONFIG_SYS)
# 	./scripts/install.sh

install:
	./scripts/install_all.sh -c config-system.txt
	./scripts/checkConfig.sh -c config-system.txt

# check input data

#inputCheck: annoCheck

inputCheck:
        ifeq ($(strip $(READSFILES) $(INPUT_BAM)),)
	$(error Unable to find any sequence/alignment(BAM) files)
        endif
        ifneq ($(strip $(READSFILES) $(INPUT_BAM)),$(strip $(READSFILES_US) $(INPUT_BAM_US)))
	mkdir $(RAW_DIR)/tmp
	$(foreach file,$(notdir $(strip $(READSFILES_US) $(INPUT_BAM_US))),mv $(RAW_DIR)/$(file) $(RAW_DIR)/tmp/$(subst $(underscore),$(period),$(file)); mv $(RAW_DIR)/tmp/$(subst $(underscore),$(period),$(file)) $(RAW_DIR)/$(subst $(underscore),$(period),$(file));)
	rm -fr $(RAW_DIR)/tmp
        endif


list: 
	@echo SCRIPT_DIR=$(SCRIPT_DIR)
	@echo SAMPLE_NAME=$(SAMPLE_NAME)
	@echo READSFILES=$(READSFILES)
	@echo INPUT_BAM=$(INPUT_BAM)
	@echo INPUT_BAM_PROC=$(INPUT_BAM_PROC)
	@echo "-- FILES TO PRE-PROCESSED --"
	@echo PROCESS_NCRNA=$(PROCESS_NCRNA)
	@echo PRO_NCGFF_FILE=$(PRO_NCGFF_FILE)
	@echo "-- FILES TO ANNOTATE --"
	@echo ANNO_CATALOG=$(ANNO_CATALOG)
	@echo ANNO_CATALOG_EXCLU=$(ANNO_CATALOG_EXCLU)
	@echo ALL_NCRNA=$(ALL_NCRNA)
	@echo NCRNA_RFAM=$(NCRNA_RFAM)
	@echo PRECURSOR_MIRNA_GFF=$(PRECURSOR_MIRNA_GFF)
	@echo MATURE_MIRNA_GFF=$(MATURE_MIRNA_GFF)
	@echo RFAM_GFF=$(RFAM_GFF)
	@echo RMSK_GFF=$(RMSK_GFF)
	@echo PROTEIN_GENE_GFF=$(PROTEIN_GENE_GFF)
	@echo TRNA_GFF=$(TRNA_GFF)
	@echo "-- FILES MAPPED ON THE GENOME --"
	@echo ALNBAM_GENOME=$(ALNBAM_GENOME)
	@echo "-- FILES ANNOTATED --"
	@echo ALNBED_RMSK=$(ALNBED_RMSK)
	@echo ALNBED_RFAM=$(ALNBED_RFAM)
	@echo ALNBED_MIRNA=$(ALNBED_MIRNA)
	@echo PROC_MIRNA=$(PROC_MIRNA)
	@echo ALNBED_NCRNA=$(ALNBED_NCRNA)
	@echo OTHER_NCRNA_GFF=$(OTHER_NCRNA_GFF)
	@echo "-- OTHERS --"
	@echo ALNBAM_GENOME=$(ALNBAM_GENOME)
	@echo MATURE_MIRNA=$(MATURE_MIRNA)
	@echo MATURE_MIRNA_TEST=$(MATURE_MIRNA_TEST)
	@echo FILTER_ZERO_COUNTS=$(FILTER_ZERO_COUNTS)
	@echo SIG_REGION_ANN=$(SIG_REGION_ANN)
	@echo SAMPLE_MAPPING_STAT=$(SAMPLE_MAPPING_STAT)
	@echo SAMPLE_GENOME_READLEN=$(SAMPLE_GENOME_READLEN)
	@echo RMSK_FAMCOV_ABUNDANT=$(RMSK_FAMCOV_ABUNDANT)
	@echo RMSK_FAMCOV_DISTINCT=$(RMSK_FAMCOV_DISTINCT)
	@echo RFAM_FAMCOV_ABUNDANT=$(RFAM_FAMCOV_ABUNDANT)
	@echo RFAM_FAMCOV_DISTINCT=$(RFAM_FAMCOV_DISTINCT)
	@echo RFAM_GFF=$(RFAM_GFF)
	@echo SIG_FILE_PREFIX=$(SIG_FILE_PREFIX)

######################################
## Process reads
## calcualte read length distribution, median quality score for each postion, and group reads if GROUP_READ is specified to 1
######################################

## process .fa file
processread_fa: $(READSFILE_FA)
        ifneq ($(strip $(READSFILE_FA)),)
	@echo "--------------------------------------------" >> $(LOGFILE)
	@date >> $(LOGFILE)
	@echo "Calculate read length distribution, median quality score for each postion, and group reads (fasta files) ..." >> $(LOGFILE)
	@echo "--------------------------------------------"
	@echo "\\033[0;34m""Calculate read length distribution, median quality score for each postion, and group reads (fasta files)""\\033[0;39m" 
	$(foreach r, $(notdir $(READSFILE_FA)), $(PERL_PATH)/perl $(SCRIPT_DIR)/processReads.pl -i $(r) -f "fasta" -g $(GROUP_READ) -D $(RAW_DIR) -d $(DATA_DIR);)
        endif

## process solid reads
processread_cs: $(READSFILE_CS)
        ifneq ($(strip $(READSFILE_CS)),)
	@echo "--------------------------------------------" >> $(LOGFILE)
	@date >> $(LOGFILE)
	@echo "Calculate read length distribution, median quality score for each postion, and group reads (csfasta files) ..." >> $(LOGFILE)
	@echo "--------------------------------------------"
	@echo "\\033[0;34m""Calculate read length distribution, median quality score for each postion, and group reads (csfasta files)""\\033[0;39m" 
	@$(foreach r, $(notdir $(READSFILE_CS)), $(PERL_PATH)/perl $(SCRIPT_DIR)/processReads.pl -i $(r) -f "csfasta" -g $(GROUP_READ) -D $(RAW_DIR) -d $(DATA_DIR);)
        endif

COUNT=
processread_fq: $(READSFILE_FQ)
        ifneq ($(strip $(READSFILE_FQ)),)
	@echo "--------------------------------------------" >> $(LOGFILE)
	@date >> $(LOGFILE)
	@echo "Calculate read length distribution, median quality score for each postion, and group reads (fastq files) ..." >> $(LOGFILE)
	@echo "--------------------------------------------"
	@echo "\\033[0;34m""Calculate read length distribution, median quality score for each postion, and group reads (fastq files)""\\033[0;39m" 
	@$(foreach r, $(notdir $(READSFILE_FQ)),$(eval COUNT := $(call increment,$(COUNT))) $(eval FORMAT := $(word $(words $(COUNT)),$(FASTQ_FORMAT))) $(PERL_PATH)/perl $(SCRIPT_DIR)/processReads.pl -i $(r) -f $(FORMAT) -g $(GROUP_READ) -D $(RAW_DIR) -d $(DATA_DIR);)
        endif

#########################################
## Align reads against genome with Bowtie
#########################################

## align .fa file to genome
mapgenome_fa: $(READSFILE_FA)
        ifneq ($(strip $(READSFILE_FA)),)
	@echo "--------------------------------------------" >> $(LOGFILE)
	@date >> $(LOGFILE)
	@echo "Running Bowtie for genome mapping (fasta files) ..." >> $(LOGFILE)
	@echo "Check log file $(BOWTIE_GENOME_LOGFILE)" >> $(LOGFILE)
	@echo "--------------------------------------------"
	@echo "\\033[0;34m""Running Bowtie for genome mapping (fasta files)""\\033[0;39m"
	@$(foreach r, $(READSFILE_FA), echo "bowtie $(BOWTIE_GENOME_OPTIONS_FA) -p $(N_CPU) --un $(DATA_DIR)/$(basename $(notdir $(r))).unmapped --sam $(BOWTIE_GENOME_REFERENCE) $(r).pmod $(BOWTIE_RESULTS_DIR)/$(basename $(notdir $(r)))_$(basename $(BOWTIE_GENOME_REFERENCE)).sam" >>$(BOWTIE_GENOME_LOGFILE);$(BOWTIE_PATH)/bowtie $(BOWTIE_GENOME_OPTIONS_FA) -p $(N_CPU) --un $(DATA_DIR)/$(basename $(notdir $(r))).unmapped --sam $(BOWTIE_GENOME_REFERENCE) $(r).pmod $(BOWTIE_RESULTS_DIR)/$(basename $(notdir $(r)))_$(basename $(BOWTIE_GENOME_REFERENCE)).sam 2>>$(BOWTIE_GENOME_LOGFILE);)
	@echo "\\033[0;34m""Running Bowtie for genome mapping (fasta files) -> done""\\033[0;39m"
        endif

## align solexa reads to genome
COUNTM=
mapgenome_fq: $(READSFILE_FQ)
        ifneq ($(strip $(READSFILE_FQ)),)
	@echo "--------------------------------------------" >> $(LOGFILE)
	@date >> $(LOGFILE)
	@echo "Running Bowtie for genome mapping (fastq files)..." >> $(LOGFILE)
	@echo "Check log file $(BOWTIE_GENOME_LOGFILE)" >> $(LOGFILE)
	@echo "--------------------------------------------"
	@echo "\\033[0;34m""Running Bowtie for genome mapping (fastq files)""\\033[0;39m"
	@$(foreach r, $(READSFILE_FQ), $(eval COUNTM := $(call increment,$(COUNTM))) $(eval FORMAT := $(word $(words $(COUNTM)),$(FASTQ_FORMAT))) echo "bowtie $(BOWTIE_GENOME_OPTIONS_FQ) --$(FORMAT)-quals -p $(N_CPU) --un $(DATA_DIR)/$(basename $(notdir $(r))).unmapped --sam $(BOWTIE_GENOME_REFERENCE) $(r).pmod $(BOWTIE_RESULTS_DIR)/$(basename $(notdir $(r)))_$(basename $(BOWTIE_GENOME_REFERENCE)).sam" >>$(BOWTIE_GENOME_LOGFILE);$(BOWTIE_PATH)/bowtie $(BOWTIE_GENOME_OPTIONS_FQ) --$(FORMAT)-quals -p $(N_CPU) --un $(DATA_DIR)/$(basename $(notdir $(r))).unmapped --sam $(BOWTIE_GENOME_REFERENCE) $(r).pmod $(BOWTIE_RESULTS_DIR)/$(basename $(notdir $(r)))_$(basename $(BOWTIE_GENOME_REFERENCE)).sam 2>>$(BOWTIE_GENOME_LOGFILE);)
	@echo "\\033[0;34m""Running Bowtie for genome mapping (fastq files) -> done""\\033[0;39m"
        endif

## align solid reads to genome
mapgenome_cs: $(READSFILE_CS)
        ifneq ($(strip $(READSFILE_CS)),)
	@echo "--------------------------------------------" >> $(LOGFILE)
	@date >> $(LOGFILE)
	@echo "Running Bowtie for genome mapping (csfasta files) ..." >> $(LOGFILE)
	@echo "Check log file $(BOWTIE_GENOME_LOGFILE)" >> $(LOGFILE)
	@echo "--------------------------------------------"
	@echo "\\033[0;34m""Running Bowtie for genome mapping (csfasta files)""\\033[0;39m"
	@$(foreach r, $(READSFILE_CS), echo "bowtie $(BOWTIE_GENOME_OPTIONS_CS) -p $(N_CPU) --un $(DATA_DIR)/$(basename $(notdir $(r))).unmapped --sam $(BOWTIE_GENOME_REFERENCE_CS) $(r).pmod $(BOWTIE_RESULTS_DIR)/$(basename $(notdir $(r)))_$(basename $(BOWTIE_GENOME_REFERENCE_CS)).sam" >>$(BOWTIE_GENOME_LOGFILE);$(BOWTIE_PATH)/bowtie $(BOWTIE_GENOME_OPTIONS_CS) -p $(N_CPU) --un $(DATA_DIR)/$(basename $(notdir $(r))).unmapped --sam $(BOWTIE_GENOME_REFERENCE_CS) $(r).pmod $(BOWTIE_RESULTS_DIR)/$(basename $(notdir $(r)))_$(basename $(BOWTIE_GENOME_REFERENCE_CS)).sam 2>>$(BOWTIE_GENOME_LOGFILE);)
	@echo "\\033[0;34m""Running Bowtie for genome mapping (csfasta files) -> done""\\033[0;39m"
        endif


## Convert SAM to BAM files, sort them and create index,
convertgenome_sam: $(ALNSAM_GENOME)
	@echo "--------------------------------------------" >> $(LOGFILE)
	@date >> $(LOGFILE)
	@echo "Converting Bowtie SAM files to BAM..." >> $(LOGFILE)
	@echo "--------------------------------------------"
	@echo "\\033[0;34m""Converting Bowtie SAM files to BAM""\\033[0;39m"
	@$(foreach r, $(ALNSAM_GENOME), $(SAMTOOLS_PATH)/samtools view -bS $(r) > $(BOWTIE_RESULTS_DIR)/unsorted_$(basename $(notdir $(r))).bam 2>>$(SAMTOOLS_LOGFILE);)
	@$(foreach r, $(UNALNBAM_GENOME), $(SAMTOOLS_PATH)/samtools sort $(r) $(BOWTIE_RESULTS_DIR)/$(patsubst unsorted_%,%,$(notdir $(basename $(r)))) 2>>$(SAMTOOLS_LOGFILE);)
	@$(foreach r, $(ALNBAM_GENOME), $(SAMTOOLS_PATH)/samtools index $(r) 2>>$(SAMTOOLS_LOGFILE);)
	@rm -f $(UNALNBAM_GENOME)
	@echo "\\033[0;34m""Converting Bowtie SAM files to BAM -> done""\\033[0;39m"
# change color : \033[33;32m

######################################
## Process bam files given by user
## generate a new bam file by grouping alignments which have the same read sequences
######################################

groupBam: $(INPUT_BAM)
	@echo "--------------------------------------------" >> $(LOGFILE)
	@date >> $(LOGFILE)
	@echo "Group bam files given by user..." >> $(LOGFILE)
	@echo "--------------------------------------------"
	@echo "\\033[0;34m""Group bam files given by user""\\033[0;39m"
        ifeq ($(strip $(GROUP_READ)),1)  
	@$(foreach r, $(INPUT_BAM), $(SAMTOOLS_PATH)/samtools view $(r) | $(PERL_PATH)/perl $(SCRIPT_DIR)/processBam.pl -i stdin -g $(GROUP_READ) > $(DATA_DIR)/$(basename $(notdir $(r))).fas; $(SAMTOOLS_PATH)/samtools view $(r) | $(PERL_PATH)/perl $(SCRIPT_DIR)/groupBam.pl -i stdin -g $(DATA_DIR)/$(basename $(notdir $(r))).fas > $(DATA_DIR)/$(basename $(notdir $(r)))_gp.sam; $(SAMTOOLS_PATH)/samtools view -bS $(DATA_DIR)/$(basename $(notdir $(r)))_gp.sam -t $(GENOME_DESC_FILE) > $(subst $(RAW_DIR),$(BOWTIE_RESULTS_DIR),$(r)); rm -f $(DATA_DIR)/$(basename $(notdir $(r)))_gp.sam;)
        else
#for online version where the input bam files have already been grouped
        ifeq ($(strip $(GROUP_READ)),2)  
	@$(foreach r, $(INPUT_BAM), $(SAMTOOLS_PATH)/samtools view $(r) | $(PERL_PATH)/perl $(SCRIPT_DIR)/processBam.pl -i stdin -g $(GROUP_READ) > $(DATA_DIR)/$(basename $(notdir $(r))).fas; cp $(r) $(subst $(RAW_DIR),$(BOWTIE_RESULTS_DIR),$(r)))	
        else
	@$(foreach r, $(INPUT_BAM), $(SAMTOOLS_PATH)/samtools view $(r) | $(PERL_PATH)/perl $(SCRIPT_DIR)/processBam.pl -i stdin -g $(GROUP_READ) > $(DATA_DIR)/$(basename $(notdir $(r))).fas; $(SAMTOOLS_PATH)/samtools view $(r) | $(AWK_PATH)/awk -F"\t" 'BEGIN{OFS="\t"}{$$1=$$1"_1";print $$0}' > $(DATA_DIR)/$(basename $(notdir $(r))).sam; $(SAMTOOLS_PATH)/samtools view -bS $(DATA_DIR)/$(basename $(notdir $(r))).sam -t $(GENOME_DESC_FILE) > $(subst $(RAW_DIR),$(BOWTIE_RESULTS_DIR),$(r)); rm -f $(DATA_DIR)/$(basename $(notdir $(r))).sam;)	
        endif
        endif
	@echo "\\033[0;34m""Group bam files given by user -> done""\\033[0;39m"

######################################
## Add multiple hits tag
######################################

addmulticounttag: $(ALNBAM_GENOME)
	@echo "--------------------------------------------" >> $(LOGFILE)
	@date >> $(LOGFILE)
	@echo "Add map count to BAM files..." >> $(LOGFILE)
	@echo "--------------------------------------------"
	@echo "\\033[0;34m""Add map count to BAM files""\\033[0;39m"
	@$(foreach r, $(ALNBAM_GENOME), $(BAM_MAPCT_PATH)/bamMapCount -i $(r) -tag XX -o $(BOWTIE_RESULTS_DIR)/temp_mapCount; mv $(BOWTIE_RESULTS_DIR)/temp_mapCount $(r);)
	@echo "\\033[0;34m""Add map count to BAM files -> done""\\033[0;39m"

######################################
## Read length, read quality score, GC content and base biases of reads
######################################

## plot length distribution of abundant reads
readlength: $(READSFILES)
        ifneq ($(strip $(READSFILES)),)
	@echo "--------------------------------------------" >> $(LOGFILE)
	@date >> $(LOGFILE)
	@echo "combine length distribution file of abundant reads from all samples, and draw plot..." >> $(LOGFILE)
	@$(PERL_PATH)/perl $(SCRIPT_DIR)/combineFiles.pl $(SAMPLE_READLEN) > $(DOC_DIR)/all_samples_readlen.data
# draw plot
	@$(R_PATH)/R --no-save --no-restore CMD BATCH "--args type='abundant' lenFile='$(DOC_DIR)/all_samples_readlen.data' figFile='$(PIC_DIR)/plotReadSize.png'" $(SCRIPT_DIR)/plotLenDistr.R  $(LOGS_DIR)/plotLenDistr.Rout
	@echo "Length distribution of abundant reads plot -> done"
        endif

## plot length distribution of distinct reads
distinctreadlength: $(READSFILES)
        ifneq ($(strip $(READSFILES)),)
	@echo "--------------------------------------------" >> $(LOGFILE)
	@date >> $(LOGFILE)
	@echo "combine length distribution file of distinct reads from all samples, and draw plot..." >> $(LOGFILE)
	@$(PERL_PATH)/perl $(SCRIPT_DIR)/combineFiles.pl $(SAMPLE_DISTINCT_READLEN) > $(DOC_DIR)/all_samples_distinct_readlen.data
# draw plot
	@$(R_PATH)/R --no-save --no-restore CMD BATCH "--args type='distinct' lenFile='$(DOC_DIR)/all_samples_distinct_readlen.data' figFile='$(PIC_DIR)/plotDistinctReadSize.png'" $(SCRIPT_DIR)/plotLenDistr.R  $(LOGS_DIR)/plotLenDistr.Rout
	@echo "Length distribution of distinct reads plot -> done"
        endif

## draw mean quality score plot
meanquality: $(READSFILE_FQ)
        ifneq ($(strip $(READSFILE_FQ)),)
	@echo "--------------------------------------------" >> $(LOGFILE)
	@date >> $(LOGFILE)
	@echo "combine mean quality score file from all samples, and draw plot..." >> $(LOGFILE)
	@$(PERL_PATH)/perl $(SCRIPT_DIR)/combineFiles.pl $(SAMPLE_MEANQS) > $(DOC_DIR)/all_samples_read_meanquality.data
# draw plot
	@$(R_PATH)/R --no-save --no-restore CMD BATCH "--args qualityFile='$(DOC_DIR)/all_samples_read_meanquality.data' figFile='$(PIC_DIR)/plotMeanQuality.png'" $(SCRIPT_DIR)/plotMeanQuality.R  $(LOGS_DIR)/plotMeanQuality.Rout
	@echo "Mean quality score plot -> done"
        endif

## draw base gc plot
readbasegc: $(READSFILES)
        ifneq ($(strip $(READSFILES)),)
	@echo "--------------------------------------------" >> $(LOGFILE)
	@date >> $(LOGFILE)
	@echo "combine base gc content file from all samples, and draw plot..." >> $(LOGFILE)
	@$(PERL_PATH)/perl $(SCRIPT_DIR)/combineFiles.pl $(SAMPLE_READGC) > $(DOC_DIR)/all_samples_read_basegc.data
# draw plot
	@$(R_PATH)/R --no-save --no-restore CMD BATCH "--args gcFile='$(DOC_DIR)/all_samples_read_basegc.data' figFile='$(PIC_DIR)/plotBaseGC.png'" $(SCRIPT_DIR)/plotBaseGC.R $(LOGS_DIR)/plotBaseGC.Rout
	@echo "Base gc plot -> done"
        endif

## draw base plot
readbase: $(READSFILES)
        ifneq ($(strip $(READSFILES)),)
	@echo "--------------------------------------------" >> $(LOGFILE)
	@date >> $(LOGFILE)
	@echo "draw base plot for each library..." >> $(LOGFILE)
	@$(R_PATH)/R --no-save --no-restore CMD BATCH "--args dataDir='$(DATA_DIR)' figFile='$(PIC_DIR)/plotBase.png'" $(SCRIPT_DIR)/plotBase.R $(LOGS_DIR)/plotBase.Rout
	@echo "Base position plot -> done"
	@echo "\\033[0;34m""Calculate read length distribution, median quality score for each postion, and group reads -> done""\\033[0;39m"
        endif

######################################
## genome mapping statistics 
######################################

## create fasta file for aligned read sequence
mapping_read_seq: $(ALNBAM_GENOME)
	@echo "--------------------------------------------" >> $(LOGFILE)
	@date >> $(LOGFILE)
	@echo "get aligned read sequence in fasta format..." >> $(LOGFILE)
	@echo "--------------------------------------------"
	@echo "\\033[0;34m""Genome mapping statistics""\\033[0;39m"

	@$(foreach r, $(ALNBAM_GENOME), $(SAMTOOLS_PATH)/samtools view $(r) | $(PERL_PATH)/perl $(SCRIPT_DIR)/extractMapRead.pl -i stdin > $(DATA_DIR)/$(basename $(notdir $(r)))_map.fas;)
	@echo "Get aligned read sequence in fasta format -> done"

## calculate length of abundant reads distribution after mapping
mapping_read_length: $(ALNBAM_GENOME)
	@echo "--------------------------------------------" >> $(LOGFILE)
	@date >> $(LOGFILE)
	@echo "compute length distribution after mapping, and draw length distribution plot..." >> $(LOGFILE)

# generate length count file for each bam file	
	@$(foreach r, $(ALNBAM_GENOME), $(SAMTOOLS_PATH)/samtools view $(r) | $(AWK_PATH)/awk -v name=$(basename $(notdir $(r))) 'BEGIN{OFS="\t"}{if(($$3!="*") && (!read[$$1])){lrname=split($$1,rname,"_");read_num=rname[lrname];size=length($$10);len[size]+=read_num} read[$$1]=1} END{print "idx",name; for(i in len){print i,len[i]|"sort -n"}}' > $(DATA_DIR)/$(basename $(notdir $(r)))_genome_mapping_readlen.data;)
# combile length count files
	@$(PERL_PATH)/perl $(SCRIPT_DIR)/combineFiles.pl $(SAMPLE_GENOME_READLEN) > $(DOC_DIR)/all_samples_genome_mapping_readlen.data
	@$(R_PATH)/R --no-save --no-restore CMD BATCH "--args tabFile='$(DOC_DIR)/all_samples_genome_mapping_readlen.data'" $(SCRIPT_DIR)/modifyColname.R  $(LOGS_DIR)/modifyColName.Rout
# draw plot
	@$(R_PATH)/R --no-save --no-restore CMD BATCH "--args type='abundant' lenFile='$(DOC_DIR)/all_samples_genome_mapping_readlen.data' figFile='$(PIC_DIR)/plotGenomeMappingReadSize.png'" $(SCRIPT_DIR)/plotLenDistr.R  $(LOGS_DIR)/plotLenDistr.Rout
	@echo "Compute length distribution after mapping, and draw length distribution plot -> done"


## calculate length of distinct reads after mapping
mapping_distinct_read_length: mapping_read_seq
	@echo "--------------------------------------------" >> $(LOGFILE)
	@date >> $(LOGFILE)
	@echo "compute length distribution of distinct reads after mapping, and draw length distribution plot..." >> $(LOGFILE)

	@$(foreach r, $(ALNBAM_GENOME), $(AWK_PATH)/awk -v name=$(basename $(notdir $(r))) 'BEGIN{OFS="\t"}{if(($$0!~/>/) && (!read[$$1])){size=length($$1); len[size]++; read[$$1]=1}} END{print "idx",name; for(i in len){print i,len[i]|"sort -n"}}' $(DATA_DIR)/$(basename $(notdir $(r)))_map.fas > $(DATA_DIR)/$(basename $(notdir $(r)))_genome_mapping_distinct_readlen.data;)
# combile length count files
	@$(PERL_PATH)/perl $(SCRIPT_DIR)/combineFiles.pl $(SAMPLE_GENOME_DISTINCT_READLEN) > $(DOC_DIR)/all_samples_genome_mapping_distinct_readlen.data
	@$(R_PATH)/R --no-save --no-restore CMD BATCH "--args tabFile='$(DOC_DIR)/all_samples_genome_mapping_distinct_readlen.data'" $(SCRIPT_DIR)/modifyColname.R  $(LOGS_DIR)/modifyColName.Rout
# draw plot
	@$(R_PATH)/R --no-save --no-restore CMD BATCH "--args type='distinct' lenFile='$(DOC_DIR)/all_samples_genome_mapping_distinct_readlen.data' figFile='$(PIC_DIR)/plotGenomeMappingDistinctReadSize.png'" $(SCRIPT_DIR)/plotLenDistr.R  $(LOGS_DIR)/plotLenDistr.Rout
	@echo "Compute length distribution of distinct reads after mapping, and draw length distribution plot -> done"


## calculate number of mapped abundant reads and unmapped abundant reads in the genome, and draw mapping plot
COUNTX=
mapping_stat: $(ALNBAM_GENOME)
	@echo "--------------------------------------------" >> $(LOGFILE)
	@date >> $(LOGFILE)
	@echo "compute number of mapped reads and unmapped reads in the genome, and draw mapping plot..." >> $(LOGFILE)

# generate mapping stat file for each bam file	
	@$(foreach r, $(ALNBAM_GENOME), $(eval COUNTX := $(call increment,$(COUNTX))) $(eval this_sample_name := $(word $(words $(COUNTX)),$(subst $(comma),$(space),$(SAMPLE_NAME)))) $(SAMTOOLS_PATH)/samtools view $(r) | $(AWK_PATH)/awk -v readname=$(this_sample_name) 'BEGIN{FS="\t";OFS="\t";mmap=0;umap=0;unmap=0;print "idx",readname;}{ if(!read[$$1]){read[$$1]=1; lrname=split($$1,rname,"_"); read_num=rname[lrname]; if($$3=="*") {unmap=unmap+read_num} else{if ($$15=="XX:i:1" || $$16=="XX:i:1"){umap=umap+read_num}else{mmap=mmap+read_num}}}}END{print "unmapped",unmap; print "uniq_mapped",umap;print "multi_mapped",mmap;print "mapped",mmap+umap}' > $(DATA_DIR)/$(basename $(notdir $(r)))_mappingstat.data;)
# combine all mapping stat file together
	@$(PERL_PATH)/perl $(SCRIPT_DIR)/combineFiles.pl $(SAMPLE_MAPPING_STAT) > $(DOC_DIR)/all_samples_genome_mappingstat.data
# draw plot
	@$(R_PATH)/R --no-save --no-restore CMD BATCH "--args mapFile='$(DOC_DIR)/all_samples_genome_mappingstat.data' picDir='$(PIC_DIR)' Type='genome'" $(SCRIPT_DIR)/plotMappingPortion.R  $(LOGS_DIR)/plotMappingPortion.Rout
	@echo "Compute number of mapped reads and unmapped reads in the genome, and draw mapping plot -> done"

## calculate number of mapped distinct reads
COUNTY=
mapping_stat_distinct: mapping_read_seq $(ALNBAM_GENOME)
	@echo "--------------------------------------------" >> $(LOGFILE)
	@date >> $(LOGFILE)
	@echo "compute number of mapped distinct reads ..." >> $(LOGFILE)

# generate distinct read mapping stat file for each mapped read file. Since mapping read file only contain mapped reads, to keep the same format as results from mapping_stat step, we also keep unmapped column which is always filled with 0
	@$(foreach r, $(ALNBAM_GENOME), $(eval COUNTY := $(call increment,$(COUNTY))) $(eval this_sample_name := $(word $(words $(COUNTY)),$(subst $(comma),$(space),$(SAMPLE_NAME)))) $(AWK_PATH)/awk -v readname=$(this_sample_name) 'BEGIN{FS="\t";OFS="\t";mmap=0;umap=0;unmap=0;print "idx",readname;}{if(($$0!~/>/) && (!read[$$1])){sum++; read[$$1]=1}}END{print "unmapped","0"; print "mapped",sum}' $(DATA_DIR)/$(basename $(notdir $(r)))_map.fas > $(DATA_DIR)/$(basename $(notdir $(r)))_distinct_mappingstat.data;)
# combine all mapping stat file together
	@$(PERL_PATH)/perl $(SCRIPT_DIR)/combineFiles.pl $(SAMPLE_DISTINCT_MAPPING_STAT) > $(DOC_DIR)/all_samples_genome_distinct_mappingstat.data
	@echo "Compute number of mapped distinct reads -> done"
	@echo "\\033[0;34m""Genome mapping statistics -> done""\\033[0;39m"


######################################
## Generate miRNA, Rfam, RepeatMasker gff files 
######################################

##generate gff file for mature mirna from mirbase
mirbase_mature_gff:
#create an faked gff file if not exist
        #ifeq ("$(wildcard $(MATURE_MIRNA_GFF))","")
#	@echo "XXNNN	1	2" > $(MATURE_MIRNA_GFF)
        #endif
# check whether the item is blank, if not, for each family separated by comma, generate gff file respectively
        ifneq ($(strip $(MATURE_MIRNA)),)  
	@echo "--------------------------------------------" >> $(LOGFILE)
	@date >> $(LOGFILE)
	@echo "Generating mature mirna gff file..." >> $(LOGFILE)
	@echo "--------------------------------------------"
	@echo "\\033[0;34m""Generating mature mirna gff file -> done""\\033[0;39m"
	@$(foreach nc_item,$(subst $(comma),$(space),$(MATURE_MIRNA)), echo "$(PERL_PATH)/perl $(SCRIPT_DIR)/CreateNcRNAgff.pl -i $(MATURE_MIRNA_GFF) -w $(nc_item) -d $(ANNOT_DIR) > $(patsubst %, $(PRO_GFF_DIR)/%$(patsubst miR%,%,$(nc_item)).gff, $(basename $(notdir $(MATURE_MIRNA_GFF))))" >> $(GET_FAMGFF_LOGFILE); $(PERL_PATH)/perl $(SCRIPT_DIR)/CreateNcRNAgff.pl -i $(MATURE_MIRNA_GFF) -w $(nc_item) -d $(ANNOT_DIR) > $(patsubst %, $(PRO_GFF_DIR)/%_$(nc_item).gff, $(basename $(notdir $(MATURE_MIRNA_GFF)))); echo "" >> $(patsubst %, $(PRO_GFF_DIR)/%_$(nc_item).gff, $(basename $(notdir $(MATURE_MIRNA_GFF))));)
	@echo "\\033[0;34m""Generating mature mirna gff file -> done""\\033[0;39m"
        endif

##generate gff file for premirna from mirbase
mirbase_precursor_gff: 
#create an faked gff file if not exist
        #ifeq ("$(wildcard $(PRECURSOR_MIRNA_GFF))","")  
#	@echo "XXNNN	1	2" > $(PRECURSOR_MIRNA_GFF)
        #endif
 # check whether the item is blank, if not, for each family separated by comma, generate gff file respectively
        ifneq ($(strip $(PRECURSOR_MIRNA)),)  
	@echo "--------------------------------------------" >> $(LOGFILE)
	@date >> $(LOGFILE)
	@echo "Generating precursor mirna gff file..." >> $(LOGFILE)
	@echo "--------------------------------------------"
	@echo "\\033[0;34m""Generating precursor mirna gff file""\\033[0;39m"
	@$(foreach nc_item,$(subst $(comma),$(space),$(PRECURSOR_MIRNA)), echo "$(PERL_PATH)/perl $(SCRIPT_DIR)/CreateNcRNAgff.pl -i $(PRECURSOR_MIRNA_GFF) -w $(nc_item) -d $(ANNOT_DIR) > $(patsubst %, $(PRO_GFF_DIR)/%$(patsubst miR%,%,$(nc_item)).gff, $(basename $(notdir $(PRECURSOR_MIRNA_GFF))))" >> $(GET_FAMGFF_LOGFILE); $(PERL_PATH)/perl $(SCRIPT_DIR)/CreateNcRNAgff.pl -i $(PRECURSOR_MIRNA_GFF) -w $(nc_item) -d $(ANNOT_DIR) > $(patsubst %, $(PRO_GFF_DIR)/%_$(nc_item).gff, $(basename $(notdir $(PRECURSOR_MIRNA_GFF)))); echo "" >>  $(patsubst %, $(PRO_GFF_DIR)/%_$(nc_item).gff, $(basename $(notdir $(PRECURSOR_MIRNA_GFF))));)
	@echo "\\033[0;34m""Generating precursor mirna gff file -> done""\\033[0;39m"
        endif

##generate gff files for specified ncRNA families from rfam
rfam_ncrna_ex_gff: $(ACA_SNORNA_ITEM) $(CD_SNORNA_ITEM)
#create an faked gff file if not exist
        #ifeq ("$(wildcard $(RFAM_GFF))","") 
#	@echo "XXNNN	1	2" >  $(RFAM_GFF)
        #endif
# check whether the item is blank, if not, for each family separated by comma, generate gff file respectively
        ifneq ($(strip $(NCRNA_RFAM_EX)),) 
	@echo "--------------------------------------------"
	@date
	@echo "Generating separate gff files for specified Rfam ncRNA families..."
	@echo "--------------------------------------------"
	@echo "\\033[0;34m""Create gff file for special ncrna family""\\033[0;39m"
	@$(foreach nc_item,$(subst $(comma),$(space),$(NCRNA_RFAM_EX)), echo "$(PERL_PATH)/perl $(SCRIPT_DIR)/CreateNcRNAgff.pl -i $(RFAM_GFF) -w $(nc_item) -d $(ANNOT_DIR) > $(patsubst %, $(PRO_GFF_DIR)/%_$(nc_item).gff, $(basename $(notdir $(RFAM_GFF))))" >> $(GET_FAMGFF_LOGFILE); $(PERL_PATH)/perl $(SCRIPT_DIR)/CreateNcRNAgff.pl -i $(RFAM_GFF) -w $(nc_item) -d $(ANNOT_DIR) > $(patsubst %, $(PRO_GFF_DIR)/%_$(nc_item).gff, $(basename $(notdir $(RFAM_GFF)))); echo "" >> $(patsubst %, $(PRO_GFF_DIR)/%_$(nc_item).gff, $(basename $(notdir $(RFAM_GFF))));)
	@echo "\\033[0;34m""Generating separate gff files for specified Rfam ncRNA families -> done""\\033[0;39m"
        endif

##generate gff files for specified repeat families from repeatmasker
rmsk_ncrna_ex_gff: 
#create an faked gff file if not exist
        #ifeq ("$(wildcard $(RMSK_GFF))","")  
#	@echo "XXNNN	1	2" > $(RMSK_GFF)
        #endif
# check whether the item is blank, if not, for each family separated by comma, generate gff file respectively
        ifneq ($(strip $(NCRNA_RMSK_EX)),)  
	@echo "--------------------------------------------"
	@date
	@echo "Generating separate gff files for specified RepeatMasker ncRNA families..."
	@$(foreach nc_item,$(subst $(comma),$(space),$(NCRNA_RMSK_EX)), echo "$(PERL_PATH)/perl $(SCRIPT_DIR)/CreateNcRNAgff.pl -i $(RMSK_GFF) -w $(nc_item) -d $(ANNOT_DIR) > $(patsubst %, $(PRO_GFF_DIR)/%_$(nc_item).gff, $(basename $(notdir $(RMSK_GFF))))" >> $(GET_FAMGFF_LOGFILE); $(PERL_PATH)/perl $(SCRIPT_DIR)/CreateNcRNAgff.pl -i $(RMSK_GFF) -w $(nc_item) -d $(ANNOT_DIR) > $(patsubst %, $(PRO_GFF_DIR)/%_$(nc_item).gff, $(basename $(notdir $(RMSK_GFF)))); echo "" >> $(patsubst %, $(PRO_GFF_DIR)/%_$(nc_item).gff, $(basename $(notdir $(RMSK_GFF))));)
	@echo "Generating separate gff files for specified RepeatMasker ncRNA families -> done"
        endif

##generate gff file for trna from ucsc genome browser
ucsc_trna_gff: 
 #create an faked gff file if not exist
        #ifeq ("$(wildcard $(TRNA_GFF))","")  
#	@echo "XXNNN	1	2" > $(TRNA_GFF)
        #endif
# check whether the item is blank, if not, for each family separated by comma, generate gff file respectively
        ifneq ($(strip $(TRNA_UCSC)),)  
	@echo "--------------------------------------------"
	@date
	@echo "Generating ucsc trna gff file..."
	@$(foreach nc_item,$(subst $(comma),$(space),$(TRNA_UCSC)), echo "$(PERL_PATH)/perl $(SCRIPT_DIR)/CreateNcRNAgff.pl -i $(TRNA_GFF) -w $(nc_item) -d $(ANNOT_DIR) > $(patsubst %, $(PRO_GFF_DIR)/%$(patsubst tRNA%,%,$(nc_item)).gff, $(basename $(notdir $(TRNA_GFF))))" >> $(GET_FAMGFF_LOGFILE); $(PERL_PATH)/perl $(SCRIPT_DIR)/CreateNcRNAgff.pl -i $(TRNA_GFF) -w $(nc_item) -d $(ANNOT_DIR) > $(patsubst %, $(PRO_GFF_DIR)/%_$(nc_item).gff, $(basename $(notdir $(TRNA_GFF)))); echo "" >> $(patsubst %, $(PRO_GFF_DIR)/%_$(nc_item).gff, $(basename $(notdir $(TRNA_GFF))));)
	@echo "Generating ucsc trna gff file -> done"
        endif


######################################
## Annotation of ncRNA
######################################

## align bam files to Rfam gff file
intersectbam_rfamgff: $(ALNBAM_GENOME) 
#create an faked gff file if not exist
        #ifeq ("$(wildcard $(RFAM_GFF))","")
#	@echo "XXNNN	1	2" >  $(RFAM_GFF)
        #endif
	@echo "--------------------------------------------" >> $(LOGFILE)
	@date >> $(LOGFILE)
	@echo "intersect bam file with Rfam gff files..." >> $(LOGFILE)
	@echo "--------------------------------------------"
	@echo "\\033[0;34m""Annotation of ncRNA""\\033[0;39m"
	@$(foreach r, $(ALNBAM_GENOME), $(BEDTOOLS_PATH)/bamToBed -i $(r) -tag XX | $(BEDTOOLS_PATH)/intersectBed -f 1 -a stdin -b $(RFAM_GFF) -wa -wb > $(patsubst %.bam, %_$(basename $(notdir $(RFAM_GFF))).bed, $(DATA_DIR)/$(notdir $(r)));)
	@echo "Align bam files to Rfam gff file -> done"

##match class keyword to rfam_bed file to generate class-specific read-mapping bed file
select_rfam_class_bed: intersectbam_rfamgff
	@echo "--------------------------------------------" >> $(LOGFILE)
	@date >> $(LOGFILE)
	@echo "match class keyword to rfam_bed file to generate class-specific read-mapping bed file..." >> $(LOGFILE)
        ifneq ($(strip $(NCRNA_RFAM)),)
	@$(foreach r, $(subst $(comma),$(space),$(NCRNA_RFAM)), $(foreach g, $(ALNBED_RFAM), $(PERL_PATH)/perl $(SCRIPT_DIR)/selectClassBed.pl -i $(g) -w $(r) -d $(ANNOT_DIR)> $(basename $(g))_$(r)_ncRNA.bed;))
	@echo "Match class keyword to rfam_bed file to generate class-specific read-mapping bed file -> done"
        endif

######################################
## Annotation of repeats
######################################

# ## align bam file to RepeatMasker gff file
# intersectbam_rmskgff: $(ALNBAM_GENOME)
# #create an faked gff file if not exist
#        ifeq ("$(wildcard $(RMSK_GFF))","")  
# 	@echo "XXNNN	1	2" > $(RMSK_GFF)
#         endif
# 	@echo "--------------------------------------------" >> $(LOGFILE)
# 	@date >> $(LOGFILE)
# 	@echo "intersect bam file with RepeatMasker gff files..." >> $(LOGFILE)
# 	$(foreach r, $(ALNBAM_GENOME), $(BEDTOOLS_PATH)/bamToBed -i $(r) -tag XX | $(BEDTOOLS_PATH)/intersectBed -f 1 -a stdin -b $(RMSK_GFF) -wa -wb > $(patsubst %.bam, %_$(basename $(notdir $(RMSK_GFF))).bed,$(DATA_DIR)/$(notdir $(r)));)

## align bam file to RepeatMasker gff file
intersectbam_rmskgff: $(ALNBAM_GENOME)
#create an faked gff file if not exist
       #ifeq ("$(wildcard $(RMSK_GFF))","")  
#	@echo "XXNNN	1	2" > $(RMSK_GFF)
        #endif
	@echo "--------------------------------------------" >> $(LOGFILE)
	@date >> $(LOGFILE)
	@echo "intersect bam file with RepeatMasker gff files..." >> $(LOGFILE)
	@echo "--------------------------------------------"
	@echo "\\033[0;34m""Annotation of repeats""\\033[0;39m"
	@$(foreach r, $(ALNBAM_GENOME), $(BEDTOOLS_PATH)/bamToBed -i $(r) -tag XX | $(BEDTOOLS_PATH)/intersectBed -f 1 -a stdin -b $(RFAM_GFF) -wa -v | $(BEDTOOLS_PATH)/intersectBed -f 1 -a stdin -b $(RMSK_GFF) -wa -wb > $(patsubst %.bam, %_$(basename $(notdir $(RMSK_GFF))).bed,$(DATA_DIR)/$(notdir $(r)));)
	@echo "Intersect bam file with RepeatMasker gff files -> done"

##match class keyword to rmsk_bed file to generate class-specific read-mapping bed file
select_rmsk_class_bed: intersectbam_rmskgff
	@echo "--------------------------------------------" >> $(LOGFILE)
	@date >> $(LOGFILE)
	@echo "match class keyword to rmsk_bed file to generate class-specific read-mapping bed file..." >> $(LOGFILE)
	@echo "--------------------------------------------"
	@echo "\\033[0;34m""Ncrna family analyses, including read coverage, read length distribution, read coverage in subfamilies, sequence logo""\\033[0;39m"
        ifneq ($(strip $(NCRNA_RMSK)),)
	@$(foreach r, $(subst $(comma),$(space),$(NCRNA_RMSK)), $(foreach g, $(ALNBED_RMSK), $(PERL_PATH)/perl $(SCRIPT_DIR)/selectClassBed.pl -i $(g) -w $(r) > $(basename $(g))_$(r)_ncRNA.bed;))
	@echo "Match class keyword to rmsk_bed file to generate class-specific read-mapping bed file -> done"
        endif

######################################
## Annotation of ncRNAs and repeats which have extended items
######################################

## align bam files to gff files of each ncRNA family
intersectbam_subgff: $(ALNBAM_GENOME)
        ifneq ($(strip $(OTHER_NCRNA_GFF)),)
        ifneq ("$(wildcard $(OTHER_NCRNA_GFF))","")  
	@echo "--------------------------------------------" >> $(LOGFILE)
	@date >> $(LOGFILE)
	@echo "intersect bam file with ncRNA gff files..." >> $(LOGFILE)
	@$(foreach r, $(OTHER_NCRNA_GFF), cp $(r) $(PRO_GFF_DIR);)
        endif
        endif
	@$(foreach r, $(ALNBAM_GENOME), $(foreach g, $(PRO_NCGFF_FILE), $(BEDTOOLS_PATH)/bamToBed -i $(r) -tag XX | $(BEDTOOLS_PATH)/intersectBed -f 1 -a stdin -b $(g) -wa -wb > $(patsubst %.bam, %_$(notdir $(basename $(g)))_ncRNA.bed, $(DATA_DIR)/$(notdir $(r)));))
	@echo "Intersect bam file with ncRNA gff files -> done"


######################################
## Utils to process both ncRNAs and repeats families
######################################

## calculate read coverage
ncrna_read_basecov: mapping_stat mapping_stat_distinct $(ALNBED_NCRNA)
	@echo "--------------------------------------------" >> $(LOGFILE)
	@date >> $(LOGFILE)
	@echo "compute read coverage for each ncRNA family..." >> $(LOGFILE)	
	@$(foreach r, $(ALNBED_NCRNA), $(PERL_PATH)/perl $(SCRIPT_DIR)/scaledBaseCoverage.pl -i $(r) -s 1 -n 1000 -f $(DATA_DIR)/$(basename $(notdir $(r)))_scaled_basecov_abundant;)
	@$(foreach r, $(subst $(comma),$(space),$(ALL_NCRNA)), $(foreach g, $(PROFILE_TYPE), $(PERL_PATH)/perl $(SCRIPT_DIR)/combineFiles.pl $(patsubst %,$(DATA_DIR)/%_$(r)_ncRNA_scaled_basecov_abundant_$(g).data,$(basename $(notdir $(ALNBAM_GENOME)))) > $(DOC_DIR)/$(r)_all_samples_scaled_basecov_abundant_$(g).data;))
	@$(foreach r, $(subst $(comma),$(space),$(ALL_NCRNA)), $(foreach g, $(PROFILE_TYPE), $(R_PATH)/R --no-save --no-restore CMD BATCH "--args tabFile='$(DOC_DIR)/$(r)_all_samples_scaled_basecov_abundant_$(g).data'" $(SCRIPT_DIR)/modifyColname.R  $(LOGS_DIR)/modifyColName.Rout;))
	@$(foreach r, $(subst $(comma),$(space),$(ALL_NCRNA)), $(foreach g, $(PROFILE_TYPE), $(R_PATH)/R --no-save --no-restore CMD BATCH "--args mapFile='$(DOC_DIR)/all_samples_genome_mappingstat.data' covFile='$(DOC_DIR)/$(r)_all_samples_scaled_basecov_abundant_$(g).data'  outFile='$(DOC_DIR)/$(r)_all_samples_scaled_basecov_abundant_$(g)_RPM.data' Type='basecov'" $(SCRIPT_DIR)/readCovNormalization.R  $(LOGS_DIR)/readCovNormalization.Rout;))
####if group_read option is used, another information about the base coverage of distinct read counts will be computed
        ifneq ($(strip $(GROUP_READ)),0)
	@$(foreach r, $(ALNBED_NCRNA), $(PERL_PATH)/perl $(SCRIPT_DIR)/scaledBaseCoverage.pl -i $(r) -s 0 -n 1000 -f $(DATA_DIR)/$(basename $(notdir $(r)))_scaled_basecov_distinct;)
	@$(foreach r, $(subst $(comma),$(space),$(ALL_NCRNA)), $(foreach g, $(PROFILE_TYPE), $(PERL_PATH)/perl $(SCRIPT_DIR)/combineFiles.pl $(patsubst %,$(DATA_DIR)/%_$(r)_ncRNA_scaled_basecov_distinct_$(g).data,$(basename $(notdir $(ALNBAM_GENOME)))) > $(DOC_DIR)/$(r)_all_samples_scaled_basecov_distinct_$(g).data;)) 
	@$(foreach r, $(subst $(comma),$(space),$(ALL_NCRNA)), $(foreach g, $(PROFILE_TYPE), $(R_PATH)/R --no-save --no-restore CMD BATCH "--args tabFile='$(DOC_DIR)/$(r)_all_samples_scaled_basecov_distinct_$(g).data'" $(SCRIPT_DIR)/modifyColname.R  $(LOGS_DIR)/modifyColName.Rout;))
	@$(foreach r, $(subst $(comma),$(space),$(ALL_NCRNA)), $(foreach g, $(PROFILE_TYPE), $(R_PATH)/R --no-save --no-restore CMD BATCH "--args mapFile='$(DOC_DIR)/all_samples_genome_distinct_mappingstat.data' covFile='$(DOC_DIR)/$(r)_all_samples_scaled_basecov_distinct_$(g).data'  outFile='$(DOC_DIR)/$(r)_all_samples_scaled_basecov_distinct_$(g)_RPM.data' Type='basecov'" $(SCRIPT_DIR)/readCovNormalization.R  $(LOGS_DIR)/readCovNormalization.Rout;))
        endif
	@echo "Compute read coverage for each ncRNA family -> done"

## calculate read length distribution for each ncRNA family
ncrna_read_length: $(ALNBED_NCRNA)
	@echo "--------------------------------------------" >> $(LOGFILE)
	@date >> $(LOGFILE)
	@echo "compute read length distribution for each ncRNA family..." >> $(LOGFILE)	
## length distribution for total reads
	@$(foreach r, $(ALNBED_NCRNA), $(AWK_PATH)/awk -v sample=$(basename $(notdir $(r))) 'BEGIN{OFS="\t"}{if(!read[$$4$$1$$2]){lrname=split($$4,rname,"_");read_num=rname[lrname];len[$$3-$$2]+=read_num/$$5} read[$$4$$1$$2]=1} END{print "idx",sample; for(i in len){print i,len[i]|"sort -n"}}' $(r) > $(DATA_DIR)/$(basename $(notdir $(r)))_total_readlen_abundant.data;)
	@$(foreach r, $(subst $(comma),$(space),$(ALL_NCRNA)), $(PERL_PATH)/perl $(SCRIPT_DIR)/combineFiles.pl $(patsubst %,$(DATA_DIR)/%_$(r)_ncRNA_total_readlen_abundant.data,$(basename $(notdir $(ALNBAM_GENOME)))) > $(DOC_DIR)/$(r)_all_samples_total_readlen_abundant.data;)
	@$(foreach r, $(subst $(comma),$(space),$(ALL_NCRNA)), $(R_PATH)/R --no-save --no-restore CMD BATCH "--args tabFile='$(DOC_DIR)/$(r)_all_samples_total_readlen_abundant.data'" $(SCRIPT_DIR)/modifyColname.R  $(LOGS_DIR)/modifyColName.Rout;)	
## length distribution for reads mapped in sense direction
	@$(foreach r, $(ALNBED_NCRNA), $(AWK_PATH)/awk -v sample=$(basename $(notdir $(r))) 'BEGIN{OFS="\t"}{if($$6==$$13){if(!read[$$4$$1$$2]){lrname=split($$4,rname,"_");read_num=rname[lrname];len[$$3-$$2]+=read_num/$$5} read[$$4$$1$$2]=1}} END{print "idx",sample; for(i in len){print i,len[i]|"sort -n"}}' $(r) > $(DATA_DIR)/$(basename $(notdir $(r)))_sense_readlen_abundant.data;)
	@$(foreach r, $(subst $(comma),$(space),$(ALL_NCRNA)), $(PERL_PATH)/perl $(SCRIPT_DIR)/combineFiles.pl $(patsubst %,$(DATA_DIR)/%_$(r)_ncRNA_sense_readlen_abundant.data,$(basename $(notdir $(ALNBAM_GENOME)))) > $(DOC_DIR)/$(r)_all_samples_sense_readlen_abundant.data;)
	@$(foreach r, $(subst $(comma),$(space),$(ALL_NCRNA)), $(R_PATH)/R --no-save --no-restore CMD BATCH "--args tabFile='$(DOC_DIR)/$(r)_all_samples_sense_readlen_abundant.data'" $(SCRIPT_DIR)/modifyColname.R  $(LOGS_DIR)/modifyColName.Rout;)
## length distribution for reads mapped in antisense direction
	@$(foreach r, $(ALNBED_NCRNA), $(AWK_PATH)/awk -v sample=$(basename $(notdir $(r))) 'BEGIN{OFS="\t"}{if($$6!=$$13){if(!read[$$4$$1$$2]){lrname=split($$4,rname,"_");read_num=rname[lrname];len[$$3-$$2]+=read_num/$$5} read[$$4$$1$$2]=1}} END{print "idx",sample; for(i in len){print i,len[i]|"sort -n"}}' $(r) > $(DATA_DIR)/$(basename $(notdir $(r)))_antisense_readlen_abundant.data;)
	@$(foreach r, $(subst $(comma),$(space),$(ALL_NCRNA)), $(PERL_PATH)/perl $(SCRIPT_DIR)/combineFiles.pl $(patsubst %,$(DATA_DIR)/%_$(r)_ncRNA_antisense_readlen_abundant.data,$(basename $(notdir $(ALNBAM_GENOME)))) > $(DOC_DIR)/$(r)_all_samples_antisense_readlen_abundant.data;)
	@$(foreach r, $(subst $(comma),$(space),$(ALL_NCRNA)), $(R_PATH)/R --no-save --no-restore CMD BATCH "--args tabFile='$(DOC_DIR)/$(r)_all_samples_antisense_readlen_abundant.data'" $(SCRIPT_DIR)/modifyColname.R  $(LOGS_DIR)/modifyColName.Rout;)
        ifneq ($(strip $(GROUP_READ)),0)
	@$(foreach r, $(ALNBED_NCRNA), $(AWK_PATH)/awk -v sample=$(basename $(notdir $(r))) 'BEGIN{OFS="\t"}{if(!read[$$4$$1$$2]){len[$$3-$$2]+=1/$$5} read[$$4$$1$$2]=1} END{print "idx",sample; for(i in len){print i,len[i]|"sort -n"}}' $(r) > $(DATA_DIR)/$(basename $(notdir $(r)))_total_readlen_distinct.data;)
	@$(foreach r, $(subst $(comma),$(space),$(ALL_NCRNA)), $(PERL_PATH)/perl $(SCRIPT_DIR)/combineFiles.pl $(patsubst %,$(DATA_DIR)/%_$(r)_ncRNA_total_readlen_distinct.data,$(basename $(notdir $(ALNBAM_GENOME)))) > $(DOC_DIR)/$(r)_all_samples_total_readlen_distinct.data;)
	@$(foreach r, $(subst $(comma),$(space),$(ALL_NCRNA)), $(R_PATH)/R --no-save --no-restore CMD BATCH "--args tabFile='$(DOC_DIR)/$(r)_all_samples_total_readlen_distinct.data'" $(SCRIPT_DIR)/modifyColname.R  $(LOGS_DIR)/modifyColName.Rout;)
## length distribution for reads mapped in sense direction
	@$(foreach r, $(ALNBED_NCRNA), $(AWK_PATH)/awk -v sample=$(basename $(notdir $(r))) 'BEGIN{OFS="\t"}{if($$6==$$13){if(!read[$$4$$1$$2]){len[$$3-$$2]+=1/$$5} read[$$4$$1$$2]=1}} END{print "idx",sample; for(i in len){print i,len[i]|"sort -n"}}' $(r) > $(DATA_DIR)/$(basename $(notdir $(r)))_sense_readlen_distinct.data;)
	@$(foreach r, $(subst $(comma),$(space),$(ALL_NCRNA)), $(PERL_PATH)/perl $(SCRIPT_DIR)/combineFiles.pl $(patsubst %,$(DATA_DIR)/%_$(r)_ncRNA_sense_readlen_distinct.data,$(basename $(notdir $(ALNBAM_GENOME)))) > $(DOC_DIR)/$(r)_all_samples_sense_readlen_distinct.data;)
	@$(foreach r, $(subst $(comma),$(space),$(ALL_NCRNA)), $(R_PATH)/R --no-save --no-restore CMD BATCH "--args tabFile='$(DOC_DIR)/$(r)_all_samples_sense_readlen_distinct.data'" $(SCRIPT_DIR)/modifyColname.R  $(LOGS_DIR)/modifyColName.Rout;)
## length distribution for reads mapped in antisense direction
	@$(foreach r, $(ALNBED_NCRNA), $(AWK_PATH)/awk -v sample=$(basename $(notdir $(r))) 'BEGIN{OFS="\t"}{if($$6!=$$13){if(!read[$$4$$1$$2]){len[$$3-$$2]+=1/$$5} read[$$4$$1$$2]=1}} END{print "idx",sample; for(i in len){print i,len[i]|"sort -n"}}' $(r) > $(DATA_DIR)/$(basename $(notdir $(r)))_antisense_readlen_distinct.data;)
	@$(foreach r, $(subst $(comma),$(space),$(ALL_NCRNA)), $(PERL_PATH)/perl $(SCRIPT_DIR)/combineFiles.pl $(patsubst %,$(DATA_DIR)/%_$(r)_ncRNA_antisense_readlen_distinct.data,$(basename $(notdir $(ALNBAM_GENOME)))) > $(DOC_DIR)/$(r)_all_samples_antisense_readlen_distinct.data;)
	@$(foreach r, $(subst $(comma),$(space),$(ALL_NCRNA)), $(R_PATH)/R --no-save --no-restore CMD BATCH "--args tabFile='$(DOC_DIR)/$(r)_all_samples_antisense_readlen_distinct.data'" $(SCRIPT_DIR)/modifyColname.R  $(LOGS_DIR)/modifyColName.Rout;)
        endif
	@echo "Compute read length distribution for each ncRNA family -> done"

## read coverage of each sub-family in ncRNA families
ncrna_subfam_coverage: mapping_stat 
        ifneq ($(strip $(ALNBED_NCRNA)),) 
	@echo "--------------------------------------------" >> $(LOGFILE)
	@date >> $(LOGFILE)
	@echo "Compute read coverage for each sub-family in ncRNA families..." >> $(LOGFILE)
	@$(foreach r, $(ALNBED_NCRNA), $(PERL_PATH)/perl $(SCRIPT_DIR)/famReadCov.pl -i $(r) -p "Name|Alias|ID" -x $(SAMPLE_NAME) > $(DATA_DIR)/$(basename $(notdir $(r)))_subfamcov.data;)
	@$(foreach r, $(subst $(comma),$(space),$(ALL_NCRNA)), $(PERL_PATH)/perl $(SCRIPT_DIR)/combineFiles.pl $(patsubst %,$(DATA_DIR)/%_$(r)_ncRNA_subfamcov.data,$(basename $(notdir $(ALNBAM_GENOME)))) > $(DOC_DIR)/$(r)_all_samples_subfamcov.data;)
	@$(foreach r, $(subst $(comma),$(space),$(ALL_NCRNA)), $(R_PATH)/R --no-save --no-restore CMD BATCH "--args mapFile='$(DOC_DIR)/all_samples_genome_mappingstat.data' covFile='$(DOC_DIR)/$(r)_all_samples_subfamcov.data'  outFile='$(DOC_DIR)/$(r)_all_samples_subfamcov_RPM.data' Type='subfam'" $(SCRIPT_DIR)/readCovNormalization.R  $(LOGS_DIR)/readCovNormalization.Rout;)
        endif

        ifeq ($(strip $(FILTER_ZERO_COUNTS)),0)
	@echo "--------------------------------------------" >> $(LOGFILE)
	@date >> $(LOGFILE)
	@echo "Add all miRNAs in result file..." >> $(LOGFILE)

	@$(foreach r, $(MATURE_MIRNA_TEST), $(PYTHON_PATH)/python $(SCRIPT_DIR)/filter_zero_count.py -i $(DOC_DIR)/$(r)_all_samples_subfamcov.data -p $(MATURE_MIRNA_GFF) > $(DOC_DIR)/$(r)_all_samples_subfamcov_all_miRNA.data;)
	@$(foreach r, $(PRECURSOR_MIRNA_TEST), $(PYTHON_PATH)/python $(SCRIPT_DIR)/filter_zero_count.py -i $(DOC_DIR)/$(r)_all_samples_subfamcov.data -p $(PRECURSOR_MIRNA_GFF) > $(DOC_DIR)/$(r)_all_samples_subfamcov_all_miRNA.data;)
	@$(foreach r, $(MATURE_MIRNA_TEST), $(PYTHON_PATH)/python $(SCRIPT_DIR)/filter_zero_count.py -i $(DOC_DIR)/$(r)_all_samples_subfamcov.data -p $(MATURE_MIRNA_GFF) > $(DOC_DIR)/$(r)_all_samples_subfamcov_RPM_all_miRNA.data;)
	@$(foreach r, $(PRECURSOR_MIRNA_TEST), $(PYTHON_PATH)/python $(SCRIPT_DIR)/filter_zero_count.py -i $(DOC_DIR)/$(r)_all_samples_subfamcov.data -p $(PRECURSOR_MIRNA_GFF) > $(DOC_DIR)/$(r)_all_samples_subfamcov_RPM_all_miRNA.data;)
	
        endif
	@echo "Compute read coverage for each sub-family in ncRNA families -> done"

## generate logo matrix for reads in each ncrna family
seq_logo_matrix: mapping_read_seq ncrna_read_length $(ALNBED_NCRNA)
	@echo "--------------------------------------------" >> $(LOGFILE)
	@date >> $(LOGFILE)
	@echo "generate logo matrix for ncrna related reads..." >> $(LOGFILE)
	@$(foreach r, $(basename $(notdir $(ALNREAD_SEQ))), $(foreach g, $(subst $(comma),$(space),$(ALL_NCRNA)), $(foreach d, $(subst $(comma),$(space),$(LOGO_DIRECTION)), $(PERL_PATH)/perl $(SCRIPT_DIR)/readLogoMatrix.pl -r $(DATA_DIR)/$(r)_map.fas -g $(DATA_DIR)/$(r)_$(g)_ncRNA.bed -o $(DATA_DIR)/$(r)_$(g)_$(d) -p $(d) -c "all";)))
	@$(foreach r, $(basename $(notdir $(ALNREAD_SEQ))), $(foreach g, $(subst $(comma),$(space),$(ALL_NCRNA)), $(foreach d, $(subst $(comma),$(space),$(LOGO_DIRECTION)), $(PERL_PATH)/perl $(SCRIPT_DIR)/readLogoMatrix.pl -r $(DATA_DIR)/$(r)_map.fas -g $(DATA_DIR)/$(r)_$(g)_ncRNA.bed -o $(DATA_DIR)/$(r)_$(g)_$(d) -p $(d) -c "unique";)))
	@$(foreach r, $(basename $(notdir $(ALNREAD_SEQ))), $(foreach g, $(subst $(comma),$(space),$(ALL_NCRNA)), $(foreach d, $(subst $(comma),$(space),$(LOGO_DIRECTION)), $(R_PATH)/R --no-save --no-restore CMD BATCH "--args dataDir='$(DATA_DIR)' prefix='$(r)_$(g)' ref='$(notdir $(basename $(BOWTIE_GENOME_REFERENCE)))' ref_cs='$(notdir $(basename $(BOWTIE_GENOME_REFERENCE_CS)))' direction='$(d)' figDir='$(PIC_DIR)'  icscale='$(IC_SCALE)' readtype='all'"  $(SCRIPT_DIR)/plotSeqLogo.R  $(LOGS_DIR)/plotSeqLogo.Rout;)))
	@$(foreach r, $(basename $(notdir $(ALNREAD_SEQ))), $(foreach g, $(subst $(comma),$(space),$(ALL_NCRNA)), $(foreach d, $(subst $(comma),$(space),$(LOGO_DIRECTION)), $(R_PATH)/R --no-save --no-restore CMD BATCH "--args dataDir='$(DATA_DIR)' prefix='$(r)_$(g)' ref='$(notdir $(basename $(BOWTIE_GENOME_REFERENCE)))' ref_cs='$(notdir $(basename $(BOWTIE_GENOME_REFERENCE_CS)))' direction='$(d)' figDir='$(PIC_DIR)'  icscale='$(IC_SCALE)' readtype='unique'"  $(SCRIPT_DIR)/plotSeqLogo.R  $(LOGS_DIR)/plotSeqLogo.Rout;)))
	@echo "Generate logo matrix for ncrna related reads -> done"

#	$(foreach r, $(basename $(notdir $(ALNREAD_SEQ))), $(foreach g, $(subst $(comma),$(space),$(ALL_NCRNA)), $(PERL_PATH)/perl $(SCRIPT_DIR)/readLogoMatrix.pl -r $(DATA_DIR)/$(r).fas -g $(DATA_DIR)/$(r)_$(g)_ncRNA.bed -o $(DATA_DIR)/$(r)_$(g)_$(LOGO_DIRECTION) -p $(LOGO_DIRECTION); $(R_PATH)/R --no-save --no-restore CMD BATCH "--args dataDir='$(DATA_DIR)' lprefix='$(r)' rprefix='$(g)_$(LOGO_DIRECTION)' figFile='$(PIC_DIR)/$(r)_$(g)_$(LOGO_DIRECTION)_NtDistri.png'"  $(SCRIPT_DIR)/plotNtDistri.R  $(LOGS_DIR)/plotNtDistri.Rout;))


## plot read coverage and length distribution for each family
plotSingleFamInfos: 
#	@echo "--------------------------------------------" >> $(LOGFILE)
#	@date >> $(LOGFILE)
#	@echo "plot read coverage and length distribution for each family..." >> $(LOGFILE)	
#	$(foreach r, $(subst $(comma),$(space),$(ALL_NCRNA)), $(R_PATH)/R --no-save --no-restore CMD BATCH "--args baseCov='$(DOC_DIR)/$(r)_all_samples_scaled_basecov_abundant_all_RPM.data' baseCov5end='$(DOC_DIR)/$(r)_all_samples_scaled_basecov_abundant_5end_RPM.data' baseCov3end='$(DOC_DIR)/$(r)_all_samples_scaled_basecov_abundant_3end_RPM.data' senseLen='$(DOC_DIR)/$(r)_all_samples_sense_readlen_abundant.data' antisenseLen='$(DOC_DIR)/$(r)_all_samples_antisense_readlen_abundant.data' allLen='$(DOC_DIR)/$(r)_all_samples_total_readlen_abundant.data' covType='abundant' figDir='$(PIC_DIR)' ncFam='$(r)'" $(SCRIPT_DIR)/plotSingleFamInfos.R  $(LOGS_DIR)/plotSingleFamInfos.Rout;)
#        ifneq ($(strip $(GROUP_READ)),0)
#	$(foreach r, $(subst $(comma),$(space),$(ALL_NCRNA)), $(R_PATH)/R --no-save --no-restore CMD BATCH "--args baseCov='$(DOC_DIR)/$(r)_all_samples_scaled_basecov_distinct_all_RPM.data' baseCov5end='$(DOC_DIR)/$(r)_all_samples_scaled_basecov_distinct_5end_RPM.data' baseCov3end='$(DOC_DIR)/$(r)_all_samples_scaled_basecov_distinct_3end_RPM.data' senseLen='$(DOC_DIR)/$(r)_all_samples_sense_readlen_distinct.data' antisenseLen='$(DOC_DIR)/$(r)_all_samples_antisense_readlen_distinct.data' allLen='$(DOC_DIR)/$(r)_all_samples_total_readlen_distinct.data' covType='distinct' figDir='$(PIC_DIR)' ncFam='$(r)'" $(SCRIPT_DIR)/plotSingleFamInfos.R  $(LOGS_DIR)/plotSingleFamInfos.Rout;)
#        endif

## plot combined read coverage and length distribution for each family
plotCombinedFamProfile: 
	@echo "--------------------------------------------" >> $(LOGFILE)
	@date >> $(LOGFILE)
	@echo "plot combined read coverage and length distribution for each family..." >> $(LOGFILE)	
	@$(foreach r, $(subst $(comma),$(space),$(ALL_NCRNA)), $(R_PATH)/R --no-save --no-restore CMD BATCH "--args baseCov='$(DOC_DIR)/$(r)_all_samples_scaled_basecov_abundant_all_RPM.data' baseCov5end='$(DOC_DIR)/$(r)_all_samples_scaled_basecov_abundant_5end_RPM.data' baseCov3end='$(DOC_DIR)/$(r)_all_samples_scaled_basecov_abundant_3end_RPM.data' senseLen='$(DOC_DIR)/$(r)_all_samples_sense_readlen_abundant.data' antisenseLen='$(DOC_DIR)/$(r)_all_samples_antisense_readlen_abundant.data' allLen='$(DOC_DIR)/$(r)_all_samples_total_readlen_abundant.data' covType='abundant' figDir='$(PIC_DIR)' ncFam='$(r)' multi='0'" $(SCRIPT_DIR)/plotCombinedFamProfile.R  $(LOGS_DIR)/plotCombinedFamProfile.Rout;)
        ifneq ($(strip $(GROUP_READ)),0)
	@$(foreach r, $(subst $(comma),$(space),$(ALL_NCRNA)), $(R_PATH)/R --no-save --no-restore CMD BATCH "--args baseCov='$(DOC_DIR)/$(r)_all_samples_scaled_basecov_distinct_all_RPM.data' baseCov5end='$(DOC_DIR)/$(r)_all_samples_scaled_basecov_distinct_5end_RPM.data' baseCov3end='$(DOC_DIR)/$(r)_all_samples_scaled_basecov_distinct_3end_RPM.data' senseLen='$(DOC_DIR)/$(r)_all_samples_sense_readlen_distinct.data' antisenseLen='$(DOC_DIR)/$(r)_all_samples_antisense_readlen_distinct.data' allLen='$(DOC_DIR)/$(r)_all_samples_total_readlen_distinct.data' covType='distinct' figDir='$(PIC_DIR)' ncFam='$(r)' multi='0'" $(SCRIPT_DIR)/plotCombinedFamProfile.R $(LOGS_DIR)/plotCombinedFamProfile.Rout;)
        endif
	@echo "Plot combined read coverage and length distribution for each family -> done"

plotExpDynamic:
	@echo "--------------------------------------------" >> $(LOGFILE)
	@date >> $(LOGFILE)
	@echo "Heatmap with the most variant genes between each family..." >> $(LOGFILE)	
	@$(foreach r, $(subst $(comma),$(space),$(ALL_NCRNA)),$(R_PATH)/R --no-save --no-restore CMD BATCH "--args subFam='$(DOC_DIR)/$(r)_all_samples_subfamcov_RPM.data' figDir='$(PIC_DIR)' ncFam='$(r)'" $(SCRIPT_DIR)/plotExpHeatmap.R $(LOGS_DIR)/plotExpHeatmap.Rout;)
	@echo "Heatmap with the most variant genes between each family -> done"
	@echo "\\033[0;34m""Ncrna family analyses, including read coverage, read length distribution, read coverage in subfamilies, sequence logo -> done""\\033[0;39m"

sRNA_distance:
#	@echo "--------------------------------------------" >> $(LOGFILE)
#	@date >> $(LOGFILE)
#	@echo "compute distance between reads for each family..." >> $(LOGFILE)
#	$(foreach r, $(ALNBED_NCRNA), $(AWK_PATH)/awk 'BEGIN{OFS="\t"}{if($$13=="+"){ln=$$2-$$10+2;rn=$$3-$$10+2;} else{ln=$$11-$$3+1;rn=$$11-$$2+1}  if($$13==$$6){strand="+"} else{strand="-"} print $$7":"$$10"_"$$11,ln,rn,$$4,$$5,strand}' $(r) > $(basename $(r))_tmp;)
#	$(foreach r, $(ALNBED_NCRNA), sort  -k 1,1 -k 2,2n $(basename $(r))_tmp > $(basename $(r))_tmp_sort; rm -f $(basename $(r))_tmp;)
#	$(foreach r, $(ALNBED_NCRNA), $(PERL_PATH)/perl $(SCRIPT_DIR)/calReadDistance.pl -i $(basename $(r))_tmp_sort -n 50 -s 1 > $(basename $(r))_tmp_sort_abundant;)
#	$(foreach r, $(ALNBED_NCRNA), $(PERL_PATH)/perl $(SCRIPT_DIR)/calReadDistance.pl -i $(basename $(r))_tmp_sort -n 50 -s 0 > $(basename $(r))_tmp_sort_distinct;)
#	$(foreach r, $(ALNBED_NCRNA), $(R_PATH)/R --no-save --no-restore CMD BATCH "--args distanceFile='$(basename $(r))_tmp_sort_abundant' picDir='$(PIC_DIR)' ncinfo='$(basename $(#notdir $(r)))' covType='abundant' figDir='$(PIC_DIR)'" $(SCRIPT_DIR)/plotReadDistance.R  $(LOGS_DIR)/plotReadDistance.Rout;)
#	$(foreach r, $(ALNBED_NCRNA), $(R_PATH)/R --no-save --no-restore CMD BATCH "--args distanceFile='$(basename $(r))_tmp_sort_distinct' picDir='$(PIC_DIR)' ncinfo='$(basename $(#notdir $(r)))' covType='distinct' figDir='$(PIC_DIR)'" $(SCRIPT_DIR)/plotReadDistance.R  $(LOGS_DIR)/plotReadDistance.Rout;)



######################################
## Special output of miRNA mapping proportion to examine the quality of the whole library
######################################

## calculate number of mapped reads and unmapped reads in the genome, and draw mapping plot
COUNTZ=
mirna_stat: mapping_stat
        #ifneq ($(strip $(ALNBED_MIRNA)),)
	@echo "--------------------------------------------" >> $(LOGFILE)
	@date >> $(LOGFILE)
	@echo "compute number of reads annotated as miRNAs, and draw mapping plot..." >> $(LOGFILE)
	@$(foreach gbam, $(ALNBAM_GENOME), $(eval COUNTZ := $(call increment,$(COUNTZ))) $(eval this_sample_name := $(word $(words $(COUNTZ)),$(subst $(comma),$(space),$(SAMPLE_NAME)))) $(BEDTOOLS_PATH)/bamToBed -i $(gbam) -tag XX | $(BEDTOOLS_PATH)/intersectBed -f 1 -a stdin -b $(PRECURSOR_MIRNA_GFF) -wa -wb > $(patsubst %.bam,%_premiR_ncRNA.bed, $(DATA_DIR)/$(notdir $(gbam)));$(AWK_PATH)/awk -v readname=$(this_sample_name) 'BEGIN{FS="\t";OFS="\t";print "idx",readname;}' > $(DATA_DIR)/$(basename $(notdir $(gbam)))_mirnastat.data; $(AWK_PATH)/awk -v info=premiRNA 'BEGIN{OFS="\t";s=0}{if($$6==$$13){nsize=split($$4,n,"_");s=s+n[nsize]/$$5}}END{print info"\t"s}' $(patsubst %.bam,%_premiR_ncRNA.bed, $(DATA_DIR)/$(notdir $(gbam))) >> $(DATA_DIR)/$(basename $(notdir $(gbam)))_mirnastat.data;) 
# combine all mapping stat file together

	@$(PERL_PATH)/perl $(SCRIPT_DIR)/combineFiles.pl $(SAMPLE_MIRNA_STAT) > $(DOC_DIR)/all_samples_genome_mirnastat.data
# draw plot
	@$(R_PATH)/R --no-save --no-restore CMD BATCH "--args mapFile='$(DOC_DIR)/all_samples_genome_mappingstat.data' mirnaFile='$(DOC_DIR)/all_samples_genome_mirnastat.data'  picDir='$(PIC_DIR)' Type='premiRNA'" $(SCRIPT_DIR)/plotMappingPortion.R  $(LOGS_DIR)/plotMappingPortion.Rout
        #endif
	@echo "Compute number of reads annotated as miRNAs, and draw mapping plot -> done"
	@echo "\\033[0;34m""Annotation of ncRNA -> done""\\033[0;39m"


######################################
## overview of read in different annotations
######################################

# intersectbam_genegff:  $(ALNBAM_GENOME)
# #check the presence of file
#         ifneq ("$(wildcard $(PROTEIN_GENE_GFF))","")  
# 	@echo "--------------------------------------------" >> $(LOGFILE)
# 	@date >> $(LOGFILE)
# 	@echo "intersect bam file with gene gff files..." >> $(LOGFILE)
# 	$(foreach r, $(ALNBAM_GENOME), $(BEDTOOLS_PATH)/bamToBed -i $(r) -tag XX | $(BEDTOOLS_PATH)/intersectBed -f 1 -a stdin -b $(PROTEIN_GENE_GFF) -wa -wb > $(patsubst %.bam, %_$(basename $(notdir $(PROTEIN_GENE_GFF))).bed,$(DATA_DIR)/$(notdir $(r)));)
#         else
# #if not exist, create an faked gff file
# 	echo "XXNNN	1	2" > $(PROTEIN_GENE_GFF)
#         endif
# #add "" to avoid 0kb file
# 	$(foreach r, $(ALNBAM_GENOME), echo "" >> $(patsubst %.bam, %_$(basename $(notdir $(PROTEIN_GENE_GFF))).bed,$(DATA_DIR)/$(notdir $(r)));)

# intersectbam_premirgff:  $(ALNBAM_GENOME) 
#         ifneq ("$(wildcard $(PRECURSOR_MIRNA_GFF))","")  
# 	@echo "--------------------------------------------" >> $(LOGFILE)
# 	@date >> $(LOGFILE)
# 	@echo "intersect bam file with precursor mirna gff files..." >> $(LOGFILE)
# 	$(foreach r, $(ALNBAM_GENOME), $(BEDTOOLS_PATH)/bamToBed -i $(r) -tag XX | $(BEDTOOLS_PATH)/intersectBed -f 1 -a stdin -b $(PRECURSOR_MIRNA_GFF) -wa -wb > $(patsubst %.bam, %_$(basename $(notdir $(PRECURSOR_MIRNA_GFF))).bed,$(DATA_DIR)/$(notdir $(r)));)
#         else
# #if not exist, create an faked gff file
# 	echo "XXNNN	1	2" > $(PRECURSOR_MIRNA_GFF)
#         endif
# 	$(foreach r, $(ALNBAM_GENOME), echo "" >> $(patsubst %.bam, %_$(basename $(notdir $(PRECURSOR_MIRNA_GFF))).bed,$(DATA_DIR)/$(notdir $(r)));)


# select_rrna_bed: intersectbam_rmskgff 
#         ifneq ("$(wildcard $(RMSK_GFF))","")  
# 	@echo "--------------------------------------------" >> $(LOGFILE)
# 	@date >> $(LOGFILE)
# 	@echo "select rRNA annotation from rmsk.ff file ..." >> $(LOGFILE)	
# 	$(foreach r, $(ALNBED_RMSK), $(PERL_PATH)/perl $(SCRIPT_DIR)/selectClassBed.pl -i $(r) -w "rRNA" > $(basename $(r))_rRNA.bed;)
# 	$(PERL_PATH)/perl $(SCRIPT_DIR)/CreateNcRNAgff.pl -i $(RMSK_GFF) -w "rRNA" -d $(ANNOT_DIR) > $(patsubst %, $(PRO_GFF_DIR)/%_rRNA.gff, $(basename $(notdir $(RMSK_GFF))))
#         else
# #if not exist, create an faked gff file
# 	echo "XXNNN	1	2" > $(RMSK_GFF)
#         endif
# 	$(foreach r, $(ALNBED_RMSK), echo ""  >> $(basename $(r))_rRNA.bed;)
# #if not exist, create an faked gff file
# 	echo "XXNNN	.	fake	1	2	.	+	.	ID=fakeitem" >> $(patsubst %, $(PRO_GFF_DIR)/%_rRNA.gff, $(basename $(notdir $(RMSK_GFF))))


# COUNTA=
# read_anno_overview: mapping_stat mapping_stat_distinct intersectbam_rfamgff intersectbam_rmskgff intersectbam_genegff intersectbam_premirgff select_rrna_bed
# 	@echo "--------------------------------------------" >> $(LOGFILE)
# 	@date >> $(LOGFILE)
# 	@echo "count reads in different annotation, draw figures and output table file ..." >> $(LOGFILE)
# 	$(BEDTOOLS_PATH)/multiIntersectBed -i $(ANNO_CATALOG) > $(DATA_DIR)/annotation_multi_intersect.bed
# 	echo "" >> $(DATA_DIR)/annotation_multi_intersect.bed
# 	$(foreach r, $(ANNO_CATALOG), $(eval COUNTA := $(call increment,$(COUNTA)))  $(AWK_PATH)/awk -v idx=$(words $(COUNTA)) '{split($$5,annlist,","); if(annlist[1]==idx){print $$0}}' $(DATA_DIR)/annotation_multi_intersect.bed > $(DATA_DIR)/$(notdir $(basename $(r)))_tmp.bed; echo "" >> $(DATA_DIR)/$(notdir $(basename $(r)))_tmp.bed;)
# 	$(foreach g, $(notdir $(basename $(ALNBAM_GENOME))), $(foreach r, $(notdir $(basename $(ANNO_CATALOG))), $(BEDTOOLS_PATH)/intersectBed -a $(DATA_DIR)/$(g)_$(r).bed -b $(DATA_DIR)/$(r)_tmp.bed -f 1 -wa > $(DATA_DIR)/$(g)_$(r)_exclusive.bed;))
# 	$(foreach g, $(notdir $(basename $(ALNBAM_GENOME))), $(AWK_PATH)/awk -v gname=$(g) 'BEGIN{OFS="\t"; print "idx",gname}' > $(DATA_DIR)/$(g)_abundant_read_anno_overview.data; $(foreach r, $(notdir $(basename $(ANNO_CATALOG))), $(AWK_PATH)/awk -v annoname=$(r) 'BEGIN{OFS="\t";sum=0}{if(!read[$$4$$1$$2]){lrname=split($$4,rname,"_");read_num=rname[lrname];sum+=read_num/$$5}} END{print annoname,sum}' $(DATA_DIR)/$(g)_$(r)_exclusive.bed >> $(DATA_DIR)/$(g)_abundant_read_anno_overview.data;))
# 	$(PERL_PATH)/perl $(SCRIPT_DIR)/combineFiles.pl $(patsubst %, $(DATA_DIR)/%_abundant_read_anno_overview.data, $(notdir $(basename $(ALNBAM_GENOME)))) > $(DOC_DIR)/all_samples_abundant_read_anno_overview.data
# 	$(R_PATH)/R --no-save --no-restore CMD BATCH "--args tabFile='$(DOC_DIR)/all_samples_abundant_read_anno_overview.data'" $(SCRIPT_DIR)/modifyColname.R  $(LOGS_DIR)/modifyColName.Rout
# 	$(R_PATH)/R --no-save --no-restore CMD BATCH "--args annFile='$(DOC_DIR)/all_samples_abundant_read_anno_overview.data' mapFile='$(DOC_DIR)/all_samples_genome_mappingstat.data' picDir='$(PIC_DIR)'" $(SCRIPT_DIR)/plotReadAnnOverview.R  $(LOGS_DIR)/plotReadAnnOverview.Rout


#        ifneq ($(strip $(GROUP_READ)),0)
#	$(foreach g, $(notdir $(basename $(ALNBAM_GENOME))), $(AWK_PATH)/awk -v gname=$(g) 'BEGIN{OFS="\t"; print "idx",gname}' > $(g)_read_mapoverview.data; $(foreach r, $(notdir $(basename $(ANNO_CATALOG))), $(AWK_PATH)/awk -v annoname=$(r) 'BEGIN{OFS="\t"}{if(!read[$$4$$1$$2]){sum+=1/$$5}END{print annoname,sum}' $(DATA_DIR)/$(g)_$(r)_exclusive.bed >> $(g)_distinct_read_anno_overview.data;))
#	$(PERL_PATH)/perl $(SCRIPT_DIR)/combineFiles.pl $(patsubst %, $(DATA_DIR)/%_abundant_read_anno_overview.data, $(notdir $(basename $(ALNBAM_GENOME)))) > $(DOC_DIR)/all_samples_abundant_read_anno_overview.data
#	$(R_PATH)/R --no-save --no-restore CMD BATCH "--args annFile='$(DOC_DIR)/all_samples_distinct_read_anno_overview.data' mapFile='$(DOC_DIR)/all_samples_genome_distinct_mappingstat.data' picDir='$(PIC_DIR)'" $(SCRIPT_DIR)/plotReadAnnOverview.R  $(LOGS_DIR)/plotReadAnnOverview.Rout
#        endif

# annotate_reads:
# 	@echo "--------------------------------------------" >> $(LOGFILE)
# 	@date >> $(LOGFILE)
# 	@echo "count reads in different annotations, draw figures and output table file ..." >> $(LOGFILE)
# 	$(foreach r, $(ALNBAM_GENOME), $(BEDTOOLS_PATH)/bamToBed -i $(r) -tag XX | $(BEDTOOLS_PATH)/annotateBed -i stdin -files $(ANNO_CATALOG) -both > data/annotation_annotateBed_$(notdir $(basename $(r))).bed; $(PERL_PATH)/perl $(SCRIPT_DIR)/annotateReads.pl -i $(DATA_DIR)/annotation_annotateBed_$(notdir $(basename $(r))).bed -x $(notdir $(basename $(r))) -a $(subst $(space),$(comma),$(ANNO_CATALOG)) -s 1 -f 1 > $(DATA_DIR)/$(notdir $(basename $(r)))_annotation_overview.data;)
# 	$(PERL_PATH)/perl $(SCRIPT_DIR)/combineFiles.pl $(patsubst %, $(DATA_DIR)/%_annotation_overview.data, $(notdir $(basename $(ALNBAM_GENOME)))) > $(DOC_DIR)/all_samples_abundant_read_anno_overview.data;
# 	$(R_PATH)/R --no-save --no-restore CMD BATCH "--args tabFile='$(DOC_DIR)/all_samples_abundant_read_anno_overview.data'" $(SCRIPT_DIR)/modifyColname.R  $(LOGS_DIR)/modifyColName.Rout
# 	$(R_PATH)/R --no-save --no-restore CMD BATCH "--args annFile='$(DOC_DIR)/all_samples_abundant_read_anno_overview.data' picDir='$(PIC_DIR)'" $(SCRIPT_DIR)/plotReadAnnOverview.R  $(LOGS_DIR)/plotReadAnnOverview.Rout

COUNTA=
generate_exclusivegff:
	@echo "--------------------------------------------" >> $(LOGFILE)
	@date >> $(LOGFILE)
	@echo "Generate exclusive annotations file for annotation overview ..." >> $(LOGFILE)
	@echo "--------------------------------------------"
	@echo "\\033[0;34m""Overview of read in different annotations""\\033[0;39m"
	
	@$(BEDTOOLS_PATH)/multiIntersectBed -i $(ANNO_CATALOG) > $(DATA_DIR)/annotation_multi_intersect.bed
	@$(foreach r, $(ANNO_CATALOG), $(eval COUNTA := $(call increment,$(COUNTA)))  $(AWK_PATH)/awk -v idx=$(words $(COUNTA)) '{split($$5,annlist,","); if(annlist[1]==idx){print $$0}}' $(DATA_DIR)/annotation_multi_intersect.bed > $(DATA_DIR)/$(notdir $(basename $(r)))_exclusive.bed; echo "" >> $(DATA_DIR)/$(notdir $(basename $(r)))_exclusive.bed;)
	@echo "Generate exclusive annotations file for annotation overview -> done"


intersectbam_glob: $(ALNBAM_GENOME)
	@echo "--------------------------------------------" >> $(LOGFILE)
	@date >> $(LOGFILE)
	@echo "Intersection of mapped data with exclusive annotation files ..." >> $(LOGFILE)
	@$(foreach r, $(ALNBAM_GENOME), $(foreach anno, $(ANNO_CATALOG_EXCLU), $(BEDTOOLS_PATH)/bamToBed -i $(r) -tag XX | $(BEDTOOLS_PATH)/intersectBed -f 1 -a stdin -b $(anno) -wa -wb  > $(patsubst %.bam, %_$(basename $(notdir $(anno))).bed,$(DATA_DIR)/$(notdir $(r)));))
	@echo "Intersection of mapped data with exclusive annotation files -> done"

# intersectbam_glob_old: $(ALNBAM_GENOME)
# 	$(foreach r, $(ALNBAM_GENOME), $(foreach anno, $(ANNO_CATALOG), $(BEDTOOLS_PATH)/bamToBed -i $(r) -tag XX | $(BEDTOOLS_PATH)/intersectBed -f 1 -a stdin -b $(anno) -wa -wb | intersectBed -f 1 -a stdin -b $(DATA_DIR)/$(basename $(notdir $(anno)))_exclusive.bed > $(patsubst %.bam, %_$(basename $(notdir $(anno)))_exclusive.bed,$(DATA_DIR)/$(notdir $(r)));))

read_anno_overview: mapping_stat mapping_stat_distinct
	@echo "--------------------------------------------" >> $(LOGFILE)
	@date >> $(LOGFILE)
	@echo "Count reads in different annotations, draw figures and output table file ..." >> $(LOGFILE)
	@$(foreach g, $(notdir $(basename $(ALNBAM_GENOME))), $(AWK_PATH)/awk -v gname=$(g) 'BEGIN{OFS="\t"; print "idx",gname}' > $(DATA_DIR)/$(g)_abundant_read_anno_overview.data; $(foreach r, $(notdir $(basename $(ANNO_CATALOG))), $(AWK_PATH)/awk -v annoname=$(r) 'BEGIN{OFS="\t";sum=0}{if(!read[$$4$$1$$2]){lrname=split($$4,rname,"_");read_num=rname[lrname];sum+=read_num/$$5;read[$$4$$1$$2]=1}} END{print annoname,sum}' $(DATA_DIR)/$(g)_$(r)_exclusive.bed >> $(DATA_DIR)/$(g)_abundant_read_anno_overview.data;))
	@$(PERL_PATH)/perl $(SCRIPT_DIR)/combineFiles.pl $(patsubst %, $(DATA_DIR)/%_abundant_read_anno_overview.data, $(notdir $(basename $(ALNBAM_GENOME)))) > $(DOC_DIR)/all_samples_abundant_read_anno_overview.data
	@$(R_PATH)/R --no-save --no-restore CMD BATCH "--args tabFile='$(DOC_DIR)/all_samples_abundant_read_anno_overview.data'" $(SCRIPT_DIR)/modifyColname.R  $(LOGS_DIR)/modifyColName.Rout
	@$(R_PATH)/R --no-save --no-restore CMD BATCH "--args annFile='$(DOC_DIR)/all_samples_abundant_read_anno_overview.data' mapFile='$(DOC_DIR)/all_samples_genome_mappingstat.data' picDir='$(PIC_DIR)'" $(SCRIPT_DIR)/plotReadAnnOverview.R  $(LOGS_DIR)/plotReadAnnOverview.Rout
	@echo "Count reads in different annotations, draw figures and output table file -> done"


subfamcov_glob :
        ifneq ($(strip $(ANNO_CATALOG)),)	
	@echo "--------------------------------------------" >> $(LOGFILE)
	@date >> $(LOGFILE)
	@echo "Compute read coverage for each read mapped in a global file ..." >> $(LOGFILE)
	@$(foreach g, $(notdir $(basename $(ALNBAM_GENOME))), $(foreach r, $(ANNO_CATALOG), $(BEDTOOLS_PATH)/intersectBed -a $(DATA_DIR)/$(g)_$(notdir $(basename $(r)))_exclusive.bed -b $(r) -wa -wb > $(DATA_DIR)/$(g)_$(notdir $(basename $(r)))_annot_exclusive.bed;))
	@$(foreach g, $(notdir $(basename $(ALNBAM_GENOME))), $(foreach r, $(notdir $(basename $(ANNO_CATALOG))), $(PYTHON_PATH)/python $(SCRIPT_DIR)/deleteRepetition.py -i $(DATA_DIR)/$(g)_$(notdir $(basename $(r)))_annot_exclusive.bed > $(DATA_DIR)/$(g)_$(r)_exclusive.bed; grep 'chr' $(DATA_DIR)/$(g)_$(notdir $(basename $(r)))_annot_exclusive.bed | tail -1 >> $(DATA_DIR)/$(g)_$(r)_exclusive.bed;))
	@$(foreach g, $(notdir $(basename $(ALNBAM_GENOME))), $(foreach r, $(notdir $(basename $(ANNO_CATALOG))), $(PERL_PATH)/perl $(SCRIPT_DIR)/famReadCov.pl -i $(DATA_DIR)/$(g)_$(r)_exclusive.bed -p "Name|Alias|ID" -x $(SAMPLE_NAME) > $(DATA_DIR)/$(g)_$(r)_global_subfamcov.data;))
	@$(foreach g, $(subst $(comma),$(space),$(SAMPLE_NAME)), $(AWK_PATH)/awk -v gname=$(g) 'BEGIN{OFS="\t"; print "idx",gname}' > $(DATA_DIR)/$(g)_global_all_subfamcov.data;)
	@$(foreach g, $(notdir $(basename $(ALNBAM_GENOME))), $(foreach r, $(notdir $(basename $(ANNO_CATALOG))), $(PYTHON_PATH)/python $(SCRIPT_DIR)/groupFiles.py -i $(DATA_DIR)/$(g)_$(r)_global_subfamcov.data >> $(DATA_DIR)/$(g)_global_all_subfamcov.tmp;))
	@$(foreach g, $(subst $(comma),$(space),$(SAMPLE_NAME)), $(PYTHON_PATH)/python $(SCRIPT_DIR)/subfamcovGroup.py -i $(DATA_DIR)/$(g)_$(ORGANISM)_global_all_subfamcov.tmp >> $(DATA_DIR)/$(g)_global_all_subfamcov.data;)
	@$(PERL_PATH)/perl $(SCRIPT_DIR)/combineFiles.pl $(patsubst %,$(DATA_DIR)/%_global_all_subfamcov.data,$(subst $(comma),$(space),$(SAMPLE_NAME))) > $(DOC_DIR)/all_samples_all_subfamcov.data;
	@$(R_PATH)/R --no-save --no-restore CMD BATCH "--args mapFile='$(DOC_DIR)/all_samples_genome_mappingstat.data' covFile='$(DOC_DIR)/all_samples_all_subfamcov.data'  outFile='$(DOC_DIR)/all_samples_all_subfamcov_RPM.data' Type='subfam'" $(SCRIPT_DIR)/readCovNormalization.R  $(LOGS_DIR)/readCovNormalization.Rout;
	@echo "Compute read coverage for each read mapped in a global file -> done"
	@echo "\\033[0;34m""Overview of read in different annotations -> done""\\033[0;39m"
        endif


######################################
## overview of all ncRNA families in Rfam
######################################

rfam_ncrna_overview: $(ALNBED_RFAM)
	@echo "--------------------------------------------" >> $(LOGFILE)
	@date >> $(LOGFILE)
	@echo "compute read coverage for each ncRNA family, and draw plots, and draw plots..." >> $(LOGFILE)	
# compute the read coverage in different rfam classes (take into count the match number of read, i.e. for each read,the coverage: 1/match_number). Different from repeatmasker mapping, extra-classification of family is needed, which is performed using rfamCov.pl
	@$(foreach r, $(ALNBED_RFAM), $(PERL_PATH)/perl $(SCRIPT_DIR)/famReadCov.pl -i $(r) -p "Alias" -x $(SAMPLE_NAME) > $(DATA_DIR)/$(basename $(notdir $(r)))_famcov_abundant.data.tmp; cat $(DATA_DIR)/$(basename $(notdir $(r)))_famcov_abundant.data.tmp | $(PERL_PATH)/perl $(SCRIPT_DIR)/rfamCov.pl -i stdin -a $(ACA_SNORNA_ITEM) -c $(CD_SNORNA_ITEM) > $(DATA_DIR)/$(basename $(notdir $(r)))_famcov_abundant.data;)
# compute the read coverage in different rfam classes (don't take into count the match number of read, i.e. for each read,the coverage: 1)
#	$(foreach r, $(ALNBED_RFAM), $(PERL_PATH)/perl $(SCRIPT_DIR)/famReadCov.pl -i $(r) -p "Alias" -s 0 -x $(SAMPLE_NAME) > $(DATA_DIR)/$(basename $(notdir $(r)))_famcov_distinct.data.tmp; cat $(DATA_DIR)/$(basename $(notdir $(r)))_famcov_distinct.data.tmp | $(PERL_PATH)/perl $(SCRIPT_DIR)/rfamCov.pl -i stdin -a $(ACA_SNORNA_ITEM) -c $(CD_SNORNA_ITEM) > $(DATA_DIR)/$(basename $(notdir $(r)))_famcov_distinct.data;)
# combine read mapping coverage files
	@$(PERL_PATH)/perl $(SCRIPT_DIR)/combineFiles.pl $(RFAM_FAMCOV_ABUNDANT) > $(DOC_DIR)/all_samples_rfam_famcov_abundant.data
#	$(PERL_PATH)/perl $(SCRIPT_DIR)/combineFiles.pl $(RFAM_FAMCOV_DISTINCT) > $(DOC_DIR)/all_samples_rfam_famcov_distinct.data
# draw plot
	@$(R_PATH)/R --no-save --no-restore CMD BATCH "--args tabFile='$(DOC_DIR)/all_samples_rfam_famcov_abundant.data' figFile='$(PIC_DIR)/plotRfamClassOverviewExp.png' type='ncRNAs(Rfam)'" $(SCRIPT_DIR)/plotAllFamOverview.R $(LOGS_DIR)/plotRfamClassOverviewExp.Rout
	@echo "Compute read coverage for each ncRNA family, and draw plots, and draw plots -> done"


######################################
## overview of repeat classes in repeatmasker
######################################

## overview of all classes in RepeatMasker results
RMSK_TAG_OVERVIEW=Class
###################################################################################################################################################
RMSK_TAG_OVERVIEW_NAME=Name
###################################################################################################################################################
rmsk_class_overview: $(ALNBED_RMSK)
	@echo "--------------------------------------------" >> $(LOGFILE)
	@date >> $(LOGFILE)
	@echo "compute read coverage for each class..." >> $(LOGFILE)
# compute the read coverage in different repeatmasker classes (take into count the match number of read, i.e. for each read,the coverage: 1/match_number)
	@$(foreach r, $(ALNBED_RMSK), $(PERL_PATH)/perl $(SCRIPT_DIR)/famReadCov.pl -i $(r) -p $(RMSK_TAG_OVERVIEW) -s 1  -x $(SAMPLE_NAME) > $(DATA_DIR)/$(basename $(notdir $(r)))_famcov.data; 	$(PERL_PATH)/perl $(SCRIPT_DIR)/famReadCov.pl -i $(r) -p $(RMSK_TAG_OVERVIEW) -x $(SAMPLE_NAME) > $(DATA_DIR)/$(basename $(notdir $(r)))_famcov_abundant.data;)

###################################################################################################################################################
	@$(foreach r, $(ALNBED_RMSK), $(PERL_PATH)/perl $(SCRIPT_DIR)/famReadCov.pl -i $(r) -p $(RMSK_TAG_OVERVIEW_NAME) -s 1  -x $(SAMPLE_NAME) > $(DATA_DIR)/$(basename $(notdir $(r)))_all_famcov.data; 	$(PERL_PATH)/perl $(SCRIPT_DIR)/famReadCov.pl -i $(r) -p $(RMSK_TAG_OVERVIEW_NAME) -x $(SAMPLE_NAME) > $(DATA_DIR)/$(basename $(notdir $(r)))_all_famcov_abundant.data;)
###################################################################################################################################################

# compute the read coverage in different repeatmasker classes (don't take into count the match number of read, i.e. for each read,the coverage: 1)
#	$(foreach r, $(ALNBED_RMSK), echo "$(PERL_PATH)/perl $(SCRIPT_DIR)/famReadCov.pl -i $(r) -p $(RMSK_TAG_OVERVIEW) -s 0  -x $(SAMPLE_NAME) > $(DATA_DIR)/$(basename $(notdir $(r)))_famcov.data"; $(PERL_PATH)/perl $(SCRIPT_DIR)/famReadCov.pl -i $(r) -p $(RMSK_TAG_OVERVIEW) -s 0 -x $(SAMPLE_NAME) > $(DATA_DIR)/$(basename $(notdir $(r)))_famcov_distinct.data;)
# combine read mapping coverage files
	@$(PERL_PATH)/perl $(SCRIPT_DIR)/combineFiles.pl $(RMSK_FAMCOV_ABUNDANT) > $(DOC_DIR)/all_samples_rmsk_famcov_abundant.data
#	$(PERL_PATH)/perl $(SCRIPT_DIR)/combineFiles.pl $(RMSK_FAMCOV_DISTINCT) > $(DOC_DIR)/all_samples_rmsk__famcov_distinct.data
# draw plot
	@$(R_PATH)/R --no-save --no-restore CMD BATCH "--args tabFile='$(DOC_DIR)/all_samples_rmsk_famcov_abundant.data' figFile='$(PIC_DIR)/plotRmsk$(RMSK_TAG_OVERVIEW)OverviewExp.png' type='Repeats(RepeatMasker)'" $(SCRIPT_DIR)/plotAllFamOverview.R $(LOGS_DIR)/plotRmsk$(RMSK_TAG_OVERVIEW)OverviewExp.Rout
	@echo "Compute read coverage for each class and draw plot -> done"
	@echo "\\033[0;34m""Annotation of repeats -> done""\\033[0;39m"


##***********************************
## Visualization - UCSC tracks
##***********************************

######################################
## generate ucsc track files
######################################

## generate ucsc track for each ncrna family
ncrnaTracks: mapping_stat $(ALNBED_NCRNA)
	@echo "--------------------------------------------" >> $(LOGFILE)
	@date >> $(LOGFILE)
	@echo "generate ucsc track for ncrna families..." >> $(LOGFILE)
	@echo "--------------------------------------------" 
	@echo "\\033[0;34m""Generate ucsc track for each ncrna family""\\033[0;39m"
#bedgraph format (height is the proportion of read expression comparing to the total read expression in ncRNA family)
        ifneq ($(strip $(ALNBED_NCRNA)),)
	@$(foreach  r, $(ALNBED_NCRNA), echo "track type=bedGraph name=\""$(basename $(notdir $(r)))"(+)\" description=\""$(basename $(notdir $(r)))"(+)\" visibility=2 color=204,0,0 viewLimits=0:25 autoScale=off" > $(UCSC_DIR)/$(basename $(notdir $(r)))_sens.bedGraph;)
	@$(foreach r, $(ALNBED_NCRNA), $(AWK_PATH)/awk -v samplename=$(basename $(notdir $(r))) 'BEGIN{FS="\t";OFS="\t";print "idx",samplename}{if(!dup[$$4$$1$$2]){lrname=split($$4,rname,"_");read_num=rname[lrname];mapped_num+=read_num/$$5;dup[$$4$$1$$2]=1}}END{print "mapped",mapped_num}' $(r) > $(DATA_DIR)/$(basename $(notdir $(r)))_readcov.tmp;)
	@$(foreach r, $(ALNBED_NCRNA), $(AWK_PATH)/awk 'BEGIN{FS="\t";OFS="\t"}{if(($$6==$$13) && (!dup[$$4$$1$$2])){lrname=split($$4,rname,"_");read_num=rname[lrname];print $$1,$$2,$$3,$$4,read_num/$$5,$$6;dup[$$4$$1$$2]=1}}' $(r) | sort -k 1,1 -k 2,2n -k 3,3n | $(BEDTOOLS_PATH)/groupBy -i stdin -grp 1,2,3 -c 5 -o sum > $(DATA_DIR)/$(basename $(notdir $(r)))_sens.bedtmp;)
	@$(foreach r, $(ALNBED_NCRNA), cat $(DATA_DIR)/$(basename $(notdir $(r)))_sens.bedtmp | $(PERL_PATH)/perl $(SCRIPT_DIR)/calBedgraphCoverage.pl -i stdin >> $(UCSC_DIR)/$(basename $(notdir $(r)))_sens.bedGraph; rm -f $(DATA_DIR)/$(basename $(notdir $(r)))_sens.bedtmp;)
	@$(foreach r, $(ALNBED_NCRNA), $(PERL_PATH)/perl $(SCRIPT_DIR)/trackNormalization.pl -a $(UCSC_DIR)/$(basename $(notdir $(r)))_sens.bedGraph -b $(DATA_DIR)/$(basename $(notdir $(r)))_readcov.tmp -f "bedgraph" -n 100 > $(UCSC_DIR)/$(basename $(notdir $(r)))_perc_sens.bedGraph; rm -f $(UCSC_DIR)/$(basename $(notdir $(r)))_sens.bedGraph;)
	@$(foreach  r, $(ALNBED_NCRNA), echo "track type=bedGraph name=\""$(basename $(notdir $(r)))"(-)\" description=\""$(basename $(notdir $(r)))"(-)\" visibility=2 color=204,0,0 viewLimits=0:25 autoScale=off" > $(UCSC_DIR)/$(basename $(notdir $(r)))_antisens.bedGraph;)
	@$(foreach  r, $(ALNBED_NCRNA), $(AWK_PATH)/awk 'BEGIN{FS="\t";OFS="\t"}{if(($$6!=$$13) && (!dup[$$4$$1$$2])){lrname=split($$4,rname,"_");read_num=rname[lrname];print $$1,$$2,$$3,$$4,read_num/$$5,$$6;dup[$$4$$1$$2]=1}}' $(r) | sort -k 1,1 -k 2,2n -k 3,3n | $(BEDTOOLS_PATH)/groupBy -i stdin -grp 1,2,3 -c 5 -o sum > $(DATA_DIR)/$(basename $(notdir $(r)))_antisens.bedtmp;)
	@$(foreach  r, $(ALNBED_NCRNA), cat $(DATA_DIR)/$(basename $(notdir $(r)))_antisens.bedtmp | $(PERL_PATH)/perl $(SCRIPT_DIR)/calBedgraphCoverage.pl -i stdin >> $(UCSC_DIR)/$(basename $(notdir $(r)))_antisens.bedGraph; rm -f $(DATA_DIR)/$(basename $(notdir $(r)))_antisens.bedtmp;)
	@$(foreach  r, $(ALNBED_NCRNA), $(PERL_PATH)/perl $(SCRIPT_DIR)/trackNormalization.pl -a $(UCSC_DIR)/$(basename $(notdir $(r)))_antisens.bedGraph  -b $(DATA_DIR)/$(basename $(notdir $(r)))_readcov.tmp -f "bedgraph" -n 100 > $(UCSC_DIR)/$(basename $(notdir $(r)))_perc_antisens.bedGraph; rm -f $(UCSC_DIR)/$(basename $(notdir $(r)))_antisens.bedGraph $(DATA_DIR)/$(basename $(notdir $(r)))_readcov.tmp;)
#bed
	@$(foreach  r, $(ALNBED_NCRNA), echo "track type=bed name=\""$(basename $(notdir $(r)))"(+)\" description=\""$(basename $(notdir $(r)))"(+)\"  visibility=4 color=204,0,0" > $(UCSC_DIR)/$(basename $(notdir $(r)))_sense.bed;)
	@$(foreach  r, $(ALNBED_NCRNA), $(AWK_PATH)/awk 'BEGIN{FS="\t";OFS="\t"}{if(($$6==$$13) && (!dup[$$4$$1$$2])){lrname=split($$4,rname,"_");read_num=rname[lrname];print $$1,$$2,$$3,$$4,read_num/$$5,$$6;dup[$$4$$1$$2]=1}}' $(r) | sort -k 1,1 -k 2,2n -k 3,3n  | $(BEDTOOLS_PATH)/groupBy -i stdin -grp 1,2,3,6 -c 5 -o sum > $(DATA_DIR)/$(basename $(notdir $(r)))_sens.bedtmp;)
	@$(foreach  r, $(ALNBED_NCRNA), cat $(DATA_DIR)/$(basename $(notdir $(r)))_sens.bedtmp | $(AWK_PATH)/awk 'BEGIN{OFS="\t"}{print $$1,$$2,$$3,$$5,$$4}' >> $(UCSC_DIR)/$(basename $(notdir $(r)))_sense.bed; rm -f $(DATA_DIR)/$(basename $(notdir $(r)))_sens.bedtmp;)
	@$(foreach  r, $(ALNBED_NCRNA), $(PERL_PATH)/perl $(SCRIPT_DIR)/trackNormalization.pl -a $(UCSC_DIR)/$(basename $(notdir $(r)))_sense.bed -b $(DOC_DIR)/all_samples_genome_mappingstat.data -f "bed" > $(UCSC_DIR)/$(basename $(notdir $(r)))_RPM_sense.bed; rm -f $(UCSC_DIR)/$(basename $(notdir $(r)))_sense.bed;)
	@$(foreach  r, $(ALNBED_NCRNA), echo "track type=bed name=\""$(basename $(notdir $(r)))"(-)\" description=\""$(basename $(notdir $(r)))"(-)\"  visibility=4 color=204,0,0" > $(UCSC_DIR)/$(basename $(notdir $(r)))_antisense.bed;)
	@$(foreach  r, $(ALNBED_NCRNA), $(AWK_PATH)/awk 'BEGIN{FS="\t";OFS="\t"}{if(($$6!=$$13) && (!dup[$$4$$1$$2])){lrname=split($$4,rname,"_");read_num=rname[lrname];print $$1,$$2,$$3,$$4,read_num/$$5,$$6;dup[$$4$$1$$2]=1}}' $(r) | sort -k 1,1 -k 2,2n -k 3,3n  | $(BEDTOOLS_PATH)/groupBy -i stdin -grp 1,2,3,6 -c 5 -o sum > $(DATA_DIR)/$(basename $(notdir $(r)))_antisens.bedtmp;)
	@$(foreach  r, $(ALNBED_NCRNA), cat $(DATA_DIR)/$(basename $(notdir $(r)))_antisens.bedtmp | $(AWK_PATH)/awk 'BEGIN{OFS="\t"}{print $$1,$$2,$$3,$$5,$$4}' >> $(UCSC_DIR)/$(basename $(notdir $(r)))_antisense.bed; rm -f $(DATA_DIR)/$(basename $(notdir $(r)))_antisens.bedtmp;)
	@$(foreach  r, $(ALNBED_NCRNA), $(PERL_PATH)/perl $(SCRIPT_DIR)/trackNormalization.pl -a $(UCSC_DIR)/$(basename $(notdir $(r)))_antisense.bed -b $(DOC_DIR)/all_samples_genome_mappingstat.data -f "bed" > $(UCSC_DIR)/$(basename $(notdir $(r)))_RPM_antisense.bed; rm -f $(UCSC_DIR)/$(basename $(notdir $(r)))_antisense.bed;)
	@gzip -f $(UCSC_DIR)/*.bedGraph
	@gzip -f $(UCSC_DIR)/*.bed
	@echo "\\033[0;34m""Generate ucsc track for each ncrna family -> done""\\033[0;39m"
        endif

## generate ucsc track for genome mapping reads (bedgraph format)
genomeTracks: mapping_stat $(ALNBAM_GENOME)
	@echo "--------------------------------------------" >> $(LOGFILE)
	@date >> $(LOGFILE)
	@echo "generate ucsc track for genome mapping reads based on the options specified in config file..." >> $(LOGFILE)
	@echo "--------------------------------------------"
	@echo "\\033[0;34m""Generate ucsc track for genome mapping reads (bedgraph format)""\\033[0;39m"
        ifneq ($(strip $(GENOME_TRACK_OPTIONS)),) 
	@$(foreach r, $(ALNBAM_GENOME), $(foreach g, $(subst $(slash),$(space),$(subst $(space),,$(GENOME_TRACK_OPTIONS))), echo "track type=bedGraph name=\""$(basename $(notdir $(r)))$(subst =,_,$(subst min,,$(subst max_copy=,_,$(subst max_len=,_,$(subst $(comma),,$(g))))))"(+)\" description=\""$(basename $(notdir $(r)))$(subst =,_,$(subst min,,$(subst max_copy=,_,$(subst max_len=,_,$(subst $(comma),,$(g))))))"(+)\" visibility=2 color=204,0,0 autoScale=on" > $(UCSC_DIR)/$(basename $(notdir $(r)))$(subst =,_,$(subst min,,$(subst max_copy=,_,$(subst max_len=,_,$(subst $(comma),,$(g))))))_plus.bedGraph;))
	@$(foreach r, $(ALNBAM_GENOME), $(foreach g, $(subst $(slash),$(space),$(subst $(space),,$(GENOME_TRACK_OPTIONS))), $(BEDTOOLS_PATH)/bamToBed -i $(r)  -tag XX | $(AWK_PATH)/awk -v strand="+" -v $(subst $(comma),$(space)-v$(space),$(g)) -f $(SCRIPT_DIR)/filterBed.awk | sort -k 1,1 -k 2,2n -k 3,3n | $(BEDTOOLS_PATH)/groupBy -i stdin -grp 1,2,3 -c 5 -o sum | $(PERL_PATH)/perl $(SCRIPT_DIR)/calBedgraphCoverage.pl -i stdin >> $(UCSC_DIR)/$(basename $(notdir $(r)))$(subst =,_,$(subst min,,$(subst max_copy=,_,$(subst max_len=,_,$(subst $(comma),,$(g))))))_plus.bedGraph;))
	@$(foreach r, $(ALNBAM_GENOME), $(foreach g, $(subst $(slash),$(space),$(subst $(space),,$(GENOME_TRACK_OPTIONS))), $(PERL_PATH)/perl $(SCRIPT_DIR)/trackNormalization.pl -a  $(UCSC_DIR)/$(basename $(notdir $(r)))$(subst =,_,$(subst min,,$(subst max_copy=,_,$(subst max_len=,_,$(subst $(comma),,$(g))))))_plus.bedGraph -b $(DOC_DIR)/all_samples_genome_mappingstat.data  -f "bedgraph" > $(UCSC_DIR)/$(basename $(notdir $(r)))$(subst =,_,$(subst min,,$(subst max_copy=,_,$(subst max_len=,_,$(subst $(comma),,$(g))))))_RPM_plus.bedGraph; rm -f $(UCSC_DIR)/$(basename $(notdir $(r)))$(subst =,_,$(subst min,,$(subst max_copy=,_,$(subst max_len=,_,$(subst $(comma),,$(g))))))_plus.bedGraph;))
	@$(foreach r, $(ALNBAM_GENOME), $(foreach g, $(subst $(slash),$(space),$(subst $(space),,$(GENOME_TRACK_OPTIONS))), echo "track type=bedGraph name=\""$(basename $(notdir $(r)))$(subst =,_,$(subst min,,$(subst max_copy=,_,$(subst max_len=,_,$(subst $(comma),,$(g))))))"(-)\" description=\""$(basename $(notdir $(r)))$(subst =,_,$(subst min,,$(subst max_copy=,_,$(subst max_len=,_,$(subst $(comma),,$(g))))))"(-)\" visibility=2 color=204,0,0 autoScale=on" > $(UCSC_DIR)/$(basename $(notdir $(r)))$(subst =,_,$(subst min,,$(subst max_copy=,_,$(subst max_len=,_,$(subst $(comma),,$(g))))))_minus.bedGraph;))
	@$(foreach r, $(ALNBAM_GENOME), $(foreach g, $(subst $(slash),$(space),$(subst $(space),,$(GENOME_TRACK_OPTIONS))), $(BEDTOOLS_PATH)/bamToBed -i $(r)  -tag XX | $(AWK_PATH)/awk -v strand="-" -v $(subst $(comma),$(space)-v$(space),$(g)) -f $(SCRIPT_DIR)/filterBed.awk | sort -k 1,1 -k 2,2n -k 3,3n | $(BEDTOOLS_PATH)/groupBy -i stdin -grp 1,2,3 -c 5 -o sum | $(PERL_PATH)/perl $(SCRIPT_DIR)/calBedgraphCoverage.pl -i stdin  >> $(UCSC_DIR)/$(basename $(notdir $(r)))$(subst =,_,$(subst min,,$(subst max_copy=,_,$(subst max_len=,_,$(subst $(comma),,$(g))))))_minus.bedGraph;))
	@$(foreach r, $(ALNBAM_GENOME), $(foreach g, $(subst $(slash),$(space),$(subst $(space),,$(GENOME_TRACK_OPTIONS))), $(PERL_PATH)/perl $(SCRIPT_DIR)/trackNormalization.pl -a $(UCSC_DIR)/$(basename $(notdir $(r)))$(subst =,_,$(subst min,,$(subst max_copy=,_,$(subst max_len=,_,$(subst $(comma),,$(g))))))_minus.bedGraph -b $(DOC_DIR)/all_samples_genome_mappingstat.data  -f "bedgraph" > $(UCSC_DIR)/$(basename $(notdir $(r)))$(subst =,_,$(subst min,,$(subst max_copy=,_,$(subst max_len=,_,$(subst $(comma),,$(g))))))_RPM_minus.bedGraph; rm -f $(UCSC_DIR)/$(basename $(notdir $(r)))$(subst =,_,$(subst min,,$(subst max_copy=,_,$(subst max_len=,_,$(subst $(comma),,$(g))))))_minus.bedGraph;))
	@gzip -f $(UCSC_DIR)/*.bedGraph
	@echo "\\033[0;34m""Generate ucsc track for genome mapping reads (bedgraph format) -> done""\\033[0;39m"
        endif

######################################
## extract regions not annotated as rfam ncrnas or repeats, but significantly enriched with reads
######################################

## slide window along the genme, and identify significant regions
sig_region_detect: $(ALNBAM_GENOME) $(GENOME_DESC_FILE)
	@echo "--------------------------------------------" >> $(LOGFILE)
	@date >> $(LOGFILE)
	@echo "extract regions (not annotated as rfam ncrnas or repeats, but) significantly enriched with reads" >> $(LOGFILE)
	@echo "--------------------------------------------"
	@echo "\\033[0;34m""Detect significant regions""\\033[0;39m"
        ifneq ($(strip $(EXCLUDE_ANN_GFF)),)
	@cat $(EXCLUDE_ANN_GFF) > $(DATA_DIR)/exclude_ann.gff
        endif
	@echo "" >> $(DATA_DIR)/exclude_ann.gff
	@$(foreach r, $(ALNBAM_GENOME), $(foreach g, $(subst $(slash),$(space),$(subst $(space),,$(SIG_READ_OPTIONS))), $(BEDTOOLS_PATH)/bamToBed -i $(r) -tag XX | $(AWK_PATH)/awk -v $(subst $(comma),$(space)-v$(space),$(g)) -f $(SCRIPT_DIR)/filterBed.awk | $(BEDTOOLS_PATH)/intersectBed -f 1 -a stdin -b $(DATA_DIR)/exclude_ann.gff -v > $(DATA_DIR)/$(basename $(notdir $(r)))$(subst =,_,$(subst min,,$(subst max_copy=,_,$(subst max_len=,_,$(subst $(comma),,$(g)))))).bed.tmp;))  
	@$(foreach r, $(SIG_FILE_PREFIX), cat $(DATA_DIR)/$(r).bed.tmp | $(PERL_PATH)/perl $(SCRIPT_DIR)/setWin.pl -i stdin -w $(SIG_WIN_SIZE) -s $(SIG_STEP_SIZE) -g $(GENOME_DESC_FILE) -o  $(DATA_DIR)/$(r)_w${SIG_WIN_SIZE}_s${SIG_STEP_SIZE};)
	@$(foreach r, $(SIG_FILE_PREFIX), $(R_PATH)/R --no-save --no-restore CMD BATCH "--args prefix='$(r)_w${SIG_WIN_SIZE}_s${SIG_STEP_SIZE}' fitMethod='$(FIT_MODEL)' pCutoff='$(PVAL_CUTOFF)' dataDir='$(DATA_DIR)' docDir='$(DOC_DIR)' picDir='$(PIC_DIR)' readnames='$(SAMPLE_NAME)'"  $(SCRIPT_DIR)/findSigRegion.R  $(LOGS_DIR)/findSigRegion.Rout;)
	@echo "Extract regions (not annotated as rfam ncrnas or repeats, but) significantly enriched with reads -> done"

## add gene/repeat. information to significant regions, and merge overlapped regions in all samples
sig_region_ann: 
	@echo "--------------------------------------------" >> $(LOGFILE)
	@date >> $(LOGFILE)
	@echo "add other information to significant regions" >> $(LOGFILE)
        ifneq ($(strip $(SIG_REGION_ANN)),)
	@$(foreach r, $(SIG_REGION_ANN), $(foreach g, $(SIG_FILE_PREFIX), cat $(DATA_DIR)/$(g).bed.tmp | $(BEDTOOLS_PATH)/intersectBed -f 1 -a stdin -b $(r) -wa -wb | $(PERL_PATH)/perl $(SCRIPT_DIR)/addSigRegAnnInfo.pl -i stdin -w $(SIG_WIN_SIZE) -s $(SIG_STEP_SIZE) -a $(notdir $(basename $(r))) -f $(DOC_DIR)/$(g)_w$(SIG_WIN_SIZE)_s$(SIG_STEP_SIZE)_sigReg.data > $(DATA_DIR)/$(g)_w$(SIG_WIN_SIZE)_s$(SIG_STEP_SIZE)_sigReg.data.tmp; mv $(DATA_DIR)/$(g)_w$(SIG_WIN_SIZE)_s$(SIG_STEP_SIZE)_sigReg.data.tmp $(DOC_DIR)/$(g)_w$(SIG_WIN_SIZE)_s$(SIG_STEP_SIZE)_sigReg.data;))
        endif
	@$(foreach filter_item, $(subst $(slash),$(space),$(subst $(space),,$(SIG_READ_OPTIONS))), cat $(patsubst %,$(DOC_DIR)/%$(subst =,_,$(subst min,,$(subst max_copy=,_,$(subst max_len=,_,$(subst $(comma),,$(filter_item))))))_w$(SIG_WIN_SIZE)_s$(SIG_STEP_SIZE)_sigReg.data,$(basename $(notdir $(ALNBAM_GENOME)))) | sort -k 1,1 -k 2,2n | $(AWK_PATH)/awk 'BEGIN{OFS="\t";pre_chr="";pre_ln=0;pre_rn=0;}{if($$1!="chr"){ if(pre_chr && pre_chr==$$1 && $$2>=pre_ln && $$2<=pre_rn){if($$3>pre_rn){pre_rn=$$3} lib=lib$$14"_"$$4"; "} else{if(pre_chr){print pre_chr,pre_ln,pre_rn,lib} pre_chr=$$1; pre_ln=$$2; pre_rn=$$3; lib=$$14"_"$$4"; "}}} END{if(pre_chr){print pre_chr,pre_ln,pre_rn,lib}}' > $(DOC_DIR)/mergedSigregion$(subst =,_,$(subst min,,$(subst max_copy=,_,$(subst max_len=,_,$(subst $(comma),,$(filter_item))))))_all_sample.data;)
	@echo "Add other information to significant regions -> done" 
	@echo "\\033[0;34m""Detect significant regions -> done""\\033[0;39m"

sig_region_track: 
        ifneq ($(SIG_READ_OPTIONS),)
	@echo "--------------------------------------------" >> $(LOGFILE)
	@date >> $(LOGFILE)
	@echo "generate ucsc track for filtered reads mapped in significant region" >> $(LOGFILE)
	@$(foreach filter_item, $(subst $(slash),$(space),$(subst $(space),,$(SIG_READ_OPTIONS))), $(foreach g, $(basename $(notdir $(ALNBAM_GENOME))), echo "track type=bed name=\""$(g)$(subst =,_,$(subst min,,$(subst max_copy=,_,$(subst max_len=,_,$(subst $(comma),,$(filter_item))))))_w$(SIG_WIN_SIZE)_s$(SIG_STEP_SIZE)"_sigRegion (+)\" description=\""$(g)$(subst =,_,$(subst min,,$(subst max_copy=,_,$(subst max_len=,_,$(subst $(comma),,$(filter_item))))))_w$(SIG_WIN_SIZE)_s$(SIG_STEP_SIZE)"_window_"$(SIG_WIN_SIZE)"_step_"$(SIG_STEP_SIZE)"_sigRegion (+)\" visibility=4 color=204,0,0" > $(UCSC_DIR)/$(g)$(subst =,_,$(subst min,,$(subst max_copy=,_,$(subst max_len=,_,$(subst $(comma),,$(filter_item))))))_w$(SIG_WIN_SIZE)_s$(SIG_STEP_SIZE)_sigRegion_plus.bed;))
	@$(foreach filter_item, $(subst $(slash),$(space),$(subst $(space),,$(SIG_READ_OPTIONS))), $(foreach g, $(basename $(notdir $(ALNBAM_GENOME))), $(BEDTOOLS_PATH)/intersectBed -f 1 -a $(DATA_DIR)/$(g)$(subst =,_,$(subst min,,$(subst max_copy=,_,$(subst max_len=,_,$(subst $(comma),,$(filter_item)))))).bed.tmp -b $(DOC_DIR)/mergedSigregion$(subst =,_,$(subst min,,$(subst max_copy=,_,$(subst max_len=,_,$(subst $(comma),,$(filter_item))))))_all_sample.data -wa | $(AWK_PATH)/awk 'BEGIN{FS="\t";OFS="\t"}{if(($$6=="+") && (!dup[$$4$$1$$2$$6])){print $$1,$$2,$$3,$$4,$$5,$$6;dup[$$4$$1$$2$$6]=1}}' | sort -k 1,1 -k 2,2n -k 3,3n | $(BEDTOOLS_PATH)/groupBy -i stdin -grp 1,2,3,6 -c 5 -o sum | $(AWK_PATH)/awk 'BEGIN{OFS="\t"}{print $$1,$$2,$$3,$$5,$$4}'>> $(UCSC_DIR)/$(g)$(subst =,_,$(subst min,,$(subst max_copy=,_,$(subst max_len=,_,$(subst $(comma),,$(filter_item))))))_w$(SIG_WIN_SIZE)_s$(SIG_STEP_SIZE)_sigRegion_plus.bed;))
	@$(foreach filter_item, $(subst $(slash),$(space),$(subst $(space),,$(SIG_READ_OPTIONS))), $(foreach g, $(basename $(notdir $(ALNBAM_GENOME))), $(PERL_PATH)/perl $(SCRIPT_DIR)/trackNormalization.pl -a $(UCSC_DIR)/$(g)$(subst =,_,$(subst min,,$(subst max_copy=,_,$(subst max_len=,_,$(subst $(comma),,$(filter_item))))))_w$(SIG_WIN_SIZE)_s$(SIG_STEP_SIZE)_sigRegion_plus.bed -b $(DOC_DIR)/all_samples_genome_mappingstat.data -f "bed" > $(UCSC_DIR)/$(g)$(subst =,_,$(subst min,,$(subst max_copy=,_,$(subst max_len=,_,$(subst $(comma),,$(filter_item))))))_w$(SIG_WIN_SIZE)_s$(SIG_STEP_SIZE)_RPM_sigRegion_plus.bed;))
	@$(foreach filter_item, $(subst $(slash),$(space),$(subst $(space),,$(SIG_READ_OPTIONS))), $(foreach g, $(basename $(notdir $(ALNBAM_GENOME))), rm -f $(UCSC_DIR)/$(g)$(subst =,_,$(subst min,,$(subst max_copy=,_,$(subst max_len=,_,$(subst $(comma),,$(filter_item))))))_w$(SIG_WIN_SIZE)_s$(SIG_STEP_SIZE)_sigRegion_plus.bed;))
	@$(foreach filter_item, $(subst $(slash),$(space),$(subst $(space),,$(SIG_READ_OPTIONS))), $(foreach g, $(basename $(notdir $(ALNBAM_GENOME))), echo "track type=bed name=\""$(g)$(subst =,_,$(subst min,,$(subst max_copy=,_,$(subst max_len=,_,$(subst $(comma),,$(filter_item))))))_w$(SIG_WIN_SIZE)_s$(SIG_STEP_SIZE)"_sigRegion (-)\" description=\""$(g)$(subst =,_,$(subst min,,$(subst max_copy=,_,$(subst max_len=,_,$(subst $(comma),,$(filter_item))))))_w$(SIG_WIN_SIZE)_s$(SIG_STEP_SIZE)"_window_"$(SIG_WIN_SIZE)"_step_"$(SIG_STEP_SIZE)"_sigRegion (-)\" visibility=4 color=204,0,0" > $(UCSC_DIR)/$(g)$(subst =,_,$(subst min,,$(subst max_copy=,_,$(subst max_len=,_,$(subst $(comma),,$(filter_item))))))_w$(SIG_WIN_SIZE)_s$(SIG_STEP_SIZE)_sigRegion_minus.bed;))
	@$(foreach filter_item, $(subst $(slash),$(space),$(subst $(space),,$(SIG_READ_OPTIONS))), $(foreach g, $(basename $(notdir $(ALNBAM_GENOME))), $(BEDTOOLS_PATH)/intersectBed -f 1 -a $(DATA_DIR)/$(g)$(subst =,_,$(subst min,,$(subst max_copy=,_,$(subst max_len=,_,$(subst $(comma),,$(filter_item)))))).bed.tmp -b $(DOC_DIR)/mergedSigregion$(subst =,_,$(subst min,,$(subst max_copy=,_,$(subst max_len=,_,$(subst $(comma),,$(filter_item))))))_all_sample.data -wa | $(AWK_PATH)/awk 'BEGIN{FS="\t";OFS="\t"}{if(($$6=="-") && (!dup[$$4$$1$$2$$6])){print $$1,$$2,$$3,$$4,$$5,$$6;dup[$$4$$1$$2$$6]=1}}' | sort -k 1,1 -k 2,2n -k 3,3n | $(BEDTOOLS_PATH)/groupBy -i stdin -grp 1,2,3,6 -c 5 -o sum | $(AWK_PATH)/awk 'BEGIN{OFS="\t"}{print $$1,$$2,$$3,$$5,$$4}'>> $(UCSC_DIR)/$(g)$(subst =,_,$(subst min,,$(subst max_copy=,_,$(subst max_len=,_,$(subst $(comma),,$(filter_item))))))_w$(SIG_WIN_SIZE)_s$(SIG_STEP_SIZE)_sigRegion_minus.bed;))
	@$(foreach filter_item, $(subst $(slash),$(space),$(subst $(space),,$(SIG_READ_OPTIONS))), $(foreach g, $(basename $(notdir $(ALNBAM_GENOME))), $(PERL_PATH)/perl $(SCRIPT_DIR)/trackNormalization.pl -a $(UCSC_DIR)/$(g)$(subst =,_,$(subst min,,$(subst max_copy=,_,$(subst max_len=,_,$(subst $(comma),,$(filter_item))))))_w$(SIG_WIN_SIZE)_s$(SIG_STEP_SIZE)_sigRegion_minus.bed -b $(DOC_DIR)/all_samples_genome_mappingstat.data -f "bed" > $(UCSC_DIR)/$(g)$(subst =,_,$(subst min,,$(subst max_copy=,_,$(subst max_len=,_,$(subst $(comma),,$(filter_item))))))_w$(SIG_WIN_SIZE)_s$(SIG_STEP_SIZE)_RPM_sigRegion_minus.bed;))
	@$(foreach filter_item, $(subst $(slash),$(space),$(subst $(space),,$(SIG_READ_OPTIONS))), $(foreach g, $(basename $(notdir $(ALNBAM_GENOME))), rm -f $(UCSC_DIR)/$(g)$(subst =,_,$(subst min,,$(subst max_copy=,_,$(subst max_len=,_,$(subst $(comma),,$(filter_item))))))_w$(SIG_WIN_SIZE)_s$(SIG_STEP_SIZE)_sigRegion_minus.bed;))
	@gzip -f $(UCSC_DIR)/*.bed
        endif

######################################
## HTML outputs
######################################
html_builder:
	@echo "--------------------------------------------" >> $(LOGFILE)
	@date >> $(LOGFILE)
	@echo "Building HTML report" >> $(LOGFILE)
	@echo $(ALL_NCRNA) | $(PERL_PATH)/perl -pe 's/\s+/\n/g' > $(DATA_DIR)/ncrna_processed.txt
	@echo "--------------------------------------------"
	@echo "\\033[0;34m""Building HTML report" "\\033[0;39m"
	@$(foreach picfile, $(wildcard $(PIC_DIR)/*_all_LOGO.png), convert -thumbnail x200 $(picfile) $(patsubst %, $(HTML_DIR)/thumb/%, $(notdir $(picfile)));)
	@$(foreach picfile, $(wildcard $(PIC_DIR)/*_unique_LOGO.png), convert -thumbnail x200 $(picfile) $(patsubst %, $(HTML_DIR)/thumb/%, $(notdir $(picfile)));)
	@$(foreach picfile, $(wildcard $(PIC_DIR)/*_abundant.png), convert -thumbnail x200 $(picfile) $(patsubst %, $(HTML_DIR)/thumb/%, $(notdir $(picfile)));)
	@$(foreach picfile, $(wildcard $(PIC_DIR)/*_distinct.png), convert -thumbnail x200 $(picfile) $(patsubst %, $(HTML_DIR)/thumb/%, $(notdir $(picfile)));)
	@$(foreach picfile, $(wildcard $(PIC_DIR)/*_plotReadModelFit.png), convert -thumbnail x200 $(picfile) $(patsubst %, $(HTML_DIR)/thumb/%, $(notdir $(picfile)));)
	@$(foreach picfile, $(wildcard $(PIC_DIR)/plot*.png), convert -thumbnail x200 $(picfile) $(patsubst %, $(HTML_DIR)/thumb/%, $(notdir $(picfile)));)
#	$(foreach picfile, $(wildcard $(PIC_DIR)/*), $(CONVERT_PATH)/convert -thumbnail x200 $(picfile) $(patsubst %, $(HTML_DIR)/thumb/%, $(notdir $(picfile)));)
	@$(PERL_PATH)/perl $(SCRIPT_DIR)/buildHTML.pl -n $(DATA_DIR)/ncrna_processed.txt -l $(LOGFILE) -c $(CONFIG_FILE) > report.html
	@echo "\\033[0;34m""Building HTML report -> done""\\033[0;39m"


######################################
## PDF outputs
######################################

pdf_builder:
	@echo "--------------------------------------------" >> $(LOGFILE)
	@date >> $(LOGFILE)
	@echo "Building PDF report" >> $(LOGFILE)
	@echo "--------------------------------------------"
	@echo "\\033[0;34m""Building PDF report" "\\033[0;39m"
	@$(PYTHON_PATH)/python $(SCRIPT_DIR)/createPdf.py -org $(ORGANISM) -n $(PROJECT_NAME) -s $(SAMPLE_NAME) -nfile $(READSFILES) -fqFormat $(FASTQ_FORMAT) -genBowtie $(BOWTIE_GENOME_REFERENCE) -optBowtieCS "$(BOWTIE_GENOME_OPTIONS_CS)" -optBowtieFA "$(BOWTIE_GENOME_OPTIONS_FA)" -optBowtieFQ "$(BOWTIE_GENOME_OPTIONS_FQ)" -annotFiles $(ANNO_CATALOG) -annotDirect $(ANNOT_DIR) -pdfDirect $(PDF_DIR) -picDirect $(PIC_DIR)
	@echo "\\033[0;34m""Building PDF report -> done""\\033[0;39m"

## Remove temporary files
clean:
	@echo "--------------------------------------------"
	@echo "\\033[0;34m""Remove temporary files" "\\033[0;39m"
	@rm -f $(DATA_DIR)/*
	@rm -f *.Rout
	@rm -f *.RData
	@echo "\\033[0;34m""Remove temporary files -> done" "\\033[0;39m"

## Remove all results files
reset: clean
	@echo "--------------------------------------------"
	@echo "\\033[0;34m""Remove results files" "\\033[0;39m"
	@rm -f $(LOGFILE)
	@rm -f $(LOGS_DIR)/*
	@rm -rf $(BOWTIE_RESULTS_DIR)/*
	@rm -f $(DATA_DIR)/*
	@rm -f $(RAW_DIR)/*.pmod
	@rm -f $(DOC_DIR)/*
	@rm -f $(PIC_DIR)/*
	@rm -f $(HTML_DIR)/index.html
	@rm -f $(HTML_DIR)/thumb/*
	@rm -f $(UCSC_DIR)/*
	@rm -f $(PRO_GFF_DIR)/*
	@rm -f *.html
	@rm -f *.pdf
	@echo "\\033[0;34m""Remove results files -> done" "\\033[0;39m"

clean_sam:

	@echo "--------------------------------------------"
	@echo "\\033[0;34m""Remove sam files" "\\033[0;39m"
	@rm -rf $(BOWTIE_RESULTS_DIR)/*.sam
	@rm -f $(DATA_DIR)/*.tmp
	@echo "\\033[0;34m""Remove sam files -> done" "\\033[0;39m"
	@echo "--------------------------------------------"
	@date

### which of the preceding rules are not meant to be files
.PHONY: all list clean reset html_builder

### which Suffixes are we working with:
.SUFFIXES: .fastq .fasta .csfasta .bam .log





