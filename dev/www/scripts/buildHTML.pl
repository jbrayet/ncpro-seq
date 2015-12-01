#!/usr/bin/perl -w

# Copyleft ↄ⃝ 2012 Institut Curie
# Author(s): Jocelyn Brayet, Laurene Syx, Chongjian Chen, Nicolas Servant(Institut Curie) 2012 - 2015
# Contact: bioinfo.ncproseq@curie.fr
# This software is distributed without any guarantee under the terms of the GNU General
# Public License, either Version 2, June 1991 or Version 3, June 2007.

## This script is used to generatea HTML report of the ncRNA pipeline

use strict;
use File::Basename;
use Getopt::Std;
use POSIX qw(strftime);
use Cwd 'abs_path';
use Data::Dumper;

sub displayTableView{
    my ($form_id, $tab_id);
    $form_id = shift;
    $tab_id = shift;
    my $filesref=shift;
    my @files = @$filesref;
    
    print "<div class='divprof'><center>Table View</center></div>";
    print "<p class='intro'>All files used to create the presented figures are available for visualization/download. Please select the file you want to visualize/download.</p>";
    print "<form id=\"".$form_id."\">\n";
    print "<select name=\"csvfile\" size=\"1\">\n";
    foreach my $tablefile (@files){
	print "<option value=\"$tablefile\">".basename($tablefile)."\n";
    }
    print "</select>\n";
    print "<input class=\"btn1\" type=\"button\" onclick = \"document.getElementById('loading').style.display='block';showTable(document.getElementById('".$form_id."').csvfile.value, '".$tab_id."');\"  value=\"View File\">\n";
    print "<input class=\"btn1\" type=\"button\" onclick = \"download(document.getElementById('".$form_id."').csvfile.value);\"  value=\"Download File\">\n";
    print "</form><br>\n";
    print "<div id=\"loading\" style=\" width:100%; display:none;\">Now loading ...</div>\n";
    print "<table id=\"".$tab_id."\"></table>\n";
}


sub usage{
print STDERR <<EOF;
  usage:  $0 -n ncRNAs_list -l logfile -c configfile -g bowtie_genome_reference -s bowtie_genome_reference_color [-h]
      -h   : help message;
      -n   : text file with all the precessed ncRNAs
      -c   : configuration file
      -l   : log file
#      -g   : Bowtie reference genome as specified in the config-ncrna.txt file
#      -s   : Bowtie color space reference genome as specified in the config-ncrna.txt file
EOF
    exit;
}

## get options from command line
my %opts;
getopts('n:l:c:h', \%opts) || usage();
usage() if ($opts{h});


my ($ncrna, $config_file, $log_file)=($opts{n}, $opts{c}, $opts{l});

my %dir;
open IN, $config_file or die $!;
    while(<IN>){
    next unless /(\S+) = (\S+)/;
    $dir{$1}=$2;
}
close IN;

print Dumper(\%dir);

my $thisdir = dirname($0);##dirname($ENV{'SCRIPT_FILENAME'} || $ENV{'PATH_TRANSLATED'} || $0); ##SCRIPT_FILENAME=cgi_bin
my $rawdata_dir=$dir{RAW_DIR};
my $pic_dir=$dir{PIC_DIR};
my $thumb_dir="html/thumb";
my $ucsc_dir=$dir{UCSC_DIR};
my $html_dir=$dir{HTML_DIR};
my $annot_dir=$dir{ANNOT_DIR};
my $doc_dir=$dir{DOC_DIR};
my (@RAW_FILES,@PIC_FILES, @ALL_NCRNA, @DOC_FILES, @TAB_FILES);

#####################################################
## LOAD DATA - READ FILES AND FOLDERS
#####################################################

opendir(RAWDIR, $rawdata_dir) || die "can't opendir: $!"; 
while (my $file = readdir(RAWDIR)) {
        ##next if ($file =~ m/.group$/ || $file=~ m/^\./ || $file=~m/\.pmod$/);
        next if (! ($file =~ m/.fastq$/ || $file=~ m/\.csfasta$/ || $file=~m/\.fas$/ || $file=~m/\.fa$/ || $file=~m/\.bam$/));
	##my ( $name, $path, $suffix ) = fileparse( $file, qr/\.[^.]*/ );
	##push(@RAW_FILES, $name);
	push(@RAW_FILES, $file);
}
close RAWDIR;
@RAW_FILES=sort(@RAW_FILES);

