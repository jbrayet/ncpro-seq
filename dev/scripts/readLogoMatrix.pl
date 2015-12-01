###!/usr/bin/perl -w

# Copyleft ↄ⃝ 2012 Institut Curie
# Author(s): Jocelyn Brayet, Laurene Syx, Chongjian Chen, Nicolas Servant(Institut Curie) 2012 - 2015
# Contact: bioinfo.ncproseq@curie.fr
# This software is distributed without any guarantee under the terms of the GNU General
# Public License, either Version 2, June 1991 or Version 3, June 2007.

#The script is used to generate logo matrix for reads in each ncrna family.

use Getopt::Std;
use strict;

## get options from command line
my %opts= ('r'=>'','g'=>'','o'=>'out','p'=>5,'c'=>'','t'=>'1');

sub usage{
print STDERR <<EOF;
    usage:  $0 -r read_fas -g bedfile -o prefix_output -p 5|3  -c all|unique -t 1|0 [-h]

     -h   : help message;
     -r   : fasta fromat file;
     -g   : bed file to get read name;
     -o   : the prefix of output file name;
     -p   : the direction to compute the matrix, 5'->3'(5) or 3'->5'(3), default is 5 ;
     -c   : reads used to calculate logo matrix. all: all reads in the family; unique: only the most expressed reads from both directions in each family member;
     -t   : group_read option from config-ncrna.txt. 1: yes; 0: no;

EOF
    exit;
}

getopts('r:g:o:p:c:t:h', \%opts) || usage();
usage() if ($opts{h});

my ($bed_file,$read_file,$prefix,$direction,$use_allread,$group_read)=($opts{g},$opts{r},$opts{o},$opts{p},$opts{c},$opts{t});

my %select_reads;
if($use_allread eq "unique"){
    my %ann_item_read;
    #get read number based on the mapped coordinate which is only useful if group_read is not activated.
    my %location_ct; 
    if(!$group_read){
	open(BDA,"bed_file") || die;
	while(<BDA>){
	    if(/^\S+\s+(\d+)\s+(\d+)\s+\S+\_\d+\s+\d+\s+([+-])(.*\s+[+-]\s+.*)/){
		my ($read_ln,$read_rn,$read_strand,$ann_item)=($1,$2,$3,$4);
		my $cur_name=$ann_item . "_" . $read_ln . "_" . $read_rn . "_" . $read_strand;
		$location_ct{$cur_name}++;
}
}
	close(BDA);
}
    open (BD,"$bed_file") || warn "can't open $bed_file";
    while(<BD>){
	if(/^\S+\s+(\d+)\s+(\d+)\s+(\S+\_(\d+))\s+(\d+)\s+([+-])(.*\s+([+-])\s+.*)/){
	    my ($read_ln,$read_rn,$rname,$read_num,$mapping_num,$rstrand,$ann_item,$ncstrand)=($1,$2,$3,$4,$5,$6,$7,$8);
	    my $cur_direction="+";
	    my $cur_readexp=$read_num/$mapping_num;
	    my $cur_name=$ann_item . "_" . $read_ln . "_" . $read_rn . "_" . $rstrand;
	    $cur_readexp*=$location_ct{$cur_name} if (!$group_read);
	    if($rstrand ne $ncstrand){
		$cur_direction="-";
}
	    if((!$ann_item_read{$ann_item}{$cur_direction}) || ($ann_item_read{$ann_item}{$cur_direction}{"readexp"}<$cur_readexp)){
		$ann_item_read{$ann_item}{$cur_direction}{"read"}=$rname;
		$ann_item_read{$ann_item}{$cur_direction}{"readexp"}=$cur_readexp;
}
}
}
    close(BD);
    foreach my $item (keys %ann_item_read){
	for my $plus_minus ("+","-"){
	    if($ann_item_read{$item}{$plus_minus}){
		my $cur_read_name=$ann_item_read{$item}{$plus_minus}{"read"};
		$select_reads{$cur_read_name}=1;
}
}
}
}

## get read information from intersectBed bed format result (-wa -wb -bed)
my %read_name;
open (BED,"$bed_file") || warn "can't open $bed_file"; 
while(<BED>){
    if(/^(\S+)\s+(\d+)\s+\d+\s+(\S+)\s+\d+\s+([+-]).*\s+([+-])\s+/){
	my ($chrm,$ln,$rname,$rstrand,$ncstrand)=($1,$2+1,$3,$4,$5);
	next if (($use_allread eq "unique") && (!$select_reads{$rname}));
	$read_name{$rname}->{"rstrand"}=$rstrand;
        ## record the strand info of read in ncrna
	if($rstrand eq $ncstrand){
	    $read_name{$rname}->{"sense"}=1
}
	else{
	    $read_name{$rname}->{"sense"}=0
}
}
}
close(BED);

