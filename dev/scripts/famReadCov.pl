###!/usr/bin/perl -w

# Copyleft ↄ⃝ 2012 Institut Curie
# Author(s): Jocelyn Brayet, Laurene Syx, Chongjian Chen, Nicolas Servant(Institut Curie) 2012 - 2015
# Contact: bioinfo.ncproseq@curie.fr
# This software is distributed without any guarantee under the terms of the GNU General
# Public License, either Version 2, June 1991 or Version 3, June 2007.

#The script is used to calculate the read coverage given file which is produced by intersectBed with parameters -wa -wb -bed.

use Getopt::Std;
use strict;

## get options from command line
my %opts= ('i'=>'','p'=>'','s'=>1,'x'=>'');

sub usage{
print STDERR <<EOF;
    usage:  $0 -i bed_file -p pattern -s 0|1 -x samplefiles [-h]

     -h   : help message;
     -i   : input bed file from intersectBed with parameter -wa -wb -bed;
     -p   : the tag in the attributes columns you want to index;
     -s   : use value in score column in bed file to compute the coverage (1/value), 1 (yes)or 0 (no), default is 1;
     -x   : names of all read sample files;
    example1: $0 -i file -p "Name" -s 1 -x g1,g2,g3

EOF
    exit;
}

getopts('i:p:s:x:h', \%opts) || usage();
usage() if ($opts{h});

my ($bed_file,$pattern,$use_sc,$samplefiles)=($opts{i},$opts{p},$opts{s},$opts{x});

open (BED,"$bed_file") || warn "can't open $bed_file";


my %fam_cov;
while(<BED>){
    if(/^\S+\s+(\d+)\s+\d+\s+(\S+\_(\d+))\s+(\d+)\s+([+-]).*($pattern)\=(\S+)/){
	my ($gln,$read_name,$read_num,$cov,$strand,$anno)=($1,$2,$3,$4,$6,$7);
	my @field=split(/\;/,$anno);
	my $fam=$field[0]; ##get the family name indicated by $pattern
	$fam=~s/\"//g;
	$cov=1/$cov;
	$cov=1 if (!$use_sc); ## each read counts 1 if not consider the number of read copies in the genome, i.e. -s 0
	$cov*=$read_num;
	$fam_cov{$fam}+=$cov;
}
}
close(BED);

## get sample name
my $sample="";
my @sample_arr=split(/,/,$samplefiles);
foreach my $i (0..$#sample_arr){
    my $cur_sample=$sample_arr[$i];
    if($bed_file=~/\/$cur_sample\_/){
	$sample=$cur_sample;
	last;
}
}


## output
print "idx\t$sample\n";
foreach my $fam (sort keys %fam_cov){
    print "$fam\t",$fam_cov{$fam},"\n";
}

