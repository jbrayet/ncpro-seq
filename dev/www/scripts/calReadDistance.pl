###!/usr/bin/perl -w

# Copyleft ↄ⃝ 2012 Institut Curie
# Author(s): Jocelyn Brayet, Laurene Syx, Chongjian Chen, Nicolas Servant(Institut Curie) 2012 - 2015
# Contact: bioinfo.ncproseq@curie.fr
# This software is distributed without any guarantee under the terms of the GNU General
# Public License, either Version 2, June 1991 or Version 3, June 2007.

#The script is used to compute distribution of read offset. 

use Getopt::Std;
use strict;
use POSIX;

## get options from command line
my %opts= ('i'=>'','n'=>50,'s'=>'1');

sub usage{
print STDERR <<EOF;
    usage:  $0 -i bed_file [-cwsh]

     -h   : help message;
     -i   : input bed file;
     -n   : the distance to check offset;
     -s   : the value to decide the way to compute coverage. if set to 1, the coverage of read abundance is computed, if set to 0, the coverage of distinct read counts  will be computed;

EOF
    exit;
}

getopts('i:n:s:f:h', \%opts) || usage();
usage() if ($opts{h});

my ($bed_file,$distance,$use_exp,$file_prefix)=($opts{i},$opts{n},$opts{s},$opts{f});

my %sense_hits;
my %anti_hits;
my $min_len=5000;
my $max_len=0;

##load bed files into hash
open (BED1,"$bed_file") || warn "can't open $bed_file";
while(<BED1>){
    if(/^(\S+)\s+(\d+)\s+(\d+)\s+\S+\s+\S+\s+([+-])/){
	my ($name,$ln,$rn,$strand)=($1,$2,$3,$4);
	my $len=$rn-$ln;
	$min_len=$len if ($len<$min_len);
	$max_len=$len if ($len>$max_len);
	if($strand eq "+"){
	    $sense_hits{$name}{$ln}.=$_;
	}
	else{
	    ##store start of reads
	    $anti_hits{$name}{$rn}.=$_;
	}
    }
}
close(BED1);

##proces sense mapped reads one by one, to compute read offset in the sense and antisense direction.
my %sense_offset;
my %anti_offset;
open (BED2,"$bed_file") || warn "can't open $bed_file";
while(<BED2>){
    if(/^(\S+)\s+(\d+)\s+\d+\s+\S+\s+\S+\s+\+/){
	my ($name,$ln)=($1,$2);
	##compute sense offset
	foreach my $i (1..$distance){
	    my $cur_idx=$ln+$i;
	    next if (!$sense_hits{$name}{$cur_idx});
	    while($sense_hits{$name}{$cur_idx}=~/$name\s+(\d+)\s+(\d+)\s+\S+\_(\d+)\s+(\S+)\s+\+/g){
		my ($this_ln,$this_rn,$this_read_num,$this_cov)=($1,$2,$3,$4);
		$this_cov=1/$this_cov;
		$this_cov*=$this_read_num if ($use_exp);
		my $this_len=$this_rn-$this_ln;
		$sense_offset{$i}{$this_len}+=$this_cov;
	    }
	}
	##compute antisense offset
	foreach my $i (1..$distance){
	    my $cur_idx=$ln+$i;
	    next if (!$anti_hits{$name}{$cur_idx});
	    while($anti_hits{$name}{$cur_idx}=~/$name\s+(\d+)\s+(\d+)\s+\S+\_(\d+)\s+(\S+)\s+\-/g){
		my ($this_ln,$this_rn,$this_read_num,$this_cov)=($1,$2,$3,$4);
		$this_cov=1/$this_cov;
		$this_cov*=$this_read_num if ($use_exp);
		my $this_len=$this_rn-$this_ln+1;
		$anti_offset{$i}{$this_len}+=$this_cov;
	    }
	}
    }
}
close(BED2);

##output offsets
print "Distance\tRead_length\tCoverage\tDirection\n";
foreach my $i (1..$distance){
    foreach my $read_len ($min_len..$max_len){
	if ($sense_offset{$i}{$read_len}){
	    print $i,"\t",$read_len,"\t",$sense_offset{$i}{$read_len},"\tSense\n";
	}
	if ($anti_offset{$i}{$read_len}){
	    print $i,"\t",$read_len,"\t-",$anti_offset{$i}{$read_len},"\tAntisense\n";
	}	
    }
}
