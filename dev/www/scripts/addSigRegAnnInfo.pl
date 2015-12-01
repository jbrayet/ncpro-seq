###!/usr/bin/perl -w

# Copyleft ↄ⃝ 2012 Institut Curie
# Author(s): Jocelyn Brayet, Laurene Syx, Chongjian Chen, Nicolas Servant(Institut Curie) 2012 - 2015
# Contact: bioinfo.ncproseq@curie.fr
# This software is distributed without any guarantee under the terms of the GNU General
# Public License, either Version 2, June 1991 or Version 3, June 2007.

#The script is used to other annotation info in significant region

use Getopt::Std;
use strict;

## get options from command line
my %opts= ('i'=>'','w'=>10000,'s'=>5000,'a'=>'','f'=>'');

sub usage{
print STDERR <<EOF;
    usage:  $0 -i bed_file -w window -s step -a item -f sig_file [-h]

     -h   : help message;
     -i   : string (bed format) from piping;
     -w   : the size of sliding window;
     -s   : the size of step (overlapped region between two windows); the size of window should be larger than that of step;
     -a   : the name of the annotation;
     -f   : the file of significant region;
    example1: $0 -i stdin -w 10000 -s 5000 -a "protein-gene" -f "*_sigReg.data"
EOF
    exit;
}

getopts('i:w:s:a:f:h', \%opts) || usage();
usage() if ($opts{h});

my ($str,$win,$step,$annotation,$sig_file)=($opts{i},$opts{w},$opts{s},$opts{a},$opts{f});

## read and store significant region
my $header="";
my %sig_hash;
my %sig_nreads;
open (SF,"$sig_file") || warn "can't open  $sig_file";
while(my $sig_line=<SF>){
    if($sig_line=~/(.*idx.*)/){
	$header=$1;
	next;
}
    elsif($sig_line=~/^(\S+\s+\d+\s+\d+\s+(\S+)\s+\d+\s+(\d+).*)/){
	my ($cur_info,$idx,$nreads)=($1,$2,$3);
	$sig_hash{$idx}=$cur_info;
	$sig_nreads{$idx}=$nreads;
}
}
close(SF);

## store all read match information of sliding windows
my %win_info=(); 

while(<$str>){
    if(/^(\S+)\s+(\d+)\s+(\d+)\s+\S+\_(\d+).*\s+(\S+\=.*)/){
	my ($chrm,$ln,$rn,$read_num,$anno)=($1,$2,$3,$4,$5);
	## get gene info
	my @field=split(/\;/,$anno);
	my $gname="";
	my $gtype="";
	foreach my $i (0..$#field){
	    if($field[$i]=~/Name\=(\S+)/){
		$gname=$1;
}
	    if($field[$i]=~/Note\=(\S+)/){
		$gtype=$1;
}
}
	$gname=$gname . "_" . $gtype if ($gtype);
	## compute which windows the read belongs to
	my $lquot=(($ln+1)%$step)<=($win-$step) ? int(($ln+1)/$step) : int(($ln+1)/$step)+1;
	my $rquot=int($rn/$step)+1;
	## save read match info for each related window
	foreach my $i ($lquot..$rquot){
	    my $cur_name=$chrm . "_" . $i;
	    ## get the number of read match
	    $win_info{$cur_name}->{$gname}+=$read_num;
}
}
}

if($header){
## print the header
    print $header,"\t",$annotation,"\n";
    foreach my $i (sort keys %sig_hash){
	if (!$win_info{$i}){
	    print $sig_hash{$i},"\t",0,"\n";
}
	else{
	    my $gene_hash=$win_info{$i};
	    my $gene_info="";
	    foreach my $j (sort keys %{$gene_hash}){
		my $cur_gene_perc=int(100*$$gene_hash{$j}/$sig_nreads{$i}+0.5)/100;
		$gene_info.=$j . ":" .  $cur_gene_perc . ";";
}
	    print $sig_hash{$i},"\t",$gene_info,"\n";
}    
}

}
