###!/usr/bin/perl -w

# Copyleft ↄ⃝ 2012 Institut Curie
# Author(s): Jocelyn Brayet, Laurene Syx, Chongjian Chen, Nicolas Servant(Institut Curie) 2012 - 2015
# Contact: bioinfo.ncproseq@curie.fr
# This software is distributed without any guarantee under the terms of the GNU General
# Public License, either Version 2, June 1991 or Version 3, June 2007.

## Count annotations from output of annotateBed tool (BEDTools)
## Optimized version :
## - Sum up annotation score on the fly
## - Remove -m option (not use for ncPRO

use Getopt::Std;
use strict;
use List::Util qw( sum );

## get options from command line
my %opts= ('i'=>'','x'=>'','p'=>'','s'=>0,'f'=>1);

sub usage{
print STDERR <<EOF;
    usage:  $0 -i bed_file -a annotation_names -p pattern -s 0|1 -x samplefiles [-h]

     -h   : help message;
     -i   : input bed file from annotateBed
     -a   : names of annotations processed (coma delimited)
     -x   : sample name
     -s   : use value in score column in bed file to compute the coverage (1/value), 1 (yes)or 0 (no), default is 0
     -f   : count full covered reads, 1 (yes) or 0 (no), default is 1

    example1: $0 -i file -a annotA,annotB -x sample_name -s 0

EOF
    exit;
}

getopts('i:a:x:s:f:h', \%opts) || usage();
usage() if ($opts{h});
my $VERBOSE=0;

my ($bed_file,$annot_list,$sample,$use_sc,$use_multi_annot,$use_fullcov)=($opts{i},$opts{a},$opts{x},$opts{s},$opts{m},$opts{f});

## Get annot name if speicifed
my @annot_name;
if ($annot_list){
    @annot_name=split(',',$annot_list);
    push @annot_name, "unknown";
}

my @annot_count;
my $nbannot;
my @line;

open (BED,"$bed_file") || die "can't open $bed_file";
while(<BED>){
    next if (/^#/);
    @line=split(' ');
    
    ##Initialize at first line
    if ($. == 1){
	my $size=scalar @line;
	$nbannot=($size-6)/2;
    }
    
    if (!/^#/){
	my($chr, $start, $end, $read_name, $cov, $strand)=($line[0], $line[1], $line[2], $line[3], $line[4], $line[5]);
	my ($read_shortname, $read_num) = $read_name =~ (/^(.*?)\_?([^\_]*)$/);
	my $is_annotated=0;
	
	##Use Annotation order information
	my $is_find=0;
	for(my $i=0;$i<$nbannot;$i++){
	    if ($line[$i+($i+6)] !=0 && $is_find==0){
		$is_find=1;
	    }elsif($line[$i+($i+6)] !=0 && $is_find==1){
		$line[$i+($i+6)]=0;
		$line[$i+($i+6)+1]=0;
	    }
	}
	##Score
	$cov=1/$cov;
	$cov=1 if (!$use_sc); 
	$cov*=$read_num;
	
	##Go through all the annotations
	for(my $i=0;$i<$nbannot;$i++){
	    ## Reads annotated
	    if ($line[$i+($i+6)]!=0){
		## Keep reads which fully overlap with annotations
		if (($use_fullcov && $line[$i+($i+6)+1] == 1) || !$use_fullcov){
		    $is_annotated=1;
		    $annot_count[$i]+=$cov;
		}
	    }
	}
	
	if ($is_annotated==0){
	    $annot_count[$nbannot]+=$cov;
	}
    }
}
close BED;

if ($#annot_name != ($nbannot)){
    warn("Number of annotations different from number of name provided (-a)");
}

if ($sample){
    print "idx\t$sample\n";
}
my $sum=0;
for (my $i=0; $i<=$nbannot;$i++){
    $sum+=$annot_count[$i];
    printf ("%s\t%.2f\n",$annot_name[$i], $annot_count[$i]);
}
printf ("mapped_reads\t%.2f",$sum);
