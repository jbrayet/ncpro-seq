###!/usr/bin/perl -w

# Copyleft ↄ⃝ 2012 Institut Curie
# Author(s): Jocelyn Brayet, Laurene Syx, Chongjian Chen, Nicolas Servant(Institut Curie) 2012 - 2015
# Contact: bioinfo.ncproseq@curie.fr
# This software is distributed without any guarantee under the terms of the GNU General
# Public License, either Version 2, June 1991 or Version 3, June 2007.

#The script is used to process bam files: 
#if -g is specified with 1, group alignments which have the same read sequence.
#or else, just output original sequence with extended read name with "_1" suffix in order to have the same name format as group read.

use Getopt::Std;
use strict;

## get options from command line
my %opts= ('i'=>'','g'=>'');

sub usage{
print STDERR <<EOF;
    usage:  $0 -i stdin -g 1|0 [-h]

     -h   : help message;
     -i   : lines in bam file from pipe;
     -g   : group read or not, 1: yes, 0: no;

EOF
    exit;
}

getopts('i:g:h', \%opts) || usage();
usage() if ($opts{h});

my ($bam_line,$do_group)=($opts{i},$opts{g});

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

my %read_gp=();
my %read_name=();

while(<$bam_line>){
    if(/^(\S+)\s+(\S+)\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+(\S+)/){
	my ($cur_name,$cur_flag,$cur_seq)=($1,$2,$3);
	next if ($read_name{$cur_name});
        #get flag information
	my $flag_content="";
	foreach my $item (keys %sam_flags){
	    if($cur_flag & $sam_flags{$item}){
		$flag_content.=" ". $item;
}
}
        #do reverse complementary if the read is mapped in reverse strand
	if($flag_content=~/reverse/){
	    $cur_seq=revcompl($cur_seq);
}
	$read_name{$cur_name}=1;
	#group read if $do_group is active, or else output read with extended name
	if ($do_group==1){
	    $read_gp{$cur_seq}++;
}
	else{
	    print $cur_name,"_1\n",$cur_seq,"\n";
}
}
}

#output read group if $do_group is active
if($do_group==1){
    my $gp_id=1;
    foreach my $seq (keys %read_gp){
	my $cur_ct=$read_gp{$seq};
	my $cur_id=$gp_id . "_" . $cur_ct;
	print ">",$cur_id,"\n";
	print $seq,"\n";
	$gp_id++;
}
}


## return reverse complementary sequence
sub revcompl{
    my ($s)=@_;
    $s=reverse($s);
    $s=~ tr/ACGTacgt/TGCAtgca/;
    return $s;
}
