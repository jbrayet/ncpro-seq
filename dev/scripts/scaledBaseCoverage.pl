###!/usr/bin/perl -w

# Copyleft ↄ⃝ 2012 Institut Curie
# Author(s): Jocelyn Brayet, Laurene Syx, Chongjian Chen, Nicolas Servant(Institut Curie) 2012 - 2015
# Contact: bioinfo.ncproseq@curie.fr
# This software is distributed without any guarantee under the terms of the GNU General
# Public License, either Version 2, June 1991 or Version 3, June 2007.

#The script is used to calculate the base coverage in a bed file. 

use Getopt::Std;
use strict;
use POSIX;

## get options from command line
my %opts= ('i'=>'','c'=>'','w'=>'','n'=>1000,'s'=>'1','f'=>'');

sub usage{
print STDERR <<EOF;
    usage:  $0 -i bed_file [-cwsh]

     -h   : help message;
     -i   : input bed file;
     -c   : the chromosome you want to focus on;
     -w   : the keyword you want to filter all lines;
     -n   : the number to which real size should be scaled;
     -s   : the value to decide the way to compute coverage. if set to 1, the coverage of read abundance is computed, if set to 0, the coverage of distinct read counts  will be computed;
     -f   : the filename prefix;

EOF
    exit;
}

getopts('i:c:w:n:s:f:h', \%opts) || usage();
usage() if ($opts{h});

my ($bed_file,$chrm,$keyword,$scale_num,$use_exp,$file_prefix)=($opts{i},$opts{c},$opts{w},$opts{n},$opts{s},$opts{f});

open (BED,"$bed_file") || warn "can't open  $bed_file";

my %duplicate;
my %base_cov;
my %base_cov_5;
my %base_cov_3;
my $cons_len_all;
my %ann_item_hash;
my %ann_item_cov;
my $repeat_full=0; #focus on full length of repeat or not

while(<BED>){
    next if ($keyword && (!/$keyword/)); ## filter keyword
    ## for special bed file which contain two hit in one line
    if(/^(\S+)\s+(\d+)\s+(\d+)\s+(\S+\_(\d+))\s+(\d+)\s+([+-])(.*\s+(\d+)\s+(\d+)\s+.*\s+([+-]).*\s+(\S+))/){
	my ($name,$l1,$r1,$read_name,$read_num,$cov,$s1,$ann_item,$l2,$r2,$s2,$info)=($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12);
	my $nc_len=$r2-$l2+1;
	my ($cons_st,$cons_end,$cons_len)=(1,$nc_len,$nc_len);
	#in case of truncated repeats
	if($info=~/repSt\=(\d+)\;repEnd\=(\d+)\;repFullLen\=(\d+)\;/){
	    ($cons_st,$cons_end,$cons_len)=($1,$2,$3);
}
	#check if only focus on full length of repeat
	if($info=~/fullLength\=1;/){
	    $repeat_full=1;
}
#discard strange repeatmasker result
#chr1	22317855	22317879	124110_1	2683	-	chr1	rmskmm9	LINE	22317840	22317896	.	+	.	repName=Lx6;repClass=LINE;repFamily=L1;repSt=7124;repEnd=7128;repFullLen=7460;
#chr1	rmskmm9	LINE	4288590	4288644	.	+	.	repName=L1_Mur2;repClass=LINE;repFamily=L1;repSt=2974;repEnd=2974;repFullLen=5877;
	next if (($cons_end-$cons_st)<($r1-$l1));
#	warn $_,$cons_st,"\t",$cons_end,"\t",$cons_len,"\n";
	$cons_len_all.=$cons_len . "\t";
	next if ($chrm && ($chrm ne $name)); ## filter chromosome name
	my $coord_id=$name . "_" . $l1 . "_" . $r1 . "_" . $s1;
	next if ((!$use_exp) && $duplicate{$coord_id}); ## each genome coordinate is counted once when calculating coverage ignoring abundance 
	$duplicate{$coord_id}=1;
	$cov=1/$cov if (!$repeat_full);
	$cov*=$read_num if($use_exp);

	my ($read_sub_ln,$read_sub_rn)=(0,0);
	## get exact overlapping position inside hit2
	if($s2 eq "+"){
	    $read_sub_ln=($l1-$l2+2)>0 ? ($l1-$l2+2) : 1;
	    $read_sub_rn=($r1-$l2)<($r2-$l2) ? ($r1-$l2+1) : ($r2-$l2+1);
}
        else{
	    $read_sub_ln=($r2-$r1+1)>0 ? ($r2-$r1+1) : 1;
	    $read_sub_rn=($r2-$l1)<($r2-$l2+1) ? ($r2-$l1) : ($r2-$l2+1);
}
#	warn $read_sub_ln,"\t",$read_sub_rn,"\n";
	## calculate base coverage
	if($s1 eq $s2){
	    cal_basecov($read_sub_ln,$read_sub_rn,$nc_len,$cons_st,$cons_end,$cons_len,$cov,"+");
}
	else{
	    cal_basecov($read_sub_ln,$read_sub_rn,$nc_len,$cons_st,$cons_end,$cons_len,$cov,"-");
}
	if(!$ann_item_hash{$ann_item}){
	    cal_anncov($cons_st,$cons_end,$cons_len);
	    $ann_item_hash{$ann_item}=1;
}
	## get the biggest size of hit
#	$max_n=($r2-$l2) if (($r2-$l2)>$max_n);
	next;
}
}

