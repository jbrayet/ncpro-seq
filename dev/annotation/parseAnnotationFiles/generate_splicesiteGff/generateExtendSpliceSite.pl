#!/usr/bin/perl -w
#created by Chongjian CHEN- 9/11/2011

#The script is used to easily generate a extended gff3 files for splice sites.

use Getopt::Std;
use strict;
use File::Basename;

## get options from command line
my %opts= ('i'=>'','e'=>'');

sub usage{
print STDERR <<EOF;
    usage:  $0 -i gene_all_info_file -e 100 [-h]

     -h   : help message;
     -i   : the refgene file containing all information;
     -e   : the key word to uniquely represent the species;

EOF
    exit;
}

getopts('i:e:h', \%opts) || usage();
usage() if ($opts{h});

my ($gene_file,$extend)=($opts{i},$opts{e});

my $gene_fileName=basename($gene_file,".txt");

open(DONOR,">gene_donor.gff");
open(ACCEPTOR,">gene_acceptor.gff");
open(IN,"$gene_file") || die;
while(<IN>){
    next if (/^\#/);
    if(/^\d+\s+(\S+)\s+(\S+)\s+([+-])\s+\d+\s+\d+\s+\d+\s+\d+\s+\d+\s+(\S+)\s+(\S+)/){
	my ($gname,$chrm,$strand,$linfo,$rinfo)=($1,$2,$3,$4,$5);
#	warn $_;
	my @larr=split(/\,/,$linfo);
	my @rarr=split(/\,/,$rinfo);
	next if ($#larr<=0);
	my ($lskip,$rskip)=(0,$#larr);
	foreach my $id (0..$#larr){
	    $larr[$id]++;
}
	if($strand eq "-"){
	    my @tmp=@larr;
	    @larr=@rarr;
	    @rarr=@tmp;
#	    (@rarr,@larr)=(@larr,@rarr);
	    ($lskip,$rskip)=($rskip,$lskip);
}
	foreach my $i (0..$#larr){
	    next if ($i==$lskip);
	    print ACCEPTOR $chrm,"\trefgene\tsplice_site\t",$larr[$i]-$extend,"\t",$larr[$i]+$extend,"\t.\t",$strand,"\t.\tGeneName\=",$gname,";Exon_idx=";
	    if($strand eq "+"){
		print ACCEPTOR $i+1,";Type=acceptor;Extend_base=$extend;\n";
}
	    else{
		print ACCEPTOR $#larr+1-$i,";Type=acceptor;Extend_base=$extend;\n";
}
}
	foreach my $i (0..$#rarr){
	    next if ($i==$rskip);
	    print DONOR $chrm,"\trefgene\tsplice_site\t",$rarr[$i]-$extend,"\t",$rarr[$i]+$extend,"\t.\t",$strand,"\t.\tGeneName\=",$gname,";Exon_idx=";
	    if($strand eq "+"){
		print DONOR $i+1,";Type=donor;Extend_base=$extend;\n";
}
	    else{
		print DONOR $#rarr-$i+1,";Type=donor;Extend_base=$extend;\n";
}
}
}
}
close(IN);
close(DONOR);
close(ACCEPTOR);