## compute base matrix for sense, antisense and all mapped reads
my %seq_dup; #to make sure only use one sequence from read group to compute matrix
my $max_sense_len=0;
my $max_anti_len=0;
my %sense_base_ct;
my %anti_base_ct;
my $sense_read_ct=0;
my $anti_read_ct=0;
my $seq_name="";
open (SEQ,"$read_file") || die;
while(<SEQ>){
    if(/>(\S+)/){
	$seq_name=$1;
	next;
}
    if(/(\S+)/){
	my $cur_seq=$1;
	next if ((!$read_name{$seq_name}->{"rstrand"}) || ($seq_dup{$cur_seq}));
	$seq_dup{$cur_seq}=1; #mark the sequence that has been processed
#	## get real sequence for read which is mapped in the antisense genomic region
#	if($read_name{$seq_name}->{"rstrand"} eq "-"){
#	    $cur_seq=revcompl($cur_seq);
#}
	## reverse read to comput matrix starting from 3' end
	$cur_seq=reverse($cur_seq) if ($direction==3);
	my $cur_readlen=length($cur_seq);
	if($read_name{$seq_name}->{"sense"}){
	    sense_base_count($cur_seq);
	    $max_sense_len=$cur_readlen if ($max_sense_len<$cur_readlen);
	    $sense_read_ct++;
}
	else{
	    anti_base_count($cur_seq);
	    $max_anti_len=$cur_readlen if ($max_anti_len<$cur_readlen);
	    $anti_read_ct++;
}
}
}
close(SEQ);

my $max_len=$max_sense_len>$max_anti_len ? $max_sense_len : $max_anti_len;

## output three matrices
if($max_len>0){
    print_matrix($max_len,"sense",$sense_read_ct);
    print_matrix($max_len,"anti",$anti_read_ct);
    print_matrix($max_len,"all",$sense_read_ct+$anti_read_ct);
}

####

## function used to output base matrix
sub print_matrix{
    my ($len,$type,$read_ct)=@_;
    open(OUT,">$prefix\_logomatrix_$type\_$use_allread.data");
    foreach my $j (1..$len){
	print OUT "\t",$j;
}
    print OUT "\n";
    my @bases=("A","C","G","T");
    my @base_total_reads=0;
    foreach my $i (0..$#bases){
	my $cur_base=$bases[$i];
	print OUT $cur_base;
	foreach my $j (1..$len){
	    if($type eq "sense"){
		$sense_base_ct{$j}->{$cur_base}=0 if (!$sense_base_ct{$j}->{$cur_base});
		print OUT "\t",$sense_base_ct{$j}->{$cur_base};
		$base_total_reads[$j-1]+=$sense_base_ct{$j}->{$cur_base};
}
	    elsif($type eq "anti"){
		$anti_base_ct{$j}->{$cur_base}=0 if (!$anti_base_ct{$j}->{$cur_base});
		print OUT "\t",$anti_base_ct{$j}->{$cur_base};
		$base_total_reads[$j-1]+=$anti_base_ct{$j}->{$cur_base};
}
	    else{
		$anti_base_ct{$j}->{$cur_base}=0 if (!$anti_base_ct{$j}->{$cur_base});
		$sense_base_ct{$j}->{$cur_base}=0 if (!$sense_base_ct{$j}->{$cur_base});
		print OUT "\t",$sense_base_ct{$j}->{$cur_base}+$anti_base_ct{$j}->{$cur_base};
		$base_total_reads[$j-1]+=$sense_base_ct{$j}->{$cur_base}+$anti_base_ct{$j}->{$cur_base};
}
}
	print OUT "\n";
}
    print OUT "N";
    foreach my $i (0..$#base_total_reads){
	print OUT "\t",$read_ct-$base_total_reads[$i];
}
    print OUT "\n";
    close(OUT);
}

## return reverse complementary sequence
sub revcompl{
    my ($s)=@_;
    $s=reverse($s);
    $s=~ tr/ACGTacgt/TGCAtgca/;
    return $s;
}

## get base count for reads mapped in the sense direction 
sub sense_base_count{
    my ($s)=@_;
    my @arr=split(//,$s);
    foreach my $i (0..$#arr){
	my $cur_char=$arr[$i];
	$sense_base_ct{$i+1}->{$cur_char}=0 if (!$sense_base_ct{$i+1}->{$cur_char});
	$sense_base_ct{$i+1}->{$cur_char}++;
}
}

## get base count for reads mapped in the antisense direction
sub anti_base_count{
    my ($s)=@_;
    my @arr=split(//,$s);
    foreach my $i (0..$#arr){
	my $cur_char=$arr[$i];
	$anti_base_ct{$i+1}->{$cur_char}=0 if (!$anti_base_ct{$i+1}->{$cur_char});
	$anti_base_ct{$i+1}->{$cur_char}++;
}
}
