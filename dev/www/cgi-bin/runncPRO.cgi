#!/usr/bin/perl 
## Nicolas Servant
## ncPRO-seq perl CGI script
## Get data from load.php
## Write the config-ncrna.txt file
## Run the ncPRO-seq pipeline

use CGI;
use File::Basename;
use URI::Escape;
use POSIX qw(strftime);

sub parse_config_file {
    my ($config_line, $name, $value, $Config);
    ($File, $Config) = @_;

    if (!open (CONFIG, "$File")) {
        print "ERROR: Config file not found : $File";
        exit(0);
    }

    while (<CONFIG>) {
        $config_line=$_;
        chop ($config_line);
        $config_line =~ s/^\s*//;
        $config_line =~ s/\s*$//;
        if ( ($config_line !~ /^#/) && ($config_line ne "") ){
	    $name=substr($config_line, 0, index($config_line,"="));
	    $value=substr($config_line, index($config_line,"=")+1);
	    $name =~ s/\s*$//;
	    $value =~ s/^\s*//;
	    $$Config{$name} = $value;
        }
    }

    close(CONFIG);
}

my $html_dir="html";

read(STDIN, $data, $ENV{'CONTENT_LENGTH'});
@form = split(/&/, $data);
foreach $field (@form){
    ($key, $value) = split(/=/, $field);
    $value =~ tr/+/ /;
    $value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
    $value =~ s/</&lt;/g;
    $value =~ s/>/&gt;/g;
    $form{$key} = $value;
}


##############################################
##
## Check config
##
##############################################


my %config;
my $msg_conf="";
my $error_conf=0;

if ( ! -e 'config_cgi.inc'){
    $error_conf=1;
    $msg_conf.="Error : Configuration 'config_cgi.inc' file not found<br>";
}else{
    &parse_config_file ('config_cgi.inc', \%config);
}


##############################################
##
## Options from load.php
##
##############################################


my $rnum=int(rand(100000));
my $le_localtime = localtime;
my $command_line="ncPRO-seq -c config-ncPRO-$rnum -s configCheck";

## Group reads ?
my $groupreads=0;
if (defined $form{"group"}){
    $groupreads=1;
    if ($form{"group"} eq "2"){
	    $groupreads=2;
    }
}
## Data mapping
if (defined $form{"domapping"}){
    $command_line.=" -s processRead -s mapGenome";
}
else{
   $command_line.=" -s processBam"; 
}

## Overview
if (defined $form{"mapstat"}){
    $command_line.=" -s mapGenomeStat";
}
if (defined $form{"rfamover"}){
    $command_line.=" -s overviewRfam";
}
if (defined $form{"readover"}){
    $command_line.=" -s mapAnnOverview -s mirna_stat";
}
if (defined $form{"rmskover"}){
    $command_line.=" -s overviewRmsk";
}

## Profiling
my @splitcode;
my $mir_code;
if (defined $form{"domir"}){
    $mir_code=$form{"miRNAcode"};
    $mir_code=~s/_[iest]_[\+-]0_[\+-]0$//;
}
my $pmir_code;
if (defined $form{"dopmir"}){
    $pmir_code=$form{"premiRNAcode"};
    $pmir_code=~s/^premi/mi/;
    $pmir_code=~s/_[iest]_[\+-]0_[\+-]0$//;
}
my $tRNA_code;
if (defined $form{"dotRNA"}){
    $tRNA_code=$form{"tRNAcode"};
    $tRNA_code=~s/_[iest]_[\+-]0_[\+-]0$//;
}

my ($ncrna_code, $ncrna_code_ex);
if (defined $form{"dorfam"}){
    @splitcode=split(/,/,$form{"ncRNAcode"});
    foreach my $val (@splitcode){
	if ($val =~ /_[iest]_[\+-]0_[\+-]0$/){
	    $val=~s/_[iest]_[\+-]0_[\+-]0$//;
	    $ncrna_code=join(',',$ncrna_code, $val);
	}else{
	    $ncrna_code_ex=join(',',$ncrna_code_ex, $val);
	}
    }
    $ncrna_code=~s/^,//;
    $ncrna_code_ex=~s/^,//;
}
my ($rmsk_code,$rmsk_code_ex);
if (defined $form{"dormsk"}){
    @splitcode=split(/,/,$form{"rmskcode"});
    foreach my $val (@splitcode){
	if (defined $form{"rmskfulllength"}){
	    $rmsk_code='';
	    $rmsk_code_ex=join(',',$rmsk_code_ex, $val);
	}else{
	    $val=~s/_[iest]_[\+-]0_[\+-]0$//;
	    $rmsk_code=join(',',$rmsk_code, $val);
	    $rmsk_code_ex='';
	}
    }
    $rmsk_code=~s/^,//;
    $rmsk_code_ex=~s/^,//;
}
## Custom gff
@splitgff=split(/,/,$form{'customgff'});


if (defined $form{"domir"} || defined $form{"dopmir"} || defined $form{"dorfam"} || defined $form{"dormsk"} || $#splitgff >= 0){
    $command_line.=" -s generateNcgff -s ncrnaProcess";
}


## UCSC
my $ucsc_option="";
$command_line.=" -s ncrnaTracks";
if (defined $form{"doucsc"}){
    $command_line.=" -s genomeTracks";
    $ucsc_option="min_len=$form{'ucsc_mins'},max_len=$form{'ucsc_maxs'},min_copy=$form{'ucsc_minrep'},max_copy=$form{'ucsc_maxrep'}";
}

## Significant Enriched Region
my $sig_option="";
if (defined $form{"dosig"}){
    $command_line.=" -s sigRegion";
    $sig_option="min_len=$form{'sig_mins'},max_len=$form{'sig_maxs'},min_copy=$form{'sig_minrep'},max_copy=$form{'sig_maxrep'}";
}

## Annotation file
my $annotation_path="";
if (defined $form{"org"}){
    $annotation_path="annotation/".$form{"org"};
    chomp $annotation_path;
    $annotation_path=~s/\r//g;
}

## Search of significant regions
my @splitsigex=split(/,/,$form{"sigexcludelist"});
my $sig_annot_ex;
foreach my $val (@splitsigex){
    if ($val =~ /pre-miRNA/){
	$sig_annot_ex=join(' ',$sig_annot_ex, "$annotation_path/precursor_miRNA.gff");
    }elsif($val =~ /mature/){
	$sig_annot_ex=join(' ',$sig_annot_ex, "$annotation_path/mature_miRNA.gff");
    }elsif($val =~ /Gene/){
	$sig_annot_ex=join(' ',$sig_annot_ex, "$annotation_path/coding_gene.gff");
    }elsif($val =~ /ncRNA/){
	$sig_annot_ex=join(' ',$sig_annot_ex, "$annotation_path/rfam.gff");
    }elsif($val =~ /Repeats/){
	$sig_annot_ex=join(' ',$sig_annot_ex, "$annotation_path/rmsk.gff");
    }
}
$sig_annot_ex=~s/^ //;

##input files
my @input_files=split(",",uri_unescape($form{'selfileslist'}));

## mail
my $sendmailto=$form{'umail'};

## Store results
##my $res_dir = dirname($ENV{'SCRIPT_FILENAME'} || $ENV{'PATH_TRANSLATED'} || $0)."/".$config{'OUTPUT'}."/res".$rnum;
my $res_dir=$config{'OUTPUT'}."/res".$rnum;
my $conf_file=$config{'OUTPUT'}.'/res'.$rnum.'/config-ncPRO-'.$rnum;
my $log_file=$config{'OUTPUT'}.'/res'.$rnum.'/pipeline.log';
my $logexec_file=$config{'OUTPUT'}.'/res'.$rnum.'/exec.log';


##############################################
##
## Run ncPRO-seq
##
##############################################
 

#system("install_dir/bin/ncPRO-deploy"," -o"," $res_dir") or die "Unable to deploy pipeline in $res_dir. Check if ncPRO-seq is in the $ENV{PATH}";
my @back=`$config{'INSTALL_DIR'}/bin/ncPRO-deploy -o $res_dir &`;

if (-d $res_dir && $error_conf==0) {

    ##############################################
    ##
    ## Input files
    ##
    ##############################################
    $msg_content="";

    my $ext;
    my $input_status=1;
    for (my $i=0; $i<=$#input_files;$i++){
	
	## Is file
	if (-f $input_files[$i]){
	    my $linkname=basename($input_files[$i]);
	    ##$ext = ($input_files[$i] =~ m/([^.]+)$/)[0];
	    if (-l $res_dir.'/rawdata/'.$linkname){##$intput_files[$i]){
		$msg_content .="<br><font color='red'>Warning : File ".basename($input_files[$i])." already exists !</font><br>";	
	    }else{
		my $symlink_exists = symlink($input_files[$i], $res_dir.'/rawdata/'.$linkname);
		if ($symlink_exists==0){
		    $input_status=0;
		    $msg_content .="<br> Cannot create symbolic link to ".basename($input_files[$i])." in ".basename($res_dir)." <br>";
		}
	    }
	##Is folder
	}elsif(-d $input_files[$i]){
	    opendir(my $dh, $input_files[$i]) || die;
	    while(my $rfile=readdir $dh) {
		if ($rfile =~ /\.fastq$/ || $rfile =~ /\.casfata$/ || $rfile =~ /\.bam$/ || $rfile =~ /\.fa/ || $rfile =~ /\.fasta/){
		    ##$ext = ($rfile =~ m/([^.]+)$/)[0];
		    if (-e $intput_files[$i]){
			$msg_content .="<br>Warning : File ".basename($input_files[$i])." already exists !<br>";	
		    }else{
			my $symlink_exists = symlink($input_files[$i].'/'.$rfile, $res_dir.'/rawdata/'.$rfile);
			if ($symlink_exists==0){
			    $input_status=0;
			    $msg_content .="<br>Cannot create symbolic link to ".basename($input_files[$i])." in ".basename($res_dir)." <br>";
			    last;
			}
		    }
		}
	    }
	    closedir $dh;
	}else{
	    $msg_content .="<br>Input file(s) not found : ".$input_files[$i]." <br>";
	    $input_status=0;
	}
    }

    ##############################################
    ##
    ## Config File
    ##
    ##############################################

    open CONFIG, '>'.$config{'OUTPUT'}.'/res'.$rnum.'/config-ncPRO-'.$rnum or die "Unable to write config file";
    print CONFIG "#########################################################################\n";
    print CONFIG "## ncRNApip - configuration file from web interface\n";
    print CONFIG "#########################################################################\n";
    print CONFIG "RAW_DIR = rawdata\n";
    print CONFIG "DATA_DIR = data\n";
    print CONFIG "DOC_DIR = doc\n";
    print CONFIG "PIC_DIR = pic\n";
    print CONFIG "UCSC_DIR = ucsc\n";
    print CONFIG "LOGS_DIR = logs\n";
    print CONFIG "PRO_GFF_DIR = processed_gff\n";
    print CONFIG "BOWTIE_RESULTS_DIR = bowtie_results\n";
    print CONFIG "ANNOT_DIR = annotation\n";
    print CONFIG "HTML_DIR = html\n\n";
    
    print CONFIG "#######################################################################\n";
    print CONFIG "## System settings\n";
    print CONFIG "#######################################################################\n";
    print CONFIG "N_CPU = $form{'ncpu'}\n";
    print CONFIG "LOGFILE = pipeline.log\n\n";
    
    print CONFIG "#######################################################################\n";
    print CONFIG "## Bowtie options\n";
    print CONFIG "## Three types of fastq format are supported:phred33, solexa, solexa1.3\n";
    print CONFIG "#######################################################################\n";
    
    print CONFIG "FASTQ_FORMAT = $form{'fastqformat_sx'}\n";

    if (defined $form{"domapping"}){
	print CONFIG "BOWTIE_GENOME_REFERENCE = $form{'bowtie_index'}\n";
	print CONFIG "BOWTIE_GENOME_REFERENCE_CS = $form{'bowtie_index_c'}\n";
       	print CONFIG "BOWTIE_GENOME_OPTIONS_CS = -C -v $form{'mm_cs'} -a -m $form{'rep_cs'} --best --strata -f -y --col-keepends\n";
	print CONFIG "BOWTIE_GENOME_OPTIONS_FA = -v $form{'mm_454'} -a -m $form{'rep_454'} --best --strata --nomaqround -f -y\n";
	print CONFIG "BOWTIE_GENOME_OPTIONS_FQ =  -e $form{'mm_sx'} -a -m $form{'rep_sx'} --best --strata --nomaqround -y\n\n";
    }else{
	print CONFIG "BOWTIE_GENOME_REFERENCE = \n";
	print CONFIG "BOWTIE_GENOME_REFERENCE_CS = \n";
	print CONFIG "BOWTIE_GENOME_OPTIONS_CS = \n";
	print CONFIG "BOWTIE_GENOME_OPTIONS_FA = \n";
	print CONFIG "BOWTIE_GENOME_OPTIONS_FQ =  \n";
 
    }
    print CONFIG "#######################################################################\n";
    print CONFIG "## Group read options\n";
    print CONFIG "#######################################################################\n";
    print CONFIG "GROUP_READ = $groupreads\n\n";

    print CONFIG "#######################################################################\n";
    print CONFIG "## Annotation files\n";
    print CONFIG "#######################################################################\n";
    print CONFIG "ORGANISM = $form{'org'}\n";
    print CONFIG "ANNO_CATALOG = annotation/$form{'org'}/precursor_miRNA.gff annotation/$form{'org'}/rfam.gff annotation/$form{'org'}/rmsk.gff annotation/$form{'org'}/coding_gene.gff\n\n";

    print CONFIG "#######################################################################\n";
    print CONFIG "## ncRNA from Rfam\n";
    print CONFIG "#######################################################################\n";
    print CONFIG "NCRNA_RFAM = $ncrna_code\n";
    print CONFIG "NCRNA_RFAM_EX = $ncrna_code_ex\n\n";
    
    print CONFIG "#######################################################################\n";
    print CONFIG "## miRNA from miRBase\n";
    print CONFIG "#######################################################################\n";
    print CONFIG "MATURE_MIRNA = $mir_code\n";
    print CONFIG "PRECURSOR_MIRNA = $pmir_code\n\n";
    
    print CONFIG "#######################################################################\n";
    print CONFIG "## tRNA from UCSC\n";
    print CONFIG "#######################################################################\n";
    print CONFIG "TRNA_UCSC = $tRNA_code\n\n";
    
    print CONFIG "#######################################################################\n";
    print CONFIG "## ncRNA from RepeatMasker\n";
    print CONFIG "#######################################################################\n";
    print CONFIG "NCRNA_RMSK = $rmsk_code\n";
    print CONFIG "NCRNA_RMSK_EX = $rmsk_code_ex\n\n";
    
    print CONFIG "#######################################################################\n";
    print CONFIG "## ncRNA from other source\n";
    print CONFIG "#######################################################################\n";
    print CONFIG "OTHER_NCRNA_GFF = $form{'customgff'}\n\n";
    
    print CONFIG "#######################################################################\n";
    print CONFIG "## Logo sequences\n";
    print CONFIG "#######################################################################\n";
    print CONFIG "LOGO_DIRECTION = 5\n";
    print CONFIG "IC_SCALE = 0\n\n";
    
    print CONFIG "#######################################################################\n";
    print CONFIG "## UCSC Genome Tracks\n";
    print CONFIG "#######################################################################\n";
    print CONFIG "GENOME_TRACK_OPTIONS = $ucsc_option\n\n";
    
    print CONFIG "#######################################################################\n";
    print CONFIG "## Settings to extract regions not annotated as EXCLUDE_ANN_GFF, but significantly enriched with reads\n";
    print CONFIG "#######################################################################\n";
    if (defined $form{"dosig"}){
	print CONFIG "SIG_READ_OPTIONS = $sig_option\n";
	print CONFIG "SIG_WIN_SIZE = $form{'sig_wsi'}\n";
	print CONFIG "SIG_STEP_SIZE = $form{'sig_wst'}\n";
	print CONFIG "EXCLUDE_ANN_GFF = $sig_annot_ex\n";
	print CONFIG "FIT_MODEL =  $form{'sig_mod'}\n";
	print CONFIG "PVAL_CUTOFF = $form{'sig_pv'}\n\n";
    }else{
	print CONFIG "SIG_READ_OPTIONS = \n";
	print CONFIG "SIG_WIN_SIZE = \n";
	print CONFIG "SIG_STEP_SIZE = \n";
	print CONFIG "EXCLUDE_ANN_GFF = \n";
	print CONFIG "FIT_MODEL =  \n";
	print CONFIG "PVAL_CUTOFF = \n\n";
    }
  
    close CONFIG;
    

    ##############################################
    ##
    ## Run ncPRO-seq
    ##
    ##############################################
    $command_line.=" -s html_builder -s clean";
    
    if ($sendmailto){
	$command_line.=" -m $sendmailto";
    }

    my $pbs_id;
    my $sys_back=-1;
    if ($input_status==1){
	if (-e $conf_file) {
	    chdir $res_dir or die "Cannot cd dir";
	    ## First update of the interface
	    my @back=`$config{'INSTALL_DIR'}/bin/ncPRO-seq -c config-ncPRO-$rnum -s html_builder &`;
	    ## Add info in LOGFILE
	    my $cgi_url=`dirname $ENV{'SCRIPT_URI'}`;
	    my $cgi_url=`dirname $ENV{'HTTP_REFERER'}`;
	    $cgi_url =~ s/\s$//;

	    my $url=$cgi_url."/".basename($config{'OUTPUT'})."/res".$rnum."/report.html";
	    my $log_url=$cgi_url."/".basename($config{'OUTPUT'})."/res".$rnum."/pipeline.log";
	    my $exec_url=$cgi_url."/".basename($config{'OUTPUT'})."/res".$rnum."/exec.log";

	    open LOG, '>'.$log_file or die "Unable to write in log file";
	    print LOG "ncPRO-seq analysis\n\n";
	    print LOG "HTML report available at $url\n";
	    print LOG "Detailed logs can be found at ".$cgi_url."/".basename($config{'OUTPUT'})."/res".$rnum."/exec.log\n\n";
	    close LOG;

            ## Run the pipeline
	    my $cmd="$config{'INSTALL_DIR'}/bin/$command_line >> exec.log 2>&1";

	    open LOGEXEC, '>'.$logexec_file or die "Unable to write in log exec file";
	    print LOGEXEC "ncPRO-seq detailed log file\n";
	    print LOGEXEC "$le_localtime\n\n";
	    print LOGEXEC "ncPRO analysis id = $rnum\n";
	    print LOGEXEC $cmd;
	    if ($config{'PBS_MODE'} == 1){
		print LOGEXEC "\nqsub ".$config{'PBS_OPT'}." -N ncpro$rnum";
	    }
	    close LOGEXEC;
	    
	    my $cmd_exec;
	    if ($config{'PBS_MODE'} == 1){
		$cmd_exec="echo \"cd $res_dir; $cmd\" | qsub ".$config{'PBS_OPT'}." -N ncpro$rnum";
		$pbs_id=qx{$cmd_exec};
	    }else{
		$cmd_exec="$cmd &";
		$sys_back=system($cmd_exec);
	    }
	    	    
	    if ($pbs_id || $sys_back==0){
		$msg_header = qq[	<b>&#10003;&nbsp;ncPRO-seq analysis in progress !</b><br><br><font color='red'>Please do not refresh this page !</font><br>];
		if ($pbs_id){
		    $msg_header .= qq[Your job is now submitted (Job ID : $pbs_id).<br>];
		}
		$msg_header .= qq[The results will be available at : <a target='_blank' href=$url>$url</a><br><br>];
		$msg_header .= qq[Please, click here to <a href=$log_url target='_blank'>follow the ncPRO-seq process</a>, or look at the <a href=$exec_url target='_blank'>detailed log file</a><br>];
		


		if ($sendmailto){
		    $msg_header .= qq[A email will be send to <a href='mailto:$sendmailto'>$sendmailto</a> at the end of the analysis.];
		}
	    }else{
		$msg_header = qq[	<font color="red"><b>&#10005;&nbsp;Error - job submission failed !</b><br><br>Please, try again in a few minutes<br></font>];
		$msg_debug .= qq[<b>PBS_OPT</b>=$config{'PBS_OPT'}<br><b>CMD</b>=$cmd_exec<br>$pbs_id];
	    }

	    $msg_content .= qq[
<h3>Command line :</h3>
$command_line
];
	    $msg_content .= qq[<h3>Input files :</h3>];

	    opendir(my $dh, $res_dir.'/rawdata') || die;
	    while(my $rfile=readdir $dh) {
		if(($rfile!~/^\./)&&($rfile!~/~$/)){
		    $msg_content .="$rfile<br>";
		}
	    }
	    closedir $dh;

	    $msg_content .= qq[
<h3>Options used to perform the analysis :</h3>
<ul class="param">
];
	    
	    open CONFIG,  basename($conf_file) or die $!;
	    while (my $line = <CONFIG>) {
		chomp($line);
		next if ($line =~ m/^\#/ || $line =~ m/^$/ || $line =~ m/=( )*$/);
		#my @values=split('=',$line);
		$name=substr($line, 0, index($line,"="));
		$value=substr($line, index($line,"=")+1);
 
		$msg_content .= qq[<li>$name<span>$value</span></li>];#
		
	    }
	    close CONFIG;
	    
	    $msg_content .= qq[
</ul><br>];




	}else{
	    $msg_header = qq[<br><br><font color="red"><big>&#9888;&nbsp;</big>Failed to run ncPRO-seq !</font><br><br><br><br>];
	    $msg_content = qq[ 
<h3>Error : Configuration file not found</h3>
];
	}
    }else{
	$msg_header = qq[   <font color="red"><big>&#9888;&nbsp;</big>Failed to run ncPRO-seq !</font><br><br><br><br>];
	$msg_content = qq[<h3>Error : Cannot load input files</h3>].$msg_content;
    }
}# can run ncPRO
else{

    if (! $config{'OUTPUT'}){
	$msg_conf.="Error : 'OUTPUT' variable not defined in CGI configuration file<br>";
    }else{
	my $rd=readlink($config{'OUTPUT'});
	if (! -d $rd || ! -w $rd){
	    $msg_conf.="Error : $config{'OUTPUT'} not found or not writable<br>";
	}
    }
    
    if (! $config{'INSTALL_DIR'}){
	$msg_conf.="Error : $config{'INSTALL_DIR'} variable not defined in CGI configuration file<br>";
    }
    else{
	if (! -e $config{'INSTALL_DIR'}."/bin/ncPRO-deploy" || ! -e $config{'INSTALL_DIR'}."/bin/ncPRO-seq"){
	    $msg_conf.="Error : ncPRO-deploy or ncPRO-seq command not found in $config{'INSTALL_DIR'}/bin/";
	}
    }
    
    $msg_header = qq[   <font color="red"><big>&#9888;&nbsp;</big>Failed to run ncPRO-seq !</font><br><br><br><br>];
    $msg_content = qq[ 
<h3>Error : Cannot deploy ncPRO-seq in $res_dir</h3>
];
}


my $css_path=dirname($ENV{'HTTP_REFERER'});
print "Content-type: text/html\n\n";
print qq{
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html;charset=iso-8859-1"/>
		<title>ncPRO-seq : run pipeline</title>
                <link rel="stylesheet" type="text/css" href="$css_path/css/ncpro.css"/>
	</head>
	<body>
		<div id="container">
		
				<div class="msg_container">
					<div class="msg_header">
						$msg_header
					</div>
					<div class="msg_content">
					$msg_content
					$msg_conf
					</div>
			
	</div>
<div>$msg_debug</div>

		
			        <div id="bottom">
  &copy; Institut Curie - 2010 | Last modified: Mar 17, 2011 | <a href="mailto:nservant@curie.fr" title="contact us">Contact us</a>
			        </div>
                 </div>
	</body>
</html>
	};
