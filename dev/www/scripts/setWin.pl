###!/usr/bin/perl -w

# Copyleft ↄ⃝ 2012 Institut Curie
# Author(s): Jocelyn Brayet, Laurene Syx, Chongjian Chen, Nicolas Servant(Institut Curie) 2012 - 2015
# Contact: bioinfo.ncproseq@curie.fr
# This software is distributed without any guarantee under the terms of the GNU General
# Public License, either Version 2, June 1991 or Version 3, June 2007.

#The script is used to slide the defined window in the genome, and obtain aligned reads and boundary for each window

use Getopt::Std;
use strict;

## get options from command line
my %opts= ('i'=>'','w'=>10000,'s'=>5000,'g'=>'','o'=>'');

sub usage{
print STDERR <<EOF;
    usage:  $0 -i bed_file -w window -s step -g chrm_size -o output [-h]

     -h   : help message;
     -i   : string (bed format) from piping;
     -w   : the size of sliding window;
     -s   : the size of step (overlapped region between two windows); the size of window should be larger than that of step;
     -o   : suffix of output name;
     -g   : the genome size file;
    example1: $0 -i stdin -w 10000 -s 5000 -g chrm.size -o out

EOF
    exit;
}

getopts('i:w:s:g:o:h', \%opts) || usage();
usage() if ($opts{h});

my ($str,$win,$step,$gsize,$output)=($opts{i},$opts{w},$opts{s},$opts{g},$opts{o});

## get size of each chromosome
my %chrm_size;
open (GSIZE,"$gsize") || warn "can't open  $gsize";
while(<GSIZE>){
    if(/^(\S+)\s+(\d+)/){
	my ($chrm,$size)=($1,$2);
	$chrm_size{$chrm}=$size;
}
}
close(GSIZE);

open (WINOUT,">$output\_window.data");
open (LENOUT,">$output\_lendistr.data");
my %win_info=(); ## store all read match information of sliding windows
my %interval=(); ## store the information of interval corresponding to reads which match the same genomic region, but might have slightly different sequence (1~2 mismatches);
my %len_info=(); ## store the information of length distribution
my $pre_chrm="";
my ($min_len,$max_len)=(10000,0);
## print the header for window file
print WINOUT "chr\tstart\tend\tidx\tn.overlap\tn.reads\tn.unique\tfrac.plus\tmax.reads\texpr\tlen.distr\n";
while(<$str>){
    if(/^(\S+)\s+(\d+)\s+(\d+)\s+\S+\_(\d+)\s+(\S+)\s+([+-])/){
	my ($chrm,$ln,$rn,$read_num,$mapnum,$strand)=($1,$2,$3,$4,$5,$6);
	$chrm=~s/MT/M/;
	if (($pre_chrm ne $chrm) && (%win_info)){
	    if($chrm_size{$pre_chrm}){
		print_win($pre_chrm);
}
	    %interval=();
	    %win_info=();
}
	my $interval_id=$chrm . "_" . $ln . "_" .$rn . $strand; ## id for each interval
	$interval{$interval_id}=0 if (!$interval{$interval_id});
	my $cur_len=$rn-$ln;
	$min_len=$cur_len if ($cur_len<$min_len);
	$max_len=$cur_len if ($cur_len>$max_len);
	$len_info{$cur_len}+=$read_num;
	## compute which windows the read belongs to
	my $lquot=(($ln+1)%$step)<=($win-$step) ? int(($ln+1)/$step) : int(($ln+1)/$step)+1;
	my $rquot=int($rn/$step)+1;
	## save read match info for each related window
	foreach my $i ($lquot..$rquot){
	    my $cur_name=$chrm . "_" . $i;
	    ## get the number of read match
	    $win_info{$cur_name}->{ct}+=$read_num;
	    ## get the number of read with unique match in the genome
	    $win_info{$cur_name}->{unique}=0 if (!$win_info{$cur_name}->{unique});
	    $win_info{$cur_name}->{unique}+=$read_num if ($mapnum==$read_num);
	    ## get the number of read match considering the number of matches in the genome
	    $win_info{$cur_name}->{exp}+=$mapnum;
	    ## get the boundary of read match region in the window
	    $win_info{$cur_name}->{ln}=$ln if ((!$win_info{$cur_name}->{ln}) || ($win_info{$cur_name}->{ln}>$ln));
	    $win_info{$cur_name}->{rn}=$rn if ((!$win_info{$cur_name}->{rn}) || ($win_info{$cur_name}->{rn}<$rn));
	    ## get the plus mapped read number
	    $win_info{$cur_name}->{plus}=0 if (!$win_info{$cur_name}->{plus});
	    $win_info{$cur_name}->{plus}+=$read_num if ($strand eq "+");
	    ## get the number of interval
	    $win_info{$cur_name}->{interval}++ if (!$interval{$interval_id});
	    ## get the maximum read match in intervals
	    $win_info{$cur_name}->{maxread}=$interval{$interval_id}+$read_num if ((!$win_info{$cur_name}->{maxread}) || ($win_info{$cur_name}->{maxread}<($interval{$interval_id}+$read_num)));
	    my $len_id="L" . $cur_len;
	    $win_info{$cur_name}->{$len_id}+=$read_num;
}
	$interval{$interval_id}+=$read_num;
	$pre_chrm=$chrm;
}
}
if($chrm_size{$pre_chrm}){
    print_win($pre_chrm);
}

## print the whole length distribution for all reads
print LENOUT "\tcount\n";
foreach my $j ($min_len..$max_len){
    if(!$len_info{$j}){
	print LENOUT $j,"\t",0,"\n";
}
    else{
	print LENOUT $j,"\t",$len_info{$j},"\n";
}
}

close(LENOUT);
close(WINOUT);

## print the read match info for sliding windows in each chromosome
sub print_win{
    my ($chrm)=@_;
    my $cur_chrm_len=$chrm_size{$chrm};
    my $max_win_idx=int(($cur_chrm_len-$win)/$step)+1;
    foreach my $i (1..$max_win_idx){
	my $cur_id=$chrm . "_" . $i;
	if(!$win_info{$cur_id}){
	    print WINOUT $chrm,"\t",$i*$step,"\t",$i*$step+$win,"\t",$cur_id,"\t",0,"\t",0,"\t",0,"\t",0,"\t",0,"\t",0,"\t",0,"\n";
}
	else{
	    print WINOUT $chrm,"\t",$win_info{$cur_id}->{ln},"\t",$win_info{$cur_id}->{rn},"\t",$cur_id,"\t",$win_info{$cur_id}->{interval},"\t",$win_info{$cur_id}->{ct},"\t",$win_info{$cur_id}->{unique},"\t",$win_info{$cur_id}->{plus}/$win_info{$cur_id}->{ct},"\t",$win_info{$cur_id}->{maxread},"\t",$win_info{$cur_id}->{exp},"\t";
	    ## print the length distribution, together with the boundary of length
	    print WINOUT "L",$min_len;
	    foreach my $len ($min_len..$max_len){
		my $cur_len_id="L" . $len;
		if(!$win_info{$cur_id}->{$cur_len_id}){
		    print WINOUT ":0";
}
		else{
		    print WINOUT ":",$win_info{$cur_id}->{$cur_len_id};
}
}
	    print WINOUT ":L",$max_len,"\n";
}
}
}
