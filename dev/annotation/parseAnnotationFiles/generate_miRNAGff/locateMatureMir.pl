#!/usr/bin/perl -w
#the script is used to generate miRNA gff3 file for pipeline
#created by Chongjian - 21/07/2011

use strict;

if ($#ARGV != 2) {
    print "usage: perl locateMatureMir.pl mature.fa hairpin.fa orgnism.gff > out.gff\n";
    exit;
}

##get prcursor position

my ($Mfile,$Hfile,$Hgff)=@ARGV;
my  ($release_date,$version);
my %pre_loc;
my $idx=0;
open (HLOC,"$Hgff") || die;
while(<HLOC>){
    if(/\##date\s+(\S+)/){
	$release_date=$1;
}
    if(/version\s+(\d+)/){
	$version=$1;
}
    next if (/^\#/);
    if(/^(\S+).*\s+(\d+)\s+(\d+).*\s+([+-])\s+.*ID\=\"(\S+?)\"/){
	$idx++;
	#attach a unique index to avoid some cases whose precusor has multiple locations in the genome
	my $pre_name=$5 . "_" . $idx;
	$pre_loc{$pre_name}->{"chrm"}=$1;
	$pre_loc{$pre_name}->{"ln"}=$2;
	$pre_loc{$pre_name}->{"rn"}=$3;
	$pre_loc{$pre_name}->{"strand"}=$4;
}
}
close(HLOC);

##get prcursor sequence

my $orgnism_name=$Hgff;
$orgnism_name=~s/\.gff//g;
my $cur_mir="";
my %hairpin_seq;

open (HSEQ,"$Hfile") || die;
while(<HSEQ>){
    $cur_mir="" if (/>/);
    if(/>($orgnism_name\S+)/){
	$cur_mir=$1;
	next;
}
    next if (!$cur_mir);
    if(/(\S+)/){
	my $cur_seq=$1;
	$cur_seq=~s/U/T/g;
	$hairpin_seq{$cur_mir}.=$cur_seq;
}
}
close(HSEQ);


##get mature sequence and match to the responding precursor according to mir name matching
my %mat_map_res;
my %mat_rebundance;
open (MSEQ,"$Mfile") || die;
while(<MSEQ>){
    $cur_mir="" if (/>/);
    if(/>($orgnism_name\S+)/){
	$cur_mir=$1;
	next;
}
    next if (!$cur_mir);
    if(/(\S+)/){
	my $cur_mat_seq=$1;
	$cur_mat_seq=~s/U/T/g;
	my $cur_matseq_gc=GC_per($cur_mat_seq);
	foreach my $id (keys %pre_loc){
	    #get real mir name and do the name-matching
	    my $real_pre_name=$id;
	    $real_pre_name=~s/\_\d+//;
	    my $cur_mir_subname=$cur_mir;
	    $cur_mir_subname=~s/\-3p|\-5p|\*|\.\d//g;
	    next if ($real_pre_name!~/$cur_mir_subname/i);
	    my $cur_hairpin_seq=$hairpin_seq{$real_pre_name};
	    my $cur_hairpin_strand=$pre_loc{$id}->{"strand"};
	    while($cur_hairpin_seq=~/$cur_mat_seq/gi){
		my $pos=length($`);
		#obtain the genomic coordinates of mature mir
		my $cur_mat_ln=$pre_loc{$id}->{"ln"}+$pos;
		my $cur_mat_rn=$pre_loc{$id}->{"ln"}+$pos+length($cur_mat_seq)-1;
		if($cur_hairpin_strand eq "-"){
		    $cur_mat_rn=$pre_loc{$id}->{"rn"}-$pos;
		    $cur_mat_ln=$pre_loc{$id}->{"rn"}-$pos-length($cur_mat_seq)+1;
}
		my $cur_matmir_id=$cur_mir;
		$cur_matmir_id=~s/\-/\./g;
		$cur_matmir_id=~s/\*/star/;
                #assign unique id for each mature mir
		$cur_matmir_id.="." . $mat_rebundance{$cur_mir} if($mat_rebundance{$cur_mir});
		$mat_rebundance{$cur_mir}++;
		#gff format used to sort and output in the following steps
#		my $cur_res="chr" . $pre_loc{$id}->{"chrm"} . "\tmirbase" . $version . "\tmiRNA\t" . $cur_mat_ln . "\t" . $cur_mat_rn . "\t.\t" . $cur_hairpin_strand . "\t.\t" . "Name=" . $cur_mir . ";Precursor=" . $real_pre_name . ";Sequence=" . $cur_mat_seq . ";GC=" . sprintf("%.3f",$cur_matseq_gc) . ";ID=" . $cur_matmir_id . "\n";
		my $cur_res="chr" . $pre_loc{$id}->{"chrm"} . "\tmirbase" . $version . "\tmiRNA\t" . $cur_mat_ln . "\t" . $cur_mat_rn . "\t.\t" . $cur_hairpin_strand . "\t.\t" . "Name=" . $cur_mir . ";Precursor=" . $real_pre_name . ";ID=" . $cur_matmir_id . "\n";
		my $cur_mat_info=$pre_loc{$id}->{"chrm"} . "_" . $cur_mat_ln;
		$mat_map_res{$cur_res}->{"chrm"}=$pre_loc{$id}->{"chrm"};
		$mat_map_res{$cur_res}->{"ln"}=$cur_mat_ln;
		$mat_map_res{$cur_res}->{"rn"}=$cur_mat_rn;
		$mat_map_res{$cur_res}->{"strand"}=$cur_hairpin_strand;
		pos($cur_hairpin_seq)=$pos+1;
}
}
}
}
close(HSEQ);


##output gff3 file

print "## gff-version 3\n";
print "## date: ",$release_date,"\n";
print "## Chromosomal coordinates of mature miRNAs (miRBase v",$version,") in ",$orgnism_name," genome\n";

my ($pre_chrm,$pre_strand,$pre_ln,$pre_rn)=("","",0,0);
foreach my $id (sort { $mat_map_res{$a}->{"chrm"} cmp $mat_map_res{$b}->{"chrm"} || $mat_map_res{$a}->{"ln"} <=> $mat_map_res{$b}->{"ln"} } keys %mat_map_res ){
    ##not print mature mir which are completely inside other mature mir
    next if(($pre_chrm eq $mat_map_res{$id}->{"chrm"}) && ($pre_ln<=$mat_map_res{$id}->{"ln"}) && ($pre_rn>=$mat_map_res{$id}->{"rn"}) && ($pre_strand eq $mat_map_res{$id}->{"strand"}));
    print $id;
    $pre_chrm=$mat_map_res{$id}->{"chrm"};
    $pre_ln=$mat_map_res{$id}->{"ln"};
    $pre_rn=$mat_map_res{$id}->{"rn"};
    $pre_strand=$mat_map_res{$id}->{"strand"};
}


##caluclate the GC content in mature sequence

sub GC_per{
    my ($s)=@_;
    my $gc_ct=0;
    while($s=~/G|C/g){
	$gc_ct++;
}
    my $gc_percent=$gc_ct/length($s);
    return ($gc_percent);
}