opendir(PICDIR, $pic_dir) || die "can't opendir: $!"; 
while (my $file = readdir(PICDIR)) {
    next if ($file=~ m/^\./);
	push(@PIC_FILES, $file);
}
close PICDIR;
@PIC_FILES=sort(@PIC_FILES);

opendir(TABLEDIR, $doc_dir) || die "can't opendir: $!"; 
while (my $file = readdir(TABLEDIR)) {
    next if ($file=~ m/^\./); ##|| $file!~ m/^all_samples/);
    push(@DOC_FILES, $file);
}
close TABLEDIR;
@DOC_FILES=sort(@DOC_FILES);


open NCRNA,"<$ncrna" or die $!;
while (my $line = <NCRNA>) {
    chomp($line);
    next if($line=~/^$/);
    push(@ALL_NCRNA,$line);
}
close NCRNA;

#####################################################
## OPTIONAL TAB
#####################################################

my $runSIG=0;
for (my $i=0; $i<=$#PIC_FILES; $i++){
    if ($PIC_FILES[$i] =~ m/plotReadModelFit.png$/){
	$runSIG=1;
    }
}

my $runUCSCTrack=0;
opendir DIR, $ucsc_dir;
if(scalar(grep( !/^\.\.?$/, readdir(DIR))) != 0){
    $runUCSCTrack=1;
} 

#####################################################
## HTML header
#####################################################

open HEADER,"<$html_dir/header.html" or die $!;
while (my $line = <HEADER>) {
    print $line;
}
close HEADER;


print "<div id='container' style=\"background-color: #FFFFFF\">";
print "<div id='top' align='center'>";
print "<table border=0 width=100%><tr>";
print "<td widht=200px align='left'><a style='color:white' href='http://ncproseq.sourceforge.net/'><img src='html/images/ncPRO_logo.png'></a></td>";
print "<td align='center'><font size=4><b>Annotation and Profiling of ncRNAs from smallRNA-seq<br></b>Analysis Report</font></td>";
print "<td widht=200px align='right'><img src='html/images/IC.gif'</td>";
print "</tr></table></div>";


print "<div id='tabs'>";
print "<ul>";
print "<li><a href='#tabs-1'>Home</a></li>";
print "<li><a href='#tabs-2'>Quality Control</a></li>";
print "<li><a href='#tabs-3'>Data Mapping</a></li>";
print "<li><a href='#tabs-4'>ncRNAs Overview</a></li>";
my $nbtab=5;
for (my $i=0; $i<=$#ALL_NCRNA; $i++){
    my ($iest, $ncrna_name, $par);
    my @valname=split("_",$ALL_NCRNA[$i]);
    foreach my $val (@valname){
	if ($val =~ m/^[iest]$/){
	    $iest=$val;
	}elsif ($val =~ m/[\+\-][0-9]+/){
	    if ($par){
		$par=join(";",$par,$val);
	    }else{
	    	$par=$val;
	    }
	}else{
	    if ($ncrna_name){
		$ncrna_name=join(" ",$ncrna_name,$val);
	    }else{
		$ncrna_name=$val;
	    }
	}
    }
    $ncrna_name=~s/miRNA miRNA/miRNA/g;
    $ncrna_name=~s/tRNA tRNA/tRNA/g;
    $ncrna_name=~s/rmsk/Repeats/g;
    if ($par){
	print ("<li><a href=\"#tabs-$nbtab\">".ucfirst($ncrna_name)." [$par]</a></li>");
    }else{
	print ("<li><a href=\"#tabs-$nbtab\">".ucfirst($ncrna_name)."</a></li>");
    }
    $nbtab++;
}
if ($runSIG == 1){
    print "<li><a href=\"#tabs-sig\">Enriched Regions</a></li>";
    $nbtab++;
}
print "<li><a href=\"#tableview\">Table view</a></li>";
my $tabletab=$nbtab-1;
$nbtab++;
if ($runUCSCTrack == 1){
    print "<li><a href=\"#tracks\">UCSC Tracks</a></li>";
    $nbtab++;
}
print "<li><a href=\"#logs\">Logs</a></li>";
$nbtab++;
print "<li><a href=\"#manual\">Help</a></li>";

print "</ul>";

   

#####################################################
## TAB1 - HOME
#####################################################

my @back=`$thisdir/../bin/ncPRO-seq -v`;
my $date = strftime "%d-%b-%Y %H:%M", localtime;
print "<div class=\"content\" id=\"tabs-1\"><h3>$back[0]</h3>$date<br><p class='intro'><b>List of samples</b></p>";
print "<ul>";
for (my $i=0; $i<=$#RAW_FILES; $i++){
    print ("<li><em>$RAW_FILES[$i]</em></li>");
}
print "</ul><p class='intro'><b>Options used to perform the analysis</b></p><ul class='param'>";

