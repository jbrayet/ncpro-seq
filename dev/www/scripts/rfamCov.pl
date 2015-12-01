###!/usr/bin/perl -w

# Copyleft ↄ⃝ 2012 Institut Curie
# Author(s): Jocelyn Brayet, Laurene Syx, Chongjian Chen, Nicolas Servant(Institut Curie) 2012 - 2015
# Contact: bioinfo.ncproseq@curie.fr
# This software is distributed without any guarantee under the terms of the GNU General
# Public License, either Version 2, June 1991 or Version 3, June 2007.

#The script is used to sum up read coverage belonging to the same rfam super-families. The families in rfam is classified as "ACA snoRNA","CD snoRNA","snRNA","rRNA","microRNA","tRNA" and "others".

use Getopt::Std;
use strict;

## get options from command line
my %opts= ('i'=>'','a'=>'annotation/ACA_snoRNA.item','c'=>'annotation/CD_snoRNA.item');

sub usage{
print STDERR <<EOF;
    usage:  $0 -i STDIN [-a aca_annot -c cd_annot -h]

     -h   : help message;
     -i   : input read coverage string;
     -a   : aca snoRNA annotation file, default is "annotation/ACA_snoRNA.item";
     -c   : cd snoRNA annotation file, default is "annotation/CD_snoRNA.item";

    example1: $0 -i STDIN -a annotation/ACA_snoRNA.item -b annotation/CD_snoRNA.item

EOF
    exit;
}

getopts('i:a:c:h', \%opts) || usage();
usage() if ($opts{h});

my ($str,$aca_file,$cd_file)=($opts{i},$opts{a},$opts{c});

## get aca and cd snoRNA names in rfam, respectively
my $cd_names=snoRNA_names($cd_file);
my $aca_names=snoRNA_names($aca_file);

my ($mir_cov,$trna_cov,$cd_cov,$aca_cov,$snrna_cov,$rrna_cov,$others)=(0,0,0,0,0,0,0);

## classify ncrna rna, and sum up read coverage in the same super-family
while(<$str>){
    if(/^idx/){
	print $_;
	next;
}
    if(/^(mir|lin-4|let-7|lsy-6|bantam).*?\s(\S+)/i){
	$mir_cov+=$2;
	next;
}
    if(/rRNA.*?\s(\S+)/i){
	$rrna_cov+=$1;
	next;
}
    if(/tRNA.*?\s(\S+)/i){
	$trna_cov+=$1;
	next;
}
    if(/($cd_names)\s+(\S+)/i){
	$cd_cov+=$2;
	next;
}
    if(/($aca_names)\s+(\S+)/i){
	$aca_cov+=$2;
	next;
}
    if(/(U1|U2|U4|U5|U6|U11|U12|SmY).*?\s(\S+)/i){
	$snrna_cov+=$2;
	next;
}
    if(/^\S+\s+(\S+)/){
	$others+=$1;
}
}

## output accumulated read coverage for each super-family
print "microRNA\t",$mir_cov,"\n";
print "tRNA\t",$trna_cov,"\n";
print "CD_snoRNA\t",$cd_cov,"\n";
print "ACA_snoRNA\t",$aca_cov,"\n";
print "rRNA\t",$rrna_cov,"\n";
print "snRNA\t",$snrna_cov,"\n";
print "others\t",$others,"\n";

#get snoRNA names 
sub snoRNA_names{
    my ($sno_ann)=@_;
    open (SNO,"$sno_ann") || warn "can't open $sno_ann";
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