## get sample name
my $sample="";
if($bed_file=~/.*\/(\S+)\.bed/){
    $sample=$1;
}

## get median length of consensus sequence
my $median_cons_len=median_len($cons_len_all);

## output
open(OUTA,">$file_prefix\_all.data");
open(OUTF,">$file_prefix\_5end.data");
open(OUTT,">$file_prefix\_3end.data");
print OUTA "idx\t",$sample,"_sense_",$median_cons_len,"\t",$sample,"_antisense_",$median_cons_len,"\n";
print OUTF "idx\t",$sample,"_sense_",$median_cons_len,"\t",$sample,"_antisense_",$median_cons_len,"\n";
print OUTT "idx\t",$sample,"_sense_",$median_cons_len,"\t",$sample,"_antisense_",$median_cons_len,"\n";
foreach my $pos (1..$scale_num){
    $base_cov{$pos}->{"+"}=0 if (!$base_cov{$pos}->{"+"});
    $base_cov{$pos}->{"-"}=0 if (!$base_cov{$pos}->{"-"});
    $base_cov_5{$pos}->{"+"}=0 if (!$base_cov_5{$pos}->{"+"});
    $base_cov_5{$pos}->{"-"}=0 if (!$base_cov_5{$pos}->{"-"});
    $base_cov_3{$pos}->{"+"}=0 if (!$base_cov_3{$pos}->{"+"});
    $base_cov_3{$pos}->{"-"}=0 if (!$base_cov_3{$pos}->{"-"});
    $ann_item_cov{$pos}=1 if (!$ann_item_cov{$pos});
    print OUTA "$pos\t",$base_cov{$pos}->{"+"}/$ann_item_cov{$pos},"\t",$base_cov{$pos}->{"-"}/$ann_item_cov{$pos},"\n";
    print OUTF "$pos\t",$base_cov_5{$pos}->{"+"}/$ann_item_cov{$pos},"\t",$base_cov_5{$pos}->{"-"}/$ann_item_cov{$pos},"\n";
    print OUTT "$pos\t",$base_cov_3{$pos}->{"+"}/$ann_item_cov{$pos},"\t",$base_cov_3{$pos}->{"-"}/$ann_item_cov{$pos},"\n";
}
close(OUTA);
close(OUTF);
close(OUTT);

#########
## function used to compute the base coverage of reads
sub cal_basecov{
    my ($readncSt,$readncEnd,$ncLen,$conSt,$conEnd,$conLen,$sc,$strand)=@_;
    my $conSt_scale=ceil(($conSt-1)/($conLen/$scale_num))+1;
    my $conEnd_scale=ceil($conEnd/($conLen/$scale_num));
    my $conLen_scale=$conEnd_scale-$conSt_scale+1;
    my $readncSt_scale=ceil(($readncSt-1)/($ncLen/$conLen_scale))+1;
    my $readncEnd_scale=ceil($readncEnd/($ncLen/$conLen_scale));
    my $readSt_scale=$conSt_scale+$readncSt_scale-1;
    my $readEnd_scale=$conSt_scale+$readncEnd_scale-1;
#    if($conSt_scale>=$conEnd_scale){
#	warn $bed_file,"\n";
#	warn $readncSt,"\t",$readncEnd,"\t",$ncLen,"\t",$conSt,"\t",$conEnd,"\t",$conLen,"\t",$sc,"\t",$strand,"\n";
#	warn $conSt_scale,"\t",$conEnd_scale,"\t",$conLen_scale,"\t",$readncSt_scale,"\t",$readncEnd_scale,"\t",$readSt_scale,"\t",$readEnd_scale,"\n";
#}

    if($strand eq "-"){
	$base_cov_5{$readEnd_scale}->{$strand}+=$sc;
	$base_cov_3{$readSt_scale}->{$strand}+=$sc;
}
    else{
	$base_cov_5{$readSt_scale}->{$strand}+=$sc;
	$base_cov_3{$readEnd_scale}->{$strand}+=$sc;
}
    for(my $i=$readSt_scale;$i<=$readEnd_scale;$i++){
	$base_cov{$i}->{$strand}+=$sc;
}
}

#########
## function used to compute the base coverage of annotation items
sub cal_anncov{
    my ($annSt,$annEnd,$conLen)=@_;
    my $annSt_scale=ceil(($annSt-1)/($conLen/$scale_num))+1;
    my $annEnd_scale=ceil($annEnd/($conLen/$scale_num));
    for(my $i=$annSt_scale;$i<=$annEnd_scale;$i++){
	$ann_item_cov{$i}++;
}
}

#########
#function to calcluate the median score in a given string.
sub median_len{
    my ($s)=@_;
    my @array=split(/\t/,$s);
    my $count=$#array + 1;
    @array=sort {$a <=> $b} @array;
    my $median="";
    if ($count % 2){
	$median=$array[int($count/2)];
} 
    else{
	$median=($array[$count/2]+$array[$count/2 - 1])/2;
}
    return($median);
}
