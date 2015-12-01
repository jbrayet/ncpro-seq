###!/usr/bin/perl -w

# Copyleft ↄ⃝ 2012 Institut Curie
# Author(s): Jocelyn Brayet, Laurene Syx, Chongjian Chen, Nicolas Servant(Institut Curie) 2012 - 2015
# Contact: bioinfo.ncproseq@curie.fr
# This software is distributed without any guarantee under the terms of the GNU General
# Public License, either Version 2, June 1991 or Version 3, June 2007.

#The script is used to compute coverage for bedgraph

use Getopt::Std;
use strict;

## get options from command line
my %opts= ('i'=>'');

sub usage{
print STDERR <<EOF;
    usage:  $0 -i stdin [-h]

     -h   : help message;
     -i   : lines from pipe;

EOF
    exit;
}

getopts('i:h', \%opts) || usage();
usage() if ($opts{h});

my ($in_line)=($opts{i});

my %region_cov=();
my ($pre_chrm,$pre_ln,$pre_rn)=("",0,0);
while(<$in_line>){
    if(/(\S+)\s+(\d+)\s+(\d+)\s+(\S+)/){
	my ($cur_chrm,$ln,$rn,$coverage)=($1,$2,$3,$4);
	$ln++;
	if(($cur_chrm ne $pre_chrm) || ($ln>$pre_rn)){
	    if($pre_rn){
		for(my $i=$pre_ln;$i<=$pre_rn;$i++){
		    print $pre_chrm,"\t",$i-1;
		    while($region_cov{$i+1} && ($region_cov{$i}==$region_cov{$i+1})){
			$i++;
}
		    print "\t",$i,"\t",sprintf("%.4f",$region_cov{$i}),"\n";
}
}
	    %region_cov=();
	    $pre_ln=0;
	    $pre_rn=0;
}
	foreach my $i ($ln..$rn){
	    $region_cov{$i}+=$coverage;
}
	$pre_rn=$rn if($rn>$pre_rn);
	$pre_chrm=$cur_chrm;
	$pre_ln=$ln if (!$pre_ln);
}
}

for(my $i=$pre_ln;$i<=$pre_rn;$i++){
    print $pre_chrm,"\t",$i-1;
    while($region_cov{$i+1} && ($region_cov{$i}==$region_cov{$i+1})){
	$i++; 
}
    print "\t",$i,"\t",sprintf("%.4f",$region_cov{$i}),"\n";
}
