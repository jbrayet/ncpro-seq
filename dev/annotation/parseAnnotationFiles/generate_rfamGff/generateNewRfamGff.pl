#!/usr/bin/perl -w
#created by Chongjian CHEN- 19/10/2011

#The script is used to easily generate a new rfam annotation gff3 files for the new genome version.

use Getopt::Std;
use strict;

## get options from command line
my %opts= ('f'=>'genome_entry.txt','k'=>'','d'=>'genome.gff3','g'=>'','G'=>'','e'=>'0.00001','o'=>'');

sub usage{
print STDERR <<EOF;
    usage:  $0 -f entry_file -k keyword -d dir -g genome_seq_used_in_rfam  -G the_new_genome_sequence -e 0.00001 -o resGFF [-h]

     -h   : help message;
     -f   : file extracted from genome_entry.txt.gz from Rfam database;
     -k   : the key word to uniquely represent the species;
     -d   : directory extracted from genome.gff3.tar.gz from Rfam database;
     -g   : the whole genome sequence file used in rfam database;
     -G   : the whole genome sequence of new genome version;
     -e   : blast e value cutoff;
     -o   : output gff file;

EOF
    exit;
}

getopts('f:k:d:g:G:e:o:h', \%opts) || usage();
usage() if ($opts{h});

my ($gentry_file,$keyword,$gff_dir,$gfile_rfam,$gfile_new,$evalue,$output_gff)=($opts{f},$opts{k},$opts{d},$opts{g},$opts{G},$opts{e},$opts{o});

my $rfam_seqfile="rfam.seq.fas";

## keyword check
if(!$keyword){
    warn "Please specify the keyword to define one species\n";
    usage();
}

##get accession number based on the keyword
my %accession=();
open(ENTRY,"$gentry_file") || die("can't find $gentry_file file\n");
while(<ENTRY>){
    if(/^\d+\s+(\S+)\s+.*$keyword/){
	$accession{$1}=1;
}
}
close(ENTRY);

##check the existance of the genome sequence file used in rfam
if(!$gfile_rfam){
    warn "Please download genome sequences (fasta) from NCBI using the following accession number and combine them into a single file as input to this script:\n";
    warn join("\n",keys %accession),"\nAnd run again this script according to the usage below\n------------\n";
    usage();
}

##store genome sequence to a hash
my %rfam_genome_seq=();
my $cur_name="";

open (GSEQ,"$gfile_rfam") || die("can't find $gfile_rfam file\n");
while(<GSEQ>){
    if(/>gi\|\d+\|\S+?\|(\S+?)\|/){
	$cur_name=$1;
	next;
}
    if(/(\S+)/){
	$rfam_genome_seq{$cur_name}.=$1;
}
}
close(GSEQ);

my %seq_abundant;
##for each accession id, find its corresponding gff3 file and extract sequences
unless(-e $rfam_seqfile){
    open(SEQOUT,">$rfam_seqfile");
    foreach my $id (keys %accession){
	open(GFF,"$gff_dir/$id.gff3") || die("can't find $gff_dir/$id.gff3");
	warn $id,"\n";
	while(<GFF>){
	    next if (/^\#/);
	    if(/^(\S+)\s+\S+\s+\S+\s+(\d+)\s+(\d+)\s+\S+\s+([+-])\s+\S+\s+ID\=(\S+?)\.\d+\;Name\=\S+?\;Alias\=(\S+?)\;Note\=(\S+)/){
		my ($cur_ref,$cur_ln,$cur_rn,$cur_strand,$cur_id,$cur_alias,$cur_note)=($1,$2,$3,$4,$5,$6,$7);
		my $substr_len=($cur_rn-$cur_ln+1)<1024 ? ($cur_rn-$cur_ln+1) : 1024;
		my $cur_seq=substr($rfam_genome_seq{$cur_ref},$cur_ln-1,$substr_len);
		warn $_ if (!$cur_seq);
		$cur_seq=revcompl($cur_seq) if($cur_strand eq "-");
		next if ($seq_abundant{$cur_seq});
		$seq_abundant{$cur_seq}=1;
		print SEQOUT ">$cur_id;$cur_alias;$cur_ref-$cur_ln-$cur_note\n",$cur_seq,"\n";
}
}
	close(GFF);
}
    close(SEQOUT);
}


##check the existance of the new genome sequence file
if(!$gfile_new){
    warn "Please specify the new genome sequence file\n";
    usage();
}

##formatdb new genome sequence file, and use blast to search rfam sequence to this database
my $db_name="";
if($gfile_new=~/(\S+)\./){
    $db_name=$1;
}

##make tmp directory
unless(-d "./tmp/"){
    system("mkdir tmp");
}

my $formatdb="bowtie-build $gfile_new $db_name";
my $bowtiecmd="bowtie -v 0 -a -m 1000000 --best --strata --nomaqround -f -y --sam $db_name $rfam_seqfile ./tmp/$rfam_seqfile.sam";

system($formatdb);
system($bowtiecmd) and die "FATAL: failed to run blast [$bowtiecmd]\n";

open (SAM,"./tmp/$rfam_seqfile.sam") || die;
open (OUT,">./tmp/$rfam_seqfile.tabout");
while(<SAM>){
    next if (/\@/);
    if(/(\S+)\s+(\d+)\s+(\S+)\s+(\d+)\s+\d+\s+\S+\s+\S+\s+\d+\s+\d+\s+(\S+)/){
	my ($read,$flag,$chrm,$gln,$seq)=($1,$2,$3,$4,$5);
	next if ($flag==4);
	my $grn=$gln+length($seq)-1;
	my ($rln,$rrn)=(1,length($seq));
	($rrn,$rln)=($rln,$rrn) if ($flag==16);
	print OUT $chrm,"\t",$read,"\t100.00\t",length($seq),"\t0\t0\t",$gln,"\t",$grn,"\t",$rln,"\t",$rrn,"\t1e-30\t",2*length($seq),"\n";
}
}
close(SAM);
close(OUT);


##run rfam_scan.pl to identify real annotions
system("./rfam_scan.pl -blaout ./tmp/$rfam_seqfile.tabout -o $output_gff ./Rfam.cm $gfile_new");

##################
## return reverse complementary sequence
sub revcompl{
    my ($s)=@_;
    $s=reverse($s);
    $s=~ tr/ACGTacgt/TGCAtgca/;
    return $s;
}