open CONFIG,"<$config_file" or die $!;
while (my $line = <CONFIG>) {
    chomp($line);
    next if ($line =~ m/^\#/ || $line =~ m/^$/ || $line =~ m/=( )*$/);
    my @values=split('=',$line);
    $values[0]=~s/ $//;
    $values[1]=~s/^ //;
    if ($values[0] eq "ORGANISM"){
	$annot_dir=$annot_dir."/".$values[1];
    }
    print "<li>$values[0]<span>$values[1]</span></li>";
}
close CONFIG;

my $annotversion_file=$annot_dir."/annotation.version";

if (-e $annotversion_file) {
    print "</ul><p class='intro'><b>Annotation files version</b></p><ul class='param'>";
    open ANNOT,"<$annotversion_file" or die $!;
    while (my $line = <ANNOT>) {
	chomp($line);
	next if ($line =~ m/^\#/ || $line =~ m/^$/ || $line =~ m/=( )*$/);
	my @values=split('\t',$line);
	print "<li>$values[0]<span>$values[1]</span></li>";
    }
    close ANNOT;
}
print "</div>\n";

#####################################################
## TAB2 - QUALITY CONTROL
#####################################################

print "<div class=\"content\" id=\"tabs-2\"><h3>Raw Data Quality Control</h3>\n";
print "<div class=\"gallery\" id=\"gallery3\">";
my $plotbase=0;
for (my $i=0; $i<=$#PIC_FILES; $i++){
    if ($PIC_FILES[$i] =~ m/Base/){
	if ($plotbase==0){
	    print "<p class='intro'><b>Base Composition Information</b>The base compostion (A,T,G,C) at each position of the read in each library is represented.<br>Normally, all base frequencies at each position should approximate 25%.</p>";
	    $plotbase=1;
	}
	print "<table border=0 align='left'><tr><td><a class=\"lb\" href=\"$pic_dir/$PIC_FILES[$i]\" title=\"$PIC_FILES[$i]\"><img src=\"$thumb_dir/$PIC_FILES[$i]\"></a></td></tr>";
	if ($PIC_FILES[$i] =~ m/BaseGC/){
	    print "<tr><td><a href='$pic_dir/$PIC_FILES[$i]' target='_blank'>Click to Download</a> / <a href='#' onclick=\"showTableLink($tabletab, 'doc/all_samples_read_basegc.data')\">View Data Table</a></td></tr></table>";
	}else{
	    print "<tr><td><a href='$pic_dir/$PIC_FILES[$i]' target='_blank'>Click to Download</a></td></tr></table>";
	}
    }
}

for (my $i=0; $i<=$#PIC_FILES; $i++){
    if ($PIC_FILES[$i] =~ m/ReadSize/ && $PIC_FILES[$i] !~ m/GenomeMapping/ && $PIC_FILES[$i] !~ m/Distinct/){
	print "<p class='intro'><b>Abundant Reads Length Distribution</b>Distribution of the lengths of the reads in the libraries.</p>";
	print "<table border=0 align='left'><tr><td><a class=\"lb\" href=\"$pic_dir/$PIC_FILES[$i]\" title=\"$PIC_FILES[$i]\"><img src=\"$thumb_dir/$PIC_FILES[$i]\"></a></td></tr>";
	print "<tr><td><a href='$pic_dir/$PIC_FILES[$i]' target='_blank'>Click to Download</a> / <a href='#' onclick=\"showTableLink($tabletab, 'doc/all_samples_readlen.data')\">View Data Table</a></td></tr></table>";
    }
    elsif ($PIC_FILES[$i] =~ m/ReadSize/ && $PIC_FILES[$i] !~ m/GenomeMapping/ && $PIC_FILES[$i] =~ m/Distinct/){
	print "<p class='intro'><b>Distinct Reads Length Distribution</b>Distribution of the lengths of the distinct sequences in the libraries.</p>";
	print "<table border=0 align='left'><tr><td><a class=\"lb\" href=\"$pic_dir/$PIC_FILES[$i]\" title=\"$PIC_FILES[$i]\"><img src=\"$thumb_dir/$PIC_FILES[$i]\"></a></td></tr>";
	print "<tr><td><a href='$pic_dir/$PIC_FILES[$i]' target='_blank'>Click to Download</a> / <a href='#' onclick=\"showTableLink($tabletab, 'doc/all_samples_distinct_readlen.data')\">View Data Table</a></td></tr></table>";
    }

    elsif ($PIC_FILES[$i] =~ /Quality/){
	print "<p class='intro'><b>Quality Score</b>The mean quality at each position of the read in each library is represented. The higher is the quality, the better are the libraries.</p>";
	print "<table border=0 align='left'><tr><td><a class=\"lb\" href=\"$pic_dir/$PIC_FILES[$i]\" title=\"$PIC_FILES[$i]\"><img src=\"$thumb_dir/$PIC_FILES[$i]\"></a></td></tr>";
	print "<tr><td><a href='$pic_dir/$PIC_FILES[$i]' target='_blank'>Click to Download</a> / <a href='#' onclick=\"showTableLink($tabletab, 'doc/all_samples_read_meanquality.data')\">View Data Table</a></td></tr></table>";
    }
}
print "</div></div>";

#####################################################
## TAB3 - DATA MAPPING
#####################################################

print "<div class=\"content\" id=\"tabs-3\"><h3>Reads Mapping on Reference Genome</h3>\n";
print "<div class=\"gallery\" id=\"gallery3\">";

for (my $i=0; $i<=$#PIC_FILES; $i++){
    if ($PIC_FILES[$i] =~ m/GenomeMapping/){
	if ($PIC_FILES[$i] =~ /ReadSize/ && $PIC_FILES[$i] !~ m/Distinct/){
	    print "<p class='intro'><b>Abundant Reads Length Distribution</b>Distribution of the lengths of the reads in the libraries.</p>";
	    print "<table border=0 align='left'><tr><td><a class=\"lb\" href=\"$pic_dir/$PIC_FILES[$i]\" title=\"$PIC_FILES[$i]\"><img src=\"$thumb_dir/$PIC_FILES[$i]\"></a></td></tr>";
	    print "<tr><td><a href='$pic_dir/$PIC_FILES[$i]' target='_blank'>Click to Download</a> / <a href='#' onclick=\"showTableLink($tabletab, 'doc/all_samples_genome_mapping_readlen.data')\">View Data Table</a></td></tr></table>";
	}elsif($PIC_FILES[$i] =~ /ReadSize/ && $PIC_FILES[$i] =~ m/Distinct/){
	    print "<p class='intro'><b>Distinct Reads Length Distribution</b>Distribution of the lengths of the distinct sequences in the libraries</p>";
	    print "<table border=0 align='left'><tr><td><a class=\"lb\" href=\"$pic_dir/$PIC_FILES[$i]\" title=\"$PIC_FILES[$i]\"><img src=\"$thumb_dir/$PIC_FILES[$i]\"></a></td></tr>";
	    print "<tr><td><a href='$pic_dir/$PIC_FILES[$i]' target='_blank'>Click to Download</a> / <a href='#' onclick=\"showTableLink($tabletab, 'doc/all_samples_genome_mapping_distinct_readlen.data')\">View Data Table</a></td></tr></table>";
	}else{
	    print "<p class='intro'><b>Mapping Proportion</b>Proportions of inserts that can be mapped to the reference genome for each library. Unique and multiple hits are respectively represented in dark and light green.</p>";
	    print "<table border=0 align='left'><tr><td><a class=\"lb\" href=\"$pic_dir/$PIC_FILES[$i]\" title=\"$PIC_FILES[$i]\"><img src=\"$thumb_dir/$PIC_FILES[$i]\"></a></td></tr>";
	    print "<tr><td><a href='$pic_dir/$PIC_FILES[$i]' target='_blank'>Click to Download</a> / <a href='#' onclick=\"showTableLink($tabletab, 'doc/all_samples_genome_mappingstat.data')\">View Data Table</a></td></tr></table>";
	}	
    }
}print "</div></div>";


#####################################################
## TAB4 - OVERVIEW
#####################################################

print "<div id=\"tabs-4\" class=\"content\"><h3>Annotation of non-conding RNAs</h3>\n";
print "<div class=\"gallery\" id=\"gallery4\">";
for (my $i=0; $i<=$#PIC_FILES; $i++){
    if ($PIC_FILES[$i] =~ m/plotReadAnnOverview/){##plotmiRNAmapping
	print "<p class='intro'><b>Reads Annotation Overview</b>Proportions of inserts that were associated to genomic features in each library.</p>";
	print "<table style=\"display:inline;\"><tr><td><a class=\"lb\" href=\"$pic_dir/$PIC_FILES[$i]\" title=\"$PIC_FILES[$i]\"><img src=\"$thumb_dir/$PIC_FILES[$i]\"></a></td></tr>";
	print "<tr><td><a href='$pic_dir/$PIC_FILES[$i]' target='_blank'>Click to Download</a> / <a href='#' onclick=\"showTableLink($tabletab, 'doc/all_samples_abundant_read_anno_overview.data')\">View Data Table</a></td></tr></table>";
    }elsif($PIC_FILES[$i] =~ m/plotmiRNAmapping/){
    	print "<p class='intro'><b>Precursor miRNAs Annotation</b>Proportions of inserts that were associated to pre-miRNAs features in each library.</p>";
	print "<table style=\"display:inline;\"><tr><td><a class=\"lb\" href=\"$pic_dir/$PIC_FILES[$i]\" title=\"$PIC_FILES[$i]\"><img src=\"$thumb_dir/$PIC_FILES[$i]\"></a></td></tr>";
	print "<tr><td><a href='$pic_dir/$PIC_FILES[$i]' target='_blank'>Click to Download</a> / <a href='#' onclick=\"showTableLink($tabletab, 'doc/all_samples_genome_mirnastat.data')\">View Data Table</a></td></tr></table>";

    }
}

for (my $i=0; $i<=$#PIC_FILES; $i++){
    if ($PIC_FILES[$i] =~ m/RfamClassOverview/){
	print "<p class='intro'><b>Annotation of ncRNAs from RFAM</b> Proportions of ncRNAs family among all inserts that were associated to ncRNAs in each library.</p>";
	print "<table style=\"display:inline;\"><tr><td><a class=\"lb\" href=\"$pic_dir/$PIC_FILES[$i]\" title=\"$PIC_FILES[$i]\"><img src=\"$thumb_dir/$PIC_FILES[$i]\"></a></td></tr>";
	print "<tr><td><a href='$pic_dir/$PIC_FILES[$i]' target='_blank'>Click to Download</a> / <a href='#' onclick=\"showTableLink($tabletab, 'doc/all_samples_rfam_famcov_abundant.data')\">View Data Table</a></td></tr></table>";
    }elsif($PIC_FILES[$i] =~ m/RmskClassOverview/){
	print "<p class='intro'><b>Annotation of Repetitive Regions</b> Proportions of repeats family among all inserts that were associated to repetitive regions in each library.</p>";
	print "<table style=\"display:inline;\"><tr><td><a class=\"lb\" href=\"$pic_dir/$PIC_FILES[$i]\" title=\"$PIC_FILES[$i]\"><img src=\"$thumb_dir/$PIC_FILES[$i]\"></a></td></tr>";
	print "<tr><td><a href='$pic_dir/$PIC_FILES[$i]' target='_blank'>Click to Download</a> / <a href='#' onclick=\"showTableLink($tabletab, 'doc/all_samples_rmsk_famcov_abundant.data')\">View Data Table</a></td></tr></table>";
    }
}
print "</div></div>";


#####################################################
## TAB - ONE PER NCRNA
#####################################################

my $tab_nb=5;
my $samplenum=1;
my $imgtitle;
foreach my $ncrna (@ALL_NCRNA) {
    my ($iest, $ncrna_name);
    my @par;
    my @valname=split("_",$ncrna);
    foreach my $val (@valname){
	if ($val =~ m/^[iest]$/){
	    $iest=$val;
	}elsif ($val =~ m/[\+\-][0-9]+/){
	    push(@par,$val);
	}else{
	    if ($ncrna_name){
		$ncrna_name=join(" ",$ncrna_name,$val);
	    }else{
 		$ncrna_name=$val;
 	    }
 	}
     }
     ## manual correction of patterns
     $ncrna_name=~s/miRNA miRNA/miRNA/g;
     $ncrna_name=~s/tRNA tRNA/tRNA/g;
     $ncrna_name=~s/rmsk/Repeats/g;
     print "<div class=\"content\" id=\"tabs-$tab_nb\">\n";
     print "<div class=\"gallery\" id=\"gallery$tab_nb\"><p class=\"galtitle\"><b>$ncrna_name</b>\n";
     if ($iest){
        	if ($iest eq "e"){
 	    print " [Extend  $par[0] bp at 5' end, $par[1] bp at 3' end]";
 	}elsif($iest eq "i"){
 	    print " [Shorten $par[0] bp at 5' end, $par[1] bp at 3' end]";
 	}elsif($iest eq "s"){
 	    print " [Get coordinates for sub-region from position $par[0] to $par[1] indexed from 5' end]";
 	}else{ 
 	    print " [Get coordinates for sub-region from position $par[0] to par[1] indexed from 3' end]";
 	}
     }
     print "</p>\n";

    foreach my $file (@RAW_FILES){
	my ( $sample, $path, $suffix ) = fileparse( $file, qr/\.[^.]*/ );
	my $sampleName = basename($sample);
	#$sampleName =~ s/\.[^.]+$//;    
	
	print "<div class='sampleprof'><div class='divprof'>'$sampleName' library</div><br>";
	my ($pattern_logo, $pattern_abundant, $pattern_distinct);
	$pattern_logo=$sampleName."_".$ncrna."_[53]";
	$pattern_abundant=$sampleName."_".$ncrna."_abundant";
	$pattern_distinct=$sampleName."_".$ncrna."_distinct";
	$pattern_abundant =~ s/\+/\\+/g;
	$pattern_distinct =~ s/\+/\\+/g;
	$pattern_logo =~ s/\+/\\+/g;

	##--------------------
	## Profiling
	##--------------------
	
	print "<p class='intro'><b>SmallRNAs profiling</b>In case of reads grouping, two different smallRNAs profiling are provided, by using abundant and distinct reads respectively. <br></p>";
	for (my $i=0; $i<=$#PIC_FILES; $i++){
	    if ($PIC_FILES[$i] =~ m/$pattern_abundant/){
		$imgtitle="$sampleName - $ncrna_name - Abundant Reads";
		print "<table style=\"display:inline;\"><tr><td><a class=\"lb\" href=\"$pic_dir/$PIC_FILES[$i]\" title=\"$PIC_FILES[$i]\"><img src=\"$thumb_dir/$PIC_FILES[$i]\" title=\"$imgtitle\"></a></td></tr>";
		print "<tr><td><a href='$pic_dir/$PIC_FILES[$i]' target='_blank'>Click to Download</a><br>";
		print "<a href='#' onclick=\"showTableLink($tabletab, 'doc/".$ncrna."_all_samples_scaled_basecov_abundant_3end_RPM.data')\">View 3' Profile Table</a>";
		print " / <a href='#' onclick=\"showTableLink($tabletab, 'doc/".$ncrna."_all_samples_scaled_basecov_abundant_5end_RPM.data')\">View 5' Profile Table</a>";
		print " / <a href='#' onclick=\"showTableLink($tabletab, 'doc/".$ncrna."_all_samples_scaled_basecov_abundant_all_RPM.data')\">View Coverage Profile Table</a><br>";
		print "<a href='#' onclick=\"showTableLink($tabletab, 'doc/".$ncrna."_all_samples_sense_readlen_abundant.data')\">View Sense length Table</a>";
		print " / <a href='#' onclick=\"showTableLink($tabletab, 'doc/".$ncrna."_all_samples_antisense_readlen_abundant.data')\">View Antisens Length  Table</a>";
		print " / <a href='#' onclick=\"showTableLink($tabletab, 'doc/".$ncrna."_all_samples_total_readlen_abundant.data')\">View Total Length Table</a>";
		print " </td></tr></table>";
	    }elsif($PIC_FILES[$i] =~ m/$pattern_distinct/){
		$imgtitle="$sampleName - $ncrna_name - Distinct Reads";
		print "<table style=\"display:inline;\"><tr><td><a class=\"lb\" href=\"$pic_dir/$PIC_FILES[$i]\" title=\"$PIC_FILES[$i]\"><img src=\"$thumb_dir/$PIC_FILES[$i]\" title=\"$imgtitle\"></a></td></tr>";
		print "<tr><td><a href='$pic_dir/$PIC_FILES[$i]' target='_blank'>Click to Download</a><br>";
		print "<a href='#' onclick=\"showTableLink($tabletab, 'doc/".$ncrna."_all_samples_scaled_basecov_distinct_3end_RPM.data')\">View 3' Profile Table</a>";
		print " / <a href='#' onclick=\"showTableLink($tabletab, 'doc/".$ncrna."_all_samples_scaled_basecov_distinct_5end_RPM.data')\">View 5' Profile Table</a>";
		print " / <a href='#' onclick=\"showTableLink($tabletab, 'doc/".$ncrna."_all_samples_scaled_basecov_distinct_all_RPM.data')\">View Coverage Profile Table</a><br>";
		print "<a href='#' onclick=\"showTableLink($tabletab, 'doc/".$ncrna."_all_samples_sense_readlen_distinct.data')\">View Sense length Table</a>";
		print " / <a href='#' onclick=\"showTableLink($tabletab, 'doc/".$ncrna."_all_samples_antisense_readlen_distinct.data')\">View Antisens Length  Table</a>";
		print " / <a href='#' onclick=\"showTableLink($tabletab, 'doc/".$ncrna."_all_samples_total_readlen_distinct.data')\">View Total Length Table</a>";
		print "</td></tr></table>";
	    }
	}
	

	##--------------------
	## Logo
	##--------------------
	
	print "<p class='intro'><b>Logo Sequences</b>For each annotation family, ncPRO-seq provides two types of sequence logos figures by using different subsets of distinct reads. In the first case, all distinct reads in annotation faimily are used to create sequence logos. In the second case, only the distinct read with the highest abundance in each family member is used.</p>";
	for (my $i=0; $i<=$#PIC_FILES; $i++){
	    if ($PIC_FILES[$i] =~ m/$pattern_logo/ && $PIC_FILES[$i] =~ m/LOGO/){
		if ($PIC_FILES[$i] =~ m/_unique_LOGO/){
		    $imgtitle="$sampleName - $ncrna_name - Logo - Highest Distinct Reads";
		}else{
			$imgtitle="$sampleName - $ncrna_name - Logo - Distinct reads";
		}
		
		print "<table style=\"display:inline;\"><tr><td><a class=\"lb\" href=\"$pic_dir/$PIC_FILES[$i]\" title=\"$PIC_FILES[$i]\"><img src=\"$thumb_dir/$PIC_FILES[$i]\" title=\"$imgtitle\"></a></tr></td><tr><td><a href='$pic_dir/$PIC_FILES[$i]' target='_blank'>Click to Download</a></td></tr></table>";
	    }
	}
	print "</div>";
	
	$samplenum++;
}
    
     $tab_nb++;
     print "</div></div>";
 }


################################################
## SIG REGION
################################################

if ($runSIG == 1){
    print "<div class=\"content\" id=\"tabs-sig\">\n";
    print "<div class=\"gallery\" id=\"sig\"><h3>Search for Significantly Enriched Regions</h3>\n";
    
    foreach my $file (@RAW_FILES){
	my ( $sample, $path, $suffix ) = fileparse( $file, qr/\.[^.]*/ );
	my $sampleName = basename($sample);
	$sampleName =~ s/\.[^.]+$//;    
	
	print "<div class='sampleprof'><div class='divprof'>Model Fit of '$sampleName' library</div><br>";
	for (my $i=0; $i<=$#PIC_FILES; $i++){
	    if ($PIC_FILES[$i] =~ m/plotReadModelFit.png$/ && $PIC_FILES[$i] =~ /$sampleName/){
		print "<table style=\"display:inline;\"><tr><td><a class=\"lb\" href=\"$pic_dir/$PIC_FILES[$i]\" title=\"$PIC_FILES[$i]\"><img src=\"$thumb_dir/$PIC_FILES[$i]\"></a></tr></td><tr><td><a href='$pic_dir/$PIC_FILES[$i]' target='_blank'>Click to Download</a></td></tr></table>";
	    }
	}
	print "</div>";
    }
    
    @TAB_FILES=();
    foreach my $tablefile (@DOC_FILES){
	 if ($tablefile =~ /sigReg/  || $tablefile =~ /Sigregion/){
	     push(@TAB_FILES, "$doc_dir/$tablefile");
	 }
    }


    print "<div class='divprof'>Table View</div>";
    print "<p class='intro'>All files used to create the presented figures are available for visualization/download. Please select the file you want to visualize/download.</p>";
    print "<form id=\"sigtableview\">\n";
    print "<select id=\"sigcsvfile\" size=\"1\">\n";
    foreach my $tablefile (@TAB_FILES){
	print "<option value=\"$tablefile\">".basename($tablefile)."\n";
    }
    print "</select>\n";
    print "<input class=\"btn1\" type=\"button\" onclick = \"document.getElementById('loading').style.display='block';showTable('sigcsvfile', 'sigtabdisplay');\"  value=\"View File\">\n";
    print "<input class=\"btn1\" type=\"button\" onclick = \"download(document.getElementById('sigcsvfile').value);\"  value=\"Download File\">\n";
    print "</form><br>\n";
    print "<div id=\"loading\" style=\" width:100%; display:none;\">Now loading ...</div>\n";
    print "<table class=\"tdisplay\" id=\"sigtabdisplay\"></table>\n";

    print "</div></div>";
}


#####################################################
## TAB TABLE
print "<div class=\"content\" id=\"tableview\"><h3>Table Viewer</h3>\n";
print "<b>Please select the file you want to visualize/download :<br></b>";

print "<form id=\"maintabview\">\n";
print "<select id=\"maincsvfile\" size=\"1\">\n";

print "<optgroup label='Normalized ncRNAs Counts'>";
foreach my $tablefile (@DOC_FILES){
    if ($tablefile =~ /subfamcov_RPM.data/){
	print "<option value=\"$doc_dir/$tablefile\">$tablefile\n";
    }
}
print "</optgroup>";
print "<optgroup label='Raw ncRNAs Counts'>";
foreach my $tablefile (@DOC_FILES){
    if ($tablefile =~ /subfamcov.data/){
	print "<option value=\"$doc_dir/$tablefile\">$tablefile\n";
    }
}
print "</optgroup>";


print "<optgroup label='All Samples Tables'>";
foreach my $tablefile (@DOC_FILES){
    if ($tablefile =~ /^all_samples/){
	print "<option value=\"$doc_dir/$tablefile\">$tablefile\n";
    }
}
print "</optgroup>";
foreach my $ncrna (@ALL_NCRNA){
    my $pattern=$ncrna;
    #$ncrna_name=~s/_[iest]_[\+\-][0-9]+_[\+-][0-9]+$//g;
    $pattern =~ s/\+/\\+/g;
    $pattern =~ s/\-/\\-/g;
    print "<optgroup label=$ncrna>";
    foreach my $tablefile (@DOC_FILES){
	if ($tablefile =~ /$pattern/){
	    print "<option value=\"$doc_dir/$tablefile\">$tablefile\n";
	}
    }
}

print "</select>\n";
print "<input class=\"btn1\" type=\"button\" onclick = \"document.getElementById('loading').style.display='block';showTable('maincsvfile', 'maintabdisplay');\"  value=\"View File\">\n";
print "<input class=\"btn1\" type=\"button\" onclick = \"download(document.getElementById('maincsvfile').value);\"  value=\"Download File\">\n";
print "</form><br>\n";
print "<div id=\"tableError\"></div>";
print "<div id=\"loading\" style=\" width:100%; display:none;\">Now loading ...</div>\n";
print "<table class=\"tdisplay\" id=\"maintabdisplay\"></table>";
print "</div>\n";


#####################################################
## TAB UCSC TRACK
if ($runUCSCTrack == 1){
    my @UCSC_BED_FILES;
    my @UCSC_BEDGRAPH_FILES;
    print "<div id=\"tracks\" class=\"content\"><h3>Download Genome Tracks</h3>";
    foreach my $sample (@RAW_FILES) {
	my $sampleName = basename($sample);
	$sampleName =~ s/\.[^.]+$//;    
	print "<p class='intro'><b>$sampleName</b></p>";
	opendir(UCSCDIR, $ucsc_dir) || die "can't opendir: $!"; 
	while (my $file = readdir(UCSCDIR)) {
	    if ($file =~ m/$sampleName/ && $file =~ m/bed.gz$/){
		push(@UCSC_BED_FILES,$file);
	    }
	    if ($file =~ m/$sampleName/ && $file =~ m/bedGraph.gz$/){
		push(@UCSC_BEDGRAPH_FILES,$file);
	    }
	}
	close UCSCDIR;
	@UCSC_BED_FILES=sort(@UCSC_BED_FILES);
	@UCSC_BEDGRAPH_FILES=sort(@UCSC_BEDGRAPH_FILES);
	print "<b>BedGraph UCSC tracks</b><br><hr>";
	foreach my $ufile (@UCSC_BEDGRAPH_FILES) {
	    print "<a href=$ucsc_dir/$ufile target=\"_blank\">$ufile</a><br>";
	}
 	print "<br><b>Bed UCSC tracks</b><br><hr>";
	foreach my $ufile (@UCSC_BED_FILES) {
	    print "<a href=$ucsc_dir/$ufile target=\"_blank\">$ufile</a><br>";
	}
   }
    print "</div>";
}

#####################################################
## LOGS TAB
print "<div class=\"content\" id=\"logs\">";
open LOG,"<$log_file" or die $!;
while (my $line = <LOG>) {
    chomp($line);
    next if ($line =~ m/^\#/ || $line =~ m/^$/ || $line =~ m/=( )*$/);
    print $line."<br>";
}
close NCRNA;
print "</div>";

#####################################################
## TAB HELP
print "<div class=\"content\" id=\"manual\">";
print "<iframe id='help' src='manuals/manual/manual.html' width=100% height=800px style=\"border:0px\"></iframe>";
print "</div>";

## HTML footer
open FOOTER,"<$html_dir/footer.html" or die $!;
while (my $line = <FOOTER>) {
    print $line;
}
close FOOTER;



