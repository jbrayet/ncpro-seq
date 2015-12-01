###!/usr/bin/perl -w

# Copyleft ↄ⃝ 2012 Institut Curie
# Author(s): Jocelyn Brayet, Laurene Syx, Chongjian Chen, Nicolas Servant(Institut Curie) 2012 - 2015
# Contact: bioinfo.ncproseq@curie.fr
# This software is distributed without any guarantee under the terms of the GNU General
# Public License, either Version 2, June 1991 or Version 3, June 2007.

#The script is used to normalize coverage in track file (bed/bedgraph) to RPM (read per million)

use Getopt::Std;
use strict;

## get options from command line
my %opts= ('a'=>'','b'=>'',"f"=>'',"n"=>"1000000");

sub usage{
print STDERR <<EOF;
    usage:  $0 -a track_file -b mapping_stat_file -f bed|bedgraph [-h]

     -h   : help message;
     -a   : input track file, bed or bedgraph format;
     -b   : mapping stat file which contains the number of mapped reads for each sample
     -f   : format of the input track file, bed or bedgraph;
     -n   : normalization scale, default is 1000000 for rpm;

EOF
    exit;
}

getopts('a:b:f:n:h', \%opts) || usage();
usage() if ($opts{h});

my ($track_file,$mapnum_file,$track_format,$scale)=($opts{a},$opts{b},$opts{f},$opts{n});

##load mapping number info
my @map_sample;
my @map_num;
open (MAP,"$mapnum_file") || die;
while(<MAP>){
    if(/^idx\s+(.*)/){
	@map_sample=split(/\t/,$1);
}
    if(/^mapped\s+(.*)/){
	@map_num=split(/\t/,$1);
}
}
close(MAP);

##get current sample name, and curent mapped read num
my $sample_idx=-1;
my $name_len=0;
foreach my $i (0..$#map_sample){
    my $cur_sample=$map_sample[$i];
    $cur_sample=~s/\+/\\\+/g;
    if($track_file=~/$cur_sample\_/){
	if((!$name_len) || ($name_len<length($cur_sample))){
	    $sample_idx=$i;
	    $name_len=length($cur_sample);
}
}
}

exit(0) if ($sample_idx==-1);

my $cur_mapnum=$map_num[$sample_idx];

##calculate RPM for track files

open (TRACK,"$track_file") || die;
while(<TRACK>){
    if(/^track/){
	print $_;
	next;
}
    if(/^(\S+\s+\d+\s+\d+\s+)(\S+)(.*)/){
	my ($loc_info,$cov,$others)=($1,$2,$3);
	my $cov_rpm=$scale*$cov/$cur_mapnum;
	if($track_format eq "bedgraph"){
	    print $loc_info,sprintf("%.4f",$cov_rpm),$others,"\n";
}
	if($track_format eq "bed"){
	    print $loc_info,sprintf("%.4f",$cov_rpm),"\t",sprintf("%.4f",$cov_rpm),$others,"\n";
}
}
}
close(TRACK);
