###!/usr/bin/perl -w

# Copyleft ↄ⃝ 2012 Institut Curie
# Author(s): Jocelyn Brayet, Laurene Syx, Chongjian Chen, Nicolas Servant(Institut Curie) 2012 - 2015
# Contact: bioinfo.ncproseq@curie.fr
# This software is distributed without any guarantee under the terms of the GNU General
# Public License, either Version 2, June 1991 or Version 3, June 2007.

#The script is used to calculate the base coverage in a bed file
#For classical bed format, the base coverage will be computed based on the cooridnates (column 1 to 3) and strand information (column 6)
#bed example: chr1	3047726	3047752	HWI-ST365_0142:8:1103:17188:171681#GGCTAC/1	255	+
#For special use, it could handle the output from intersectBed with parameters -wa -wb -bed. In this case, the base coverage will be compued based on the length of the secondary coordiantes (column 8 and 9) and two strand information (column 6 and 12)
#bed example: chr1	3047726	3047752	HWI-ST365_0142:8:1103:17188:171681#GGCTAC/1	255	+	chr1	3047720	3047750	g1	11	+



use Getopt::Std;
use strict;

## get options from command line
my %opts= ('i'=>'','c'=>'','w'=>'','s'=>1);

sub usage{
print STDERR <<EOF;
    usage:  $0 -i bed_file [-cwsh]

     -h   : help message;
     -i   : input bed file;
     -c   : the chromosome you want to focus on;
     -w   : the keyword you want to filter all lines;
     -s   : use value in score column in bed file to compute the coverage (1/value), 1 (yes)or 0 (no), default is 1;

    example1: $0 -i file
    example2: $0 -i file -c "chr1" -w "tRNA" -s 0

EOF
    exit;
}

getopts('i:c:w:s:h', \%opts) || usage();
usage() if ($opts{h});

my ($bed_file,$chrm,$keyword,$use_sc)=($opts{i},$opts{c},$opts{w},$opts{s});

open (BED,"$bed_file") || warn "can't open  $bed_file";

my %duplicate;
my %base_cov;
my $max_n=0;
while(<BED>){
    next if ($keyword && (!/$keyword/)); ## filter keyword
    ## for special bed file which contain two hit in one line
    if(/^(\S+)\s+(\d+)\s+(\d+)\s+(\S+)\s+(\d+)\s+([+-]).*\s+(\d+)\s+(\d+)\s+.*\s+([+-])/){
	my ($name,$l1,$r1,$read_name,$cov,$s1,$l2,$r2,$s2)=($1,$2,$3,$4,$5,$6,$7,$8,$9);
	my $uniq_id=$read_name . "_" . $l1 . $s1;
	next if ($duplicate{$uniq_id}); ## skip when reads with the same name and cooridates have already been counted
	$duplicate{$uniq_id}=1;
	next if ($chrm && ($chrm ne $name)); ## filter chromosome name
	$cov=1/$cov;
	$cov=1 if (!$use_sc); ## to decide which score to be used in coverage calculation
	my ($sub_ln,$sub_rn)=(0,0);
	## get exact overlapping position inside hit2
	if($s2 eq "+"){
	    $sub_ln=($l1-$l2+2)>0 ? ($l1-$l2+2) : 1;
	    $sub_rn=($r1-$l2)<($r2-$l2) ? ($r1-$l2+1) : ($r2-$l2+1);
}
        else{
	    $sub_ln=($r2-$r1+1)>0 ? ($r2-$r1+1) : 1;
	    $sub_rn=($r2-$l1)<($r2-$l2+1) ? ($r2-$l1) : ($r2-$l2+1);
}
	## calculate base coverage
	if($s1 eq $s2){
	    cal_basecov($sub_ln,$sub_rn,$cov,"+");
}
	else{
	    cal_basecov($sub_ln,$sub_rn,$cov,"-");
}
	## get the biggest size of hit
	$max_n=($r2-$l2) if (($r2-$l2)>$max_n);
	next;
}
    ## for classical bed format
    if(/^(\S+)\s+(\d+)\s+(\d+)\s+(\S+)\s+(\d+)\s+([+-])/){
	my ($name,$ln,$rn,$read_name,$cov,$s)=($1,$2,$3,$4,$5,$6);
	my $uniq_id=$read_name . "_" . $ln . $s;
	next if ($duplicate{$uniq_id}); ## skip when reads with the same name and cooridates have already been counted
	$duplicate{$uniq_id}=1;
	next if ($chrm && ($chrm ne $name));  ## filter chromosome name
	$cov=1/$cov;
	$cov=1 if (!$use_sc); ## to decide which score to be used in coverage calculation
	## calculate base coverage
	cal_basecov($ln,$rn,$cov,$s);
	## get the biggest size of hit
	$max_n=$rn if ($rn>$max_n);
}
}
close(BED);


## get sample name
my $sample="";
if($bed_file=~/.*\/(\S+)\.bed/){
    $sample=$1;
}

## output

print "idx\t",$sample,"_sense\t",$sample,"_antisense\n";
foreach my $pos (1..$max_n){
    $base_cov{$pos}->{"+"}=0 if (!$base_cov{$pos}->{"+"});
    $base_cov{$pos}->{"-"}=0 if (!$base_cov{$pos}->{"-"});
    print "$pos\t",$base_cov{$pos}->{"+"},"\t",$base_cov{$pos}->{"-"},"\n";
}

## function used to compute the base coverage
sub cal_basecov{
    my ($n1,$n2,$sc,$strand)=@_;
    for(my $i=$n1;$i<=$n2;$i++){
	$base_cov{$i}->{$strand}+=(1/$sc);
}
}
