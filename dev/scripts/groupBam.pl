###!/usr/bin/perl -w

# Copyleft ↄ⃝ 2012 Institut Curie
# Author(s): Jocelyn Brayet, Laurene Syx, Chongjian Chen, Nicolas Servant(Institut Curie) 2012 - 2015
# Contact: bioinfo.ncproseq@curie.fr
# This software is distributed without any guarantee under the terms of the GNU General
# Public License, either Version 2, June 1991 or Version 3, June 2007.

#The script is used to generate grouped bam files.

use Getopt::Std;
use strict;

## get options from command line
my %opts= ('i'=>'','g'=>'');

sub usage{

print STDERR <<EOF;
    usage:  $0 -i stdin -g grouped_fasta [-h]

     -h   : help message;
     -i   : lines in bam file from pipe;
     -g   : seq group (fasta);

EOF
    exit;
}

getopts('i:g:h', \%opts) || usage();
usage() if ($opts{h});

my ($bam_line,$gfile)=($opts{i},$opts{g});

##explanation of flag in Sam format
my %sam_flags=(
    "read paired" => 0x1,
    "read mapped in proper pair" => 0x2,
    "read unmapped" => 0x4,
    "mate unmapped" => 0x8,
    "read reverse strand" => 0x10,
    "mate reverse strand" => 0x20,
    "first in pair" => 0x40,
    "second in pair" => 0x80,
    "not primary alignment" => 0x100,
    "read fails platform/vendor quality checks" => 0x200,
    "read is PCR or optical duplicate" => 0x400,
);

my %gp;
my $cur_name="";
open(GIN,"$gfile") || die;
while(<GIN>){
    if(/>(\S+)/){
	$cur_name=$1;
	next;
    }
    if(/(\S+)/){
	my $cur_seq=$1;
	$gp{$cur_seq}=$cur_name;
    }
}
close(GIN);

my %duplicate;
while(<$bam_line>){
    if(/^\S+\s+((\S+)\s+(\S+)\s+(\S+)\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+(\S+).*)/){
	my ($info,$flag,$s1,$s2,$seq)=($1,$2,$3,$4,$5);
	#get flag information
	my $flag_content="";
	foreach my $item (keys %sam_flags){
	    if($flag & $sam_flags{$item}){
		$flag_content.=" ". $item;
	    }
	}
	#do reverse complementary if the read is mapped in reverse strand
	if($flag_content=~/reverse/){
	    $seq=revcompl($seq);
	}
	my $cur_id=$s1 . "_" . $s2 . "_" . $seq;
	next if ($duplicate{$cur_id});
	if ($gp{$seq}){
	    print $gp{$seq},"\t",$info,"\n";
	}
	$duplicate{$cur_id}=1;
    }
}

## return reverse complementary sequence
sub revcompl{
    my ($s)=@_;
    $s=reverse($s);
    $s=~ tr/ACGTacgt/TGCAtgca/;
    return $s;
}
