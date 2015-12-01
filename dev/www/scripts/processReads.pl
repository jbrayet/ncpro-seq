###!/usr/bin/perl -w

# Copyleft ↄ⃝ 2012 Institut Curie
# Author(s): Jocelyn Brayet, Laurene Syx, Chongjian Chen, Nicolas Servant(Institut Curie) 2012 - 2015
# Contact: bioinfo.ncproseq@curie.fr
# This software is distributed without any guarantee under the terms of the GNU General
# Public License, either Version 2, June 1991 or Version 3, June 2007.

#The script is used to check the input format, calcualte read length distribution, compute mean quality score of each base
#if -g is specified with 1, group reads which have the same sequence in raw sequencing data. For fastq reads, the mean quality score is computed in each read group.
#if -g is specified with 0, just output original sequence with extended read name with "_1" suffix in order to have the same name format as group read.
#if -g is specified with 2, just output original sequence .

use Getopt::Std;
use utf8;
use strict;
use POSIX;

## get options from command line
my %opts= ('i'=>'','f'=>'','g'=>'','D'=>'','d'=>'');

sub usage{
print STDERR <<EOF;
    usage:  $0 -i read_file -f format -g 2|1|0 -D seq_dir -d data_dir [-h]

     -h   : help message;
     -i   : input read file;
     -f   : format of read file, could be specified as "fa","csfast", "solexa", "solexa1.3", and "phred33";
     -g   : group read or not, 1: yes; 0: no, add "_1" suffix; 2: no, output original sequence;
     -D   : the raw sequence directory;
     -d   : the data directory;

    example1: $0 -i file -f "phred33" -g 1 -D "rawdata" -d "data"
    example2: $0 -i file -f "fa" -g 1 -D "rawdata" -d "data"
    example3: $0 -i file -f "csfast" -g 1 -D "rawdata" -d "data"

EOF
    exit;
}

getopts('i:f:g:D:d:h', \%opts) || usage();
usage() if ($opts{h});

my ($read_file,$format,$do_group,$seq_dir,$data_dir)=($opts{i},$opts{f},$opts{g},$opts{D},$opts{d});

##specify start identifier of read (> or @) in sequence file
my $stid=">";
if($format!~/fa/){
    $stid="@";
}

my ($max_len,$cur_seq,$cur_qc)=(0,"","");
my %seq_len=(); # hash of sequence length
my %seq_group=(); # hash of read group 
my %seq_qc=(); # hash of quality score
my %seq_base=(); # hash of read base 
my $default_seq_copy=1; #number of sequence obtained in the library which has already noted in the name of sequence, $do_group=2
my $input_nb=0; #group=2 sum up the copy number to check weither the sequence are grouped or not

