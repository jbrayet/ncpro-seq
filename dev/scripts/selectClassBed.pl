###!/usr/bin/perl -w

# Copyleft ↄ⃝ 2012 Institut Curie
# Author(s): Jocelyn Brayet, Laurene Syx, Chongjian Chen, Nicolas Servant(Institut Curie) 2012 - 2015
# Contact: bioinfo.ncproseq@curie.fr
# This software is distributed without any guarantee under the terms of the GNU General
# Public License, either Version 2, June 1991 or Version 3, June 2007.

#The script is used to match class keyword to bed file (result file from intersectBed -wa -wb) to generate class-specific read-mapping bed file

use Getopt::Std;
use strict;

## get options from command line
my %opts= ('i'=>'','d'=>'','w'=>'');

sub usage{
print STDERR <<EOF;
    usage:  $0 -i bed_file -w item -d annotDir [-h]

     -h   : help message;
     -i   : input bed file;
     -w   : the item used to match
     -d   : the directory which stores snoRNA annotation files;

    example1: $0 -i file -w "tRNA" -d annotation

EOF
    exit;
}

getopts('i:d:w:h', \%opts) || usage();
usage() if ($opts{h});

my ($ori_bed,$keyword,$annot_dir)=($opts{i},$opts{w},$opts{d});

#get exact snoRNA keywords
if($keyword=~/snoRNA/){    
    $keyword=snoRNA_keyword($keyword);
}

open (BED,"$ori_bed") ||  warn "can't open bed $ori_bed"; 
while(<BED>){
#    if(/\s+\d+\s+\d+\s+.*\s+\d+\s+\d+\s+.*\=\"?($keyword)(?:(?!\d+)).*/){
    if(/\s+\d+\s+\d+\s+.*\s+\d+\s+\d+\s+.*\=\"?($keyword)\"?;.*/i){
	print $_;
}
}
close(BED);

#assign all snoRNA names in Rfam as keyword
sub snoRNA_keyword{
    my ($type)=@_;
    open (SNO,"$annot_dir/$type.item") || warn "can't open $annot_dir/$type.item"; 
    my $sno_name="";
    while(<SNO>){
	next if (/\#/);
	if(/^\S+\s+(\S+)/){
	    $sno_name.=$1 . "|";
}
}
    chop($sno_name);
    close(SNO);
    return ($sno_name);
}
