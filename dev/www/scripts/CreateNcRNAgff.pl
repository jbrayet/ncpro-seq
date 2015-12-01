###!/usr/bin/perl -w

# Copyleft ↄ⃝ 2012 Institut Curie
# Author(s): Jocelyn Brayet, Laurene Syx, Chongjian Chen, Nicolas Servant(Institut Curie) 2012 - 2015
# Contact: bioinfo.ncproseq@curie.fr
# This software is distributed without any guarantee under the terms of the GNU General
# Public License, either Version 2, June 1991 or Version 3, June 2007.

#The script is used to generate a sub-gff3 file from an original gff3 file according to the item given in the command. 
#The script can be simply used to lines containing the item
# There are four types of extended items which are used to modify coordinates: 
# _[iest]_[+-]Number_[+-]Number
# 1. _i_[+-]N1_[+-]N2: shorten [+-]N1 bp at 5' end, [+-]N2 bp at 3' end
# 2. _e_[+-]N1_[+-]N2: extend [+-]N1 bp at 5' end, [+-]N2 bp at 3' end 
# 3. _s_[+-]N1_[+-]N2: get coordinates for sub-region from position N1 to N2 indexed from 5' end 
# 4. _t_[+-]N1_[+-]N2: get coordinates for sub-region from position N1 to N2 indexed from 3' end

use Getopt::Std;
use strict;

## get options from command line
my %opts= ('i'=>'','d'=>'','w'=>'');

sub usage{
print STDERR <<EOF;
    usage:  $0 -i gff_file -w item -d annotDir [-h]

     -h   : help message;
     -i   : input gff file;
     -w   : the item used to match
	    format: Name | Name_[ie]Number1_Number2
	    i: get internal sub-region from location Number1 to Number2
	    e: get extended region with 5' Number1 extra-region and 3' Number2 extras_region
     -d   : the directory which stores snoRNA annotation files;

    example1: $0 -i file -w "tRNA_i_10_50" -d annotation

EOF
    exit;
}

getopts('i:d:w:h', \%opts) || usage();
usage() if ($opts{h});

my ($ori_gff,$item,$annot_dir)=($opts{i},$opts{w},$opts{d});

my ($keyword,$iest,$n1,$n2)=($item,"",0,0);

if($item=~/(\S+)\_([iest])\_([+-]?\d+)\_([+-]?\d+)/){
($keyword,$iest,$n1,$n2)=($1,$2,$3,$4);
}

#get exact snoRNA keywords
if($keyword=~/snoRNA/){    
    $keyword=snoRNA_keyword($keyword);
}

open (GFF,"$ori_gff") ||  warn "can't open bed $ori_gff"; 
while(<GFF>){
    if($keyword=~/(miRNA)|(tRNA)/){
	next if (!/($keyword)(?:(?!\d+))/i);
    }
    else{
        next if (!/=\"?($keyword)\"?;/i);
    }

    if(/^(\S+.*\s+)(\d+)\s+(\d+)(\s+\S+\s+([+-]).*)\s+(\S+)/){
	my ($l_str,$cur_ln,$cur_rn,$r_str,$cur_strand,$cur_features)=($1,$2,$3,$4,$5,$6);	
	if(!$iest){
	    print $_;
	    next;
}
	else{
#for repeatmasker, only full length repeats could be used for extention
	    if($cur_features=~/repSt\=(\d+)\;repEnd\=(\d+)\;repFullLen\=(\d+)\;/){
		next if (($1!=1) || ($2!=$3));
#		next if (($3*0.9)>($2-$1+1))	#repeats which represent >90% of consensus sequence are considered as full length repeat
}
#remove repeat location info for extended hits
	    $cur_features=~s/repSt\=\d+\;repEnd\=\d+\;repFullLen\=\d+\;/fullLength\=1;/g;
	    #compute the sub/extended coordinates
#	    next if (($n1<=0) || ($n2>($cur_rn-$cur_ln+1)));
	    if($iest eq "i"){
		if($cur_strand eq "+"){
		    $cur_ln+=$n1;
		    $cur_rn-=$n2;
}
		else{
		    $cur_ln+=$n2;
		    $cur_rn-=$n1;
}
}
	    elsif($iest eq "e"){
		if($cur_strand eq "+"){
		    $cur_ln-=$n1;
		    $cur_rn+=$n2;
}
		else{
		    $cur_ln-=$n2;
		    $cur_rn+=$n1;
}
}
	    elsif($iest eq "s"){
		if($cur_strand eq "+"){
		    $cur_rn=$cur_ln+$n2-1;
		    $cur_ln=$cur_ln+$n1-1;
}
		else{
		    $cur_ln=$cur_rn-$n2+1;
		    $cur_rn=$cur_rn-$n1+1;
}
}
	    elsif($iest eq "t"){
		if($cur_strand eq "+"){
		    $cur_ln=$cur_rn+$n1-1;
		    $cur_rn=$cur_rn+$n2-1;
}
		else{
		    $cur_rn=$cur_ln-$n1+1;
		    $cur_ln=$cur_ln-$n2+1;
}
}
	    next if ($cur_ln<=0 || $cur_ln>=$cur_rn);
	    $l_str=~s/\s+/\t/g;
	    $r_str=~s/\s+/\t/g;
	    print "$l_str$cur_ln\t$cur_rn$r_str\t$cur_features\n";
}
}
}
close(GFF);

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