open (SEQ,"$seq_dir/$read_file") || warn "can't open $read_file";
open (GROUPOUT,">$seq_dir/$read_file.pmod"); #modified read file after processing
while(<SEQ>){
    if(/^$stid(\S+)/){
	my $cur_header=$1;
	$cur_seq=<SEQ>;
	chomp($cur_seq);
	my $cur_seq_len=length($cur_seq);
	if($do_group==2){
	    my @tmp_arr=split(/\_/,$cur_header);
	    $default_seq_copy=$tmp_arr[-1];
	    $input_nb++;
	    die "Sequence Copy Number not found" if $#tmp_arr <1;
	    die "Unexpected Sequence Copy Number\nAre you sure that your data are processed ?" if $default_seq_copy <1;
	}
        ##validate the fasta/csfast format
	if($format eq "fasta"){
	    if($cur_seq!~/[ATGCNatgcN]{$cur_seq_len,}/){
		`rm -f $seq_dir/$read_file.group`;
		die("$seq_dir/$read_file is not a fasta file\n");
	    }
            #output read without grouping
	    if($do_group==0){
		print GROUPOUT ">",$cur_header,"_1\n",$cur_seq,"\n";
	    }
	    elsif($do_group==2){
		print GROUPOUT ">",$cur_header,"\n",$cur_seq,"\n";
	    }
	}
	if($format eq "csfasta"){
	    my $len_nonuc=$cur_seq_len-1;
	    ##Remove the first tag from the sequence length
	    $cur_seq_len=$cur_seq_len-1;
	    if($cur_seq!~/[ATGCatgc][01234\.]{$len_nonuc,}/){
		`rm -f $seq_dir/$read_file.group`;
		die("$seq_dir/$read_file is not a csfasta file\n");
	    }
            #output read without grouping
	    if(!$do_group){
		print GROUPOUT ">",$cur_header,"_1\n",$cur_seq,"\n";
	    }
	    elsif($do_group==2){
		print GROUPOUT ">",$cur_header,"\n",$cur_seq,"\n";
	    }
	}
	#get length info
	$max_len=$cur_seq_len if ($cur_seq_len>$max_len);
	$seq_len{$cur_seq_len}+=$default_seq_copy;
	#get read group (distinct read) information
	$seq_group{$cur_seq}{"ct"}++;
	my $nuc_pos=1;
	if($format eq "csfasta"){
	    $cur_seq=colorTobase($cur_seq);
	}
	if($cur_seq){
	    foreach my $c (split(//,$cur_seq)){
		$seq_base{$nuc_pos}{$c}+=$default_seq_copy;
		$nuc_pos++;
	    }
	}
	#process fastq reads
	if($stid eq "@"){
	    my $mid_line=<SEQ>;
            #validate the fastq format
	    if($mid_line!~/^\+/){
		`rm -f $seq_dir/$read_file.group`;
		die("$seq_dir/$read_file is not a fastq file\n");
	    }
	    $cur_qc=<SEQ>;
	    #output read without grouping
	    if($do_group==0){
		print GROUPOUT "@",$cur_header,"_1\n",$cur_seq,"\n","+",$cur_header,"_1\n",$cur_qc;
	    }
	    elsif($do_group==2){
		print GROUPOUT "@",$cur_header,"\n",$cur_seq,"\n","+",$cur_header,"\n",$cur_qc;
	    }
	    chomp($cur_qc);
	    my $pos=1;
	    my @cur_seq_qc=0;
	    @cur_seq_qc=split(/\;/,$seq_group{$cur_seq}{"qc"}) if ($seq_group{$cur_seq}{"qc"});
	    foreach my $c (split(//, $cur_qc)){
		#get unicode value from characters
		my $cur_ord=ord($c);
		#validate the fastq format
		if(($format eq "phred33") && ($cur_ord<33 || $cur_ord>80)){
		    `rm -f $seq_dir/$read_file.group`;
		    die("$seq_dir/$read_file is not a sanger fastq file\n");
		}
		if(($format eq "solexa") && ($cur_ord<59 || $cur_ord>126)){
		    `rm -f $seq_dir/$read_file.group`;
		    die("$seq_dir/$read_file is not a solexa 1.0 fastq file\n");
		}
		if(($format eq "solexa1.3") && ($cur_ord<64 || $cur_ord>110)){
#		    warn $cur_ord,"\n";
		    `rm -f $seq_dir/$read_file.group`;
		    die("$seq_dir/$read_file is not a solexa 1.3 fastq file\n");
		}		
		if($do_group==1){
		    #store base quality score info for each read group, if $do_group is active (=1)
		    $cur_seq_qc[$pos-1]+=$cur_ord;
		}		
                #store unicode value of positional quality score for all reads
		$seq_qc{$pos}{"sc"}+=$cur_ord*$default_seq_copy;
		$seq_qc{$pos}{"ct"}+=$default_seq_copy;
		$pos++;
	    }
	    $seq_group{$cur_seq}{"qc"}=join(";",@cur_seq_qc);
	}
    }
}
close(SEQ);

## check wether the sequence are grouped or not
if($do_group==2){
    die "Reads sequences are not grouped" if keys %seq_group != $input_nb;
}

##get sample name
my $sample="";
if($read_file=~/(\S+)\./){
    $sample=$1;
}

##output length distribution of abundant reads
open (LENOUT,">$data_dir/$sample\_readlen.data");
print LENOUT "idx\t$sample\n";
foreach my $len (sort {$a <=> $b} keys %seq_len){
    print LENOUT $len,"\t",$seq_len{$len},"\n";
}
close(LENOUT);

##output read base composition 
open (BASE,">$data_dir/$sample\_basestat.data");
open (GC,">$data_dir/$sample\_baseGCstat.data");
print BASE "idx\tA\tT\tG\tC\tN\n";
print GC "idx\t$sample\n";
foreach my $pos (1..$max_len){
    $seq_base{$pos}{"A"}=0 if (!$seq_base{$pos}{"A"});
    $seq_base{$pos}{"T"}=0 if (!$seq_base{$pos}{"T"});
    $seq_base{$pos}{"G"}=0 if (!$seq_base{$pos}{"G"});
    $seq_base{$pos}{"C"}=0 if (!$seq_base{$pos}{"C"});
    $seq_base{$pos}{"N"}=0 if (!$seq_base{$pos}{"N"});
    my $cur_basect=$seq_base{$pos}{"A"}+$seq_base{$pos}{"T"}+$seq_base{$pos}{"G"}+$seq_base{$pos}{"C"}+$seq_base{$pos}{"N"};
    my $cur_gcct=$seq_base{$pos}{"G"}+$seq_base{$pos}{"C"};
    print BASE $pos,"\t",100*$seq_base{$pos}{"A"}/$cur_basect,"\t",100*$seq_base{$pos}{"T"}/$cur_basect,"\t",100*$seq_base{$pos}{"G"}/$cur_basect,"\t",100*$seq_base{$pos}{"C"}/$cur_basect,"\t",100*$seq_base{$pos}{"N"}/$cur_basect,"\n";
    print GC $pos,"\t",100*$cur_gcct/$cur_basect,"\n";
}
close(BASE);
close(GC);

##output length distribution of distinct reads
open (DISTLENOUT,">$data_dir/$sample\_distinct_readlen.data");
print DISTLENOUT "idx\t$sample\n";
my %distinct_len;
foreach my $cur_read (keys %seq_group){
    my $cur_len=length($cur_read);
    $distinct_len{$cur_len}++;
}
foreach my $len  (sort {$a <=> $b} keys %distinct_len){
    print DISTLENOUT $len,"\t",$distinct_len{$len},"\n";
}
close(DISTLENOUT);


##output read groups  if $do_group is active
if($do_group==1){
    my $gp_id=1;
    foreach my $sg (keys %seq_group){
        #for fastq format read
	if($stid eq "@"){
	    #use group id and the number of read in the group to uniquely define a read group
	    print GROUPOUT "\@$gp_id\_",$seq_group{$sg}{"ct"},"\n";
	    print GROUPOUT $sg,"\n";
	    print GROUPOUT "\+$gp_id\_",$seq_group{$sg}{"ct"},"\n";
	    my $cur_seq_len=length($sg);
	    my @cur_seq_qc=split(/\;/,$seq_group{$sg}{"qc"});
	    foreach my $id (1..$cur_seq_len){
		#calculate the mean score
		my $cur_mean_qc=ceil($cur_seq_qc[$id-1]/$seq_group{$sg}{"ct"});
		print GROUPOUT chr($cur_mean_qc);
	    }
	    print GROUPOUT "\n";
	    $gp_id++;
	}
        #for fa and csfast reads
	else{ 
	    #use group id and the number of read in the group to uniquely define a read group
	    print GROUPOUT ">$gp_id\_",$seq_group{$sg}{"ct"},"\n";
	    print GROUPOUT $sg,"\n";
	    $gp_id++;
	}
    }
}
close(GROUPOUT);

#output mean quality score for each position in all fastq reads
if($stid eq "@"){
    open(QCOUT,">$data_dir/$sample\_meanquality.data");
    print QCOUT "idx\t$sample\n";
    foreach my $pos (1..$max_len){
	#calculate the mean score
	my $pos_meansc=ceil($seq_qc{$pos}{"sc"}/$seq_qc{$pos}{"ct"});
	$pos_meansc=qc_real_sc($pos_meansc);
	print QCOUT $pos,"\t",$pos_meansc,"\n";
}
    close(QCOUT);
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
