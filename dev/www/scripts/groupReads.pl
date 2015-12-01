###!/usr/bin/perl -w

# Copyleft ↄ⃝ 2012 Institut Curie
# Author(s): Jocelyn Brayet, Laurene Syx, Chongjian Chen, Nicolas Servant(Institut Curie) 2012 - 2015
# Contact: bioinfo.ncproseq@curie.fr
# This software is distributed without any guarantee under the terms of the GNU General
# Public License, either Version 2, June 1991 or Version 3, June 2007.

#The script is used to group reads which have the same sequence in raw sequencing data. For fastq reads, the mean quality score is computed in each read group.
#

use Getopt::Std;
use utf8;
use strict;
use POSIX;

## get options from command line
my %opts= ('i'=>'','f'=>'');

sub usage{
print STDERR <<EOF;

    usage:  $0 -i read_file -f format [-h]

     -h   : help message;
     -i   : input read file;
     -f   : format of read file, could be specified as "fa","csfasta", "solexa", "solexa1.3", and "phred33";

    example1: $0 -i file -f "phred33" > output
    example2: $0 -i file -f "fa" > output
    example3: $0 -i file -f "csfasta" > output

EOF
    exit;
}

getopts('i:f:h', \%opts) || usage();
usage() if ($opts{h});

my ($read_file,$format)=($opts{i},$opts{f});

##specify start identifier of read (> or @) in sequence file
my $stid=">";
if($format!~/fa/){
    $stid="@";
}

my ($cur_seq,$cur_qc)=("","");
my %seq_len=(); # hash of sequence length
my %seq_group=(); # hash of read group 

open (SEQ,"$read_file") || warn "can't open $read_file";
while(<SEQ>){
    if(/^$stid(\S+)/){
	my $cur_header=$1;
	$cur_seq=<SEQ>;
	chomp($cur_seq);
	my $cur_seq_len=length($cur_seq);

        ##validate the fasta/csfast format
	if($format eq "fasta"){
	    if($cur_seq!~/[ATGCNatgcN]{$cur_seq_len,}/){
		die("$read_file is not a fasta file\n");
	    } 
	}
	if($format eq "csfasta"){
	    my $len_nonuc=$cur_seq_len-1;
	    ##Remove the first tag from the sequence length
	    $cur_seq_len=$cur_seq_len-1;
	    if($cur_seq!~/[ATGCatgc][01234\.]{$len_nonuc,}/){
		die("$read_file is not a csfasta file\n");
	    }
	}

	#get read group (distinct read) information
	$seq_group{$cur_seq}{"ct"}++;
	my $nuc_pos=1;
	if($format eq "csfasta"){
	    $cur_seq=colorTobase($cur_seq);
	}
	#process fastq reads
	if($stid eq "@"){
	    my $mid_line=<SEQ>;
            #validate the fastq format
	    if($mid_line!~/^\+/){
		die("$read_file is not a fastq file\n");
	    }
	    $cur_qc=<SEQ>;

	    chomp($cur_qc);
	    my $pos=1;
	    my @cur_seq_qc=0;
	    @cur_seq_qc=split(/\;/,$seq_group{$cur_seq}{"qc"}) if ($seq_group{$cur_seq}{"qc"});
	    foreach my $c (split(//, $cur_qc)){
		#get unicode value from characters
		my $cur_ord=ord($c);
		#validate the fastq format
		if(($format eq "phred33") && ($cur_ord<33 || $cur_ord>80)){
		    die("$read_file is not a sanger fastq file\n");
		}
		if(($format eq "solexa") && ($cur_ord<59 || $cur_ord>126)){
		    die("$read_file is not a solexa 1.0 fastq file\n");
		}
		if(($format eq "solexa1.3") && ($cur_ord<64 || $cur_ord>110)){
		    die("$read_file is not a solexa 1.3 fastq file\n");
		}		

	        #store base quality score info for each read group
		$cur_seq_qc[$pos-1]+=$cur_ord;			
 
		$pos++;
	    }
	    $seq_group{$cur_seq}{"qc"}=join(";",@cur_seq_qc);
	}
    }
}
close(SEQ);



##output read groups 
my $gp_id=1;
foreach my $sg (keys %seq_group){
    #for fastq format read
    if($stid eq "@"){
        #use group id and the number of read in the group to uniquely define a read group
	print "\@$gp_id\_",$seq_group{$sg}{"ct"},"\n";
	print $sg,"\n";
	print "\+$gp_id\_",$seq_group{$sg}{"ct"},"\n";
	my $cur_seq_len=length($sg);
	my @cur_seq_qc=split(/\;/,$seq_group{$sg}{"qc"});
	foreach my $id (1..$cur_seq_len){
	    #calculate the mean score
	    my $cur_mean_qc=ceil($cur_seq_qc[$id-1]/$seq_group{$sg}{"ct"});
	    print chr($cur_mean_qc);
	}
	print "\n";
	$gp_id++;
    }
    #for fa and csfast reads
    else{
	#use group id and the number of read in the group to uniquely define a read group
	print ">$gp_id\_",$seq_group{$sg}{"ct"},"\n";
	print $sg,"\n";
	$gp_id++;
    }
}



#########
#function to get real quanlity score based on the different fastq format
sub qc_real_sc{
    my ($sc)=@_;
    if($format eq "solexa1.3"){
	$sc-=64;
    }
    elsif($format eq "phred33"){
	$sc-=33;
    }
    else{
	$sc-=64;
	$sc=log(1+10^($sc/10))/log(10);
    }
}


#########
#function to convert solid read to fasta read
sub colorTobase{
    my ($seq)=@_;
    if($seq=~/N|4|\./){
	return("");
    }
    $seq =~ tr/ACGTacgt/01230123/;
    for(my $i=1;$i<length($seq);$i++) {
        substr($seq, $i, 1) = int(substr($seq, $i-1, 1)) ^ int(substr($seq, $i, 1));     
    }
    $seq = substr($seq, 1);
    $seq =~ tr/01234/ACGTN/;
    return($seq);
}
