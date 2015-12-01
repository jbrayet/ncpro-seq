<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">

<?php include('config_html.inc'); ?>

<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html;charset=iso-8859-1"/>
    <meta name="author" content="N. Servant and C. Chen">
    <meta name="copyright" content="&copy; 2010 Institut Curie">
    <title>ncPRO-seq analysis</title>
    
    <!-- Custom CSS -->
    <link rel="stylesheet" type="text/css" href="css/ncpro.css"/>
    <link rel="stylesheet" type="text/css" href="css/datatable_jui.css"/>
    
    <!-- Jquery -->
    <link type="text/css" rel="stylesheet"  href="css/custom-theme/jquery-ui-1.8.17.custom.css"/>
    <script type="text/javascript" src="js/jquery.js"></script>
    <script type="text/javascript" src="js/jquery-1.4.2.min.js"></script>
    <script type="text/javascript" src="js/jquery-ui-1.8.17.custom.min.js"></script>
    
    <!-- Web design -->
    <link rel="stylesheet" type="text/css" href="css/arbocss.css"/>
    <!--<script type="text/javascript" src="js/ConstructArbo.js"></script>-->
    <script type="text/javascript" src="js/jquery.validate.js"></script>
    <script type="text/javascript" src="js/jquery.validate-addMethods.js"></script>

     <!-- Functions -->
    <script  type="text/javascript" src="js/ncpro_func.js"></script>
    <script type="text/javascript">
      //window.onload=function(){cacheArbo()};
      
      $(function() {
      $("#tabs").tabs();
      $("#tabs").tabs('select', 0);
      });
      
      (function($) {
      dissub=function(){
      $("#runncpro").attr("disabled", true);
      };
      })(jQuery)


      $(document).ready(function(){

      $('#pipForm').submit(function(e) {
      var retval=true;
      var values = {};
      //$('#alertError').empty();

      $.each($('#pipForm').serializeArray(), function(i, field) {
      values[field.name] = field.value;
      });
      
      var sf=$.param($('input[name="selfiles"]'));
      sf=sf.replace(/selfiles=/g,"");
      sf=sf.replace(/&/g,",");
      if (sf == ""){
      $('#alertError').append('Error : input files not specified<br>');
      retval=false;
      }else{
      $('#selfileslist').val(sf);
      }
 
      var ncrna_code=getExtendCode($('select[name="ncrna_sel"]'), $('select[name="ncrna_ext"]'), $('select[name="ncrna_3pm"]'), $('select[name="ncrna_5pm"]'), $('input[name="ncrna_3val"]'), $('input[name="ncrna_5val"]'));
      $('#ncRNAcode').val(ncrna_code);
      var rmsk_code=getExtendCode($('select[name="rmsk_sel"]'), $('select[name="rmsk_ext"]'), $('select[name="rmsk_3pm"]'), $('select[name="rmsk_5pm"]'), $('input[name="rmsk_3val"]'), $('input[name="rmsk_5val"]'));
      $('#rmskcode').val(rmsk_code);
      var miRNA_code=getExtendCode($('select[name="miRNA_sel"]'), $('select[name="miRNA_ext"]'), $('select[name="miRNA_3pm"]'), $('select[name="miRNA_5pm"]'), $('input[name="miRNA_3val"]'), $('input[name="miRNA_5val"]'));
      $('#miRNAcode').val(miRNA_code);
      var premiRNA_code=getExtendCode($('select[name="premiRNA_sel"]'), $('select[name="premiRNA_ext"]'), $('select[name="premiRNA_3pm"]'), $('select[name="premiRNA_5pm"]'), $('input[name="premiRNA_3val"]'), $('input[name="premiRNA_5val"]'));
      $('#premiRNAcode').val(premiRNA_code);
      var tRNA_code=getExtendCode($('select[name="tRNA_sel"]'), $('select[name="tRNA_ext"]'), $('select[name="tRNA_3pm"]'), $('select[name="tRNA_5pm"]'), $('input[name="tRNA_3val"]'), $('input[name="tRNA_5val"]'));
      $('#tRNAcode').val(tRNA_code);
      $('#sigexcludelist').val($('#sig_exclude').val());
      
      var cgff=$.param($('input[name="customgff"]'));
      cgff=cgff.replace(/customgff=/g,"");
      cgff=cgff.replace(/&/g,",");
      $('#customgfflist').val(cgff);
      
      return(retval);
      });
      });
      
      //jQuery(document).ready(function(){
      //$(".imgbrowse").click( function(e) {
      //$('#Gtree').css( {position:"absolute", top:e.pageY-200, left: e.pageX});
      //});
      //})
      
      //$(document).ready(function(){
      // hide browser onload
      //cacheArbo();
      //});
      
      $(document).ready(function(){
      $('#rmskfulllength').click (function (){
      var thischeck = $(this);
      if (thischeck.is (':checked')){
      $('.rmsk_options').show();
      }else{
      $('.rmsk_options').hide();
      }
      });
      });

    </script>
  </head>
  
  <body>
    <div id="container">
      <div id="top" align="center">
	<table  id="header"><tr>
	    <td width=200px align="left"><a style="color:white" href="http://ncpro.curie.fr/"><img src="images/ncPRO_logo.png"></a></td>
	    <td id="title" align='center'><b>Annotation and Profiling of ncRNAs from smallRNA-seq</b></td>
	    <!-- <td width=200px align="right"><img src="images/IC.gif"</td>-->
	</tr></table>
      </div>
            
      <div id="tabs">
	<ul>
	  <li><a href="#tabs-1">Run Analysis</a></li>
	</ul>
	
	<div class="content" id="tabs-1">
	  
	  <div id="alertError"></div>
<?php  
   /********************************************************/
   /** Check all files required for http and cgi
   /********************************************************/
   $config_error=0;

   /* System */
   if ( ! is_link("./install_dir") || ! is_file("./install_dir/bin/ncPRO-seq")){
   print "<script>$('#alertError').append('Error : Link to installation dir not found. Please, check the ncPRO installation<br>');</script>";
   $config_error=1;
   }
   
   if (! is_link("./output") || ! is_writable("./output")){
   print "<script>$('#alertError').append('Error : Output folder not found or not writable<br>');</script>";
   $config_error=1;
   }

   if (! is_file('config_html.inc')){
   print "<script>$('#alertError').append('Error : configuration file \'config_html.inc\' not found in the html directory. Please check the ncPRO web installation<br>');</script>";
   $config_error=1;
   }
   
   /*CGI*/
   if (!defined('CGI_DIR')){
   print "<script>$('#alertError').append('Error : CGI_DIR variable undefined. Please check the \'config_html.inc\' config file<br>');</script>";
   $cgi_dir='';
   $config_error=1;
   }else{
   $cgi_dir=constant('CGI_DIR');
   }

   //print "CGI=$cgi_dir";

   if ( ! is_dir($cgi_dir)){
   print "<script>$('#alertError').append('Error : CGI_DIR not found. Please check the ncPRO web installation<br>');</script>";
   $config_error=1;
   }else if(!is_file($cgi_dir."/runncPRO.cgi") || !is_executable($cgi_dir."/runncPRO.cgi")){
   print "<script>$('#alertError').append('Error : \'runncPRO.cgi\' not found in CGI_DIR folder or not executable<br>');</script>";
   $config_error=1;
   }
   
   if ((preg_match("/CGI/",$cgi_dir) == 0) && (preg_match("/cgi/",$cgi_dir) == 0)){
   print "<script>$('#alertError').append('Warning : The CGI_DIR path not appears to be a valid cgi path. See the manual for more details<br>');</script>";
   $config_error=1;
   }

   
   /*Set Action form URL*/
   if (basename($cgi_dir) == "cgi-bin" || basename($cgi_dir) == "CGI-Executables"){
   $actionform="/cgi-bin/runncPRO.cgi";
   }else{
   $exp=explode("/",$cgi_dir);

   $i=0;
   while ($exp[$i] != "cgi-bin" && $exp[$i] != "CGI-Executables"  && $i<=count($exp)){
   $i++;
   }
   $actionform="/cgi-bin/".implode("/",array_slice($exp,$i+1))."/runncPRO.cgi";
   }
   
   /* Annotation */
   $rfam_item_file="./install_dir/annotation/rfam_items.txt";
   if (file_exists($rfam_item_file)) {
   $lines = file($rfam_item_file);
   $rfam_options="<option>ACA_snoRNA<option>CD_snoRNA";
   foreach ($lines as $lineNumber => $lineContent){
   $rfam_options.="<option>".rtrim($lineContent);
  }
  }else{
  print  "<script>$('#alertError').append('Error : Cannot load items table \'$rfam_item_file\'<br>');</script>";
  $config_error=1;
  }
  
  $rmsk_item_file="./install_dir/annotation/rmsk_items.txt";
  if (file_exists($rmsk_item_file)) {
  $lines = file($rmsk_item_file);
  $rmsk_options=""; 
  foreach ($lines as $lineNumber => $lineContent){
  $rmsk_options.="<option>".rtrim($lineContent);
  }
  }else{
  print  "<script>$('#alertError').append('Error : Cannot load items table \'$rmsk_item_file\'<br>');</script>";
  $config_error=1;
  }
   
  $gdir="./install_dir/annotation";
  $counter=0;
  if ($handle = opendir($gdir)) {
  while (false !== ($entry = readdir($handle))) {
  if ($entry != "." && $entry != ".." && $entry != "parseAnnotationFiles") {
  if (is_dir($gdir."/".$entry) === true){
  $counter++;
  }
  }
  }
  }
  closedir($handle);
  if ($counter == 0){
   print  "<script>$('#alertError').append('Error : No reference genome found in the annotation folder. <br>Please download you favorite annotation in <a href=\"http://sourceforge.net/projects/ncproseq/files/annotation/\" target=\"_blank\">the ncPRO website</a><br>');</script>";
  $config_error=1;
  }

  ?>
	  
	  <!--<form action="/cgi-bin/runncPRO.cgi" method="POST" name="pipForm" id="pipForm">-->
	  <!--<form action=<? print dirname($_SERVER['SCRIPT_URI'])."/cgi-bin/runncPRO.cgi" ?> method="POST" name="pipForm" id="pipForm">-->
	  <form action=<? print $actionform ?> method="POST" name="pipForm" id="pipForm">
	    
	    <input type="hidden" name="ncRNAcode" id="ncRNAcode" value=""/> 
	    <input type="hidden" name="rmskcode" id="rmskcode" value=""/> 
	    <input type="hidden" name="miRNAcode" id="miRNAcode" value=""/> 
	    <input type="hidden" name="tRNAcode" id="tRNAcode" value=""/> 
	    <input type="hidden" name="premiRNAcode" id="premiRNAcode" value=""/> 
	    <input type="hidden" name="selfileslist" id="selfileslist" value=""/> 
	    <input type="hidden" name="customgfflist" id="customgfflist" value=""/> 
	    <input type="hidden" name="sigexcludelist" id="sigexcludelist" value=""/> 
	    
	    Please, select the part of the pipeline you want to run and set the different parameters accordingly.<br><br>
	    <!-- GET INPUT DATA -->
	    <p class='intro'><b>Data Pre-processing</b></p>
	    <div id="data">
	      <b>Input data file(s) :</b><br>
	      
	      Select the input data files you want to analyse. By selecting a folder all the <b>fastq/fa/csfasta/bam</b> files will be considered as input files. The mapping option will be accessible only for non .bam input files.<br>
	      Otherwise, the input files can be imported manually.<br><br>
	      <table id="selfilestable"><tr><td>
		    <input name="selfiles" id="selfiles1" style="width:400px"/>
<!--<a onClick="javascript:setPos()" style="color: white" href="javascript:openArbo('selfiles1','<?print $browse?>');"><img class="imgbrowse" src="images/folder.png" /></a>--><button type="button" onclick="javascript:addFileRow('selfilestable','selfiles')">+</button>
	      </td></tr></table>
	      
	      <b>Organism :</b><br>
	      Please, select the genome reference. All the samples have to belong to the same species.
	      <select name="org" id="org" onchange="javascript:setbowtieindex();">
	     	<?
		   
		   $dir="./install_dir/annotation";
		   if ($handle = opendir($dir)) {
		   while (false !== ($entry = readdir($handle))) {
            	   if ($entry != "." && $entry != ".." && $entry != "parseAnnotationFiles") {
		   if (is_dir($dir."/".$entry) === true){
                   print "<option value='$entry'>$entry</option>";
		   }
		   }
		   }
		   closedir($handle);
		   }else{
		   print "<option value=''>Annotation files not found</option>";
		   }
		   

		   /*
	     	   $lines = file('data/annot_list.txt');
	     	   foreach ($lines as  $val) {
		   $val=rtrim($val);
		   $vals=preg_split("/ - /",$val);
	     	   print "<option value='$vals[1]'>$val</option>";
	     	   }
		   */
	     	   ?>
	      </select><br>
	      <br><input type=checkbox name="group" checked><b>Group reads ?</b><br>This option allow to decrease a lot the size of the data. All the reads corresponding to the same sequence are merged.<br><br>
	    </div>
	    
	    	    
	    <!-- SET PARAMETERS -->
	    <div id="config">
	    <p class='intro'><b>Reads Alignment</b></p>

	      <b><input type=checkbox onclick="javascript:showParameters(this, 'mapping_par');" name="domapping"> Bowtie Mapping</b>
	      
	      <div id="mapping_par"  class="confdiv"> Align reads with the Bowtie aligner program.
	      	Please look at <a href="http://bowtie-bio.sourceforge.net/manual.shtml" target=_blank>Bowtie manual</a> for details about the options.<br><br>
		<b>Bowtie pre-built index</b><br>Please, specified the basename of the index file to be searched in the Bowtie index folder. <br>
	      	For color space mapping (<b>SOLiD</b>) : <input name="bowtie_index_c" id="bowtie_index_c" style="width:200px" value="mm9_c"/> <br>and/or for base space mapping (<b>454/SOLEXA</b>) : <input name="bowtie_index" id="bowtie_index" style="width:200px" value="mm9"/><br><br>
	      	<b>Bowtie multithreading option</b><br>Please, enter the number the number of processors/cores available :
	      	<input name="ncpu" id="ncpu" style="width:20px" value="1"/><br><br>
		
	      	<b>SOLiD mapping</b><br>
	      	Number of mismatches <input type="text" name="mm_cs" value="2" style="width:50px" /><br>
	      	Maximum number of reportable alignments <input type="text" name="rep_cs" value="100" style="width:50px"/><br><br>
		
	      	<b>SOLEXA mapping</b><br>
	      	Quality value threshold <input type=text name="mm_sx" value="50" style="width:50px"/><br>
	      	Maximum Number of reportable alignments <input type="text" name="rep_sx" value="100" style="width:50px"/><br>
	      	Fastq format <select name="fastqformat_sx"><option value="solexa1.3">solexa1.3<option value="solexa">solexa<option value="phred33">phred33</select><br><br>
		
	      	<b>454 mapping</b><br>
	      	Number of mismatches <input type="text" name="mm_454" value="2" style="width:50px" /><br>
	      	Maximum number of reportable alignments <input type="text" name="rep_454" value="100" style="width:50px"/><br>
	      </div>
	      
	      <br><input type=checkbox name="mapstat"><b> Generate mapping statistics</b> (reads length, quality, and mapping overview)<br><br>

	      <p class='intro'><b>Overview</b></p>
	      <input type=checkbox name="readover"><b> Generate reads annotation overview</b>
	      <br><input type=checkbox name="rfamover"><b> Generate annotation overview for ncRNAs from RFAM</b>
              <br><input type=checkbox name="rmskover"><b> Generate annotation overview for genomic repetitive regions</b>


	      	      <br><br><p class='intro'><b>ncRNAs Profiling</b></p>
	      <b><input type=checkbox onclick="javascript:showParameters(this, 'matmir_par');" name="domir"> mature miRNA annotation</b>
	      <div id="matmir_par"  class="confdiv"> Annotate mapped reads against mature miRNAs from miRbase.<br><br>
	      	<select class="selfoc"  name="miRNA_sel"><option>miRNA</select><script type="text/javascript">oeist('miRNA');</script>
	      </div>
	      
	      <br><b><input type=checkbox onclick="javascript:showParameters(this, 'premir_par');" name="dopmir"> pre-miRNA annotation</b>
	      <div id="premir_par"  class="confdiv"> Annotate mapped reads against precursor miRNA from miRbase.<br><br>
	      	<select class="selfoc"  name="premiRNA_sel"><option>premiRNA</select><script type="text/javascript">oeist('premiRNA');</script>
	      </div>
	      
	      <br><b><input type=checkbox onclick="javascript:showParameters(this, 'tRNA_par');" name="dotRNA"> tRNA annotation</b>
	      <div id="tRNA_par"  class="confdiv"> Annotate mapped reads against tRNA from UCSC database.<br><br>
	      	<select class="selfoc"  name="tRNA_sel"><option>tRNA</select><script type="text/javascript">oeist('tRNA');</script>
	      </div>
	      
	      <br><b><input type=checkbox onclick="javascript:showParameters(this, 'rfam_par');" name="dorfam"> non-coding RNA annotation from RFAM</b>
	      <div id="rfam_par"  class="confdiv"> Annotate mapped reads against Rfam database. Select one or several RFam entry to focus on.<br><br>
	      	<table id="rfamtable"><tr><td>
	      	      <select class="selfoc"  name="ncrna_sel">
	      		<?  print $rfam_options;  ?>
                      </select>
                      <script type="text/javascript">oeist('ncrna');</script><button type="button" onclick="javascript:addncrnaRow('rfamtable','ncrna','<? print $rfam_options ?>')">+</button>
		      <button type='button'  class='delete' onclick="javascript:rmRow('rfamtable')">-</button>
		</td></tr></table>
              </div>
	      
	      
	      <br><br><p class='intro'><b>Repeats Profiling</b></p>
	      <b><input type=checkbox onclick="javascript:showParameters(this, 'rmsk_par');" name="dormsk"> non-coding RNA profiling from RepeatMasker</b>
	      <div id="rmsk_par" class="confdiv"> 
		Annotate mapped reads against RepeatMasker database.<br><br>
	      	<input type=checkbox  name="rmskfulllength" id="rmskfulllength" checked> Focus only on full length elements <!--onclick="javascript:oeist_disable('rmsk');"-->
		<table id="rmsktable"><tbody>
	      	  <tr><td><select class="selfoc" name="rmsk_sel">
	      		<?  print $rmsk_options;  ?>
	      	      </select><script type="text/javascript">oeist('rmsk');</script>
		      <button type="button" onclick="javascript:addrmskRow('rmsktable','rmsk','<? print $rmsk_options ?>')">+</button>
		      <button type='button'  class='delete' onclick="javascript:rmRow('rmsktable')">-</button></td></tr></tbody></table>
	      </div>
	      
	      <br><br><b><input type=checkbox onclick="javascript:showParameters(this, 'custom_par');" name="docustom"> Other custom gff file(s)</b>
	      <div id="custom_par"  class="confdiv">Select additional file(s) to use for reads annotation (gff3 format required)<br><br>
	      	<table id="customFiletable"><tr><td>
		      <input name="customgff" id="customgff1" style="width:400px"/>
		      <button type="button" onclick="javascript:addFileRow('customFiletable','customgff')">+</button>
	      	</td></tr></table>
	      </div>
	      
	      <br><b><input type=checkbox onclick="javascript:showParameters(this, 'ucsc_par');" name="doucsc"> Genome Track options</b>
	      <div id="ucsc_par"  class="confdiv">Select the parameters for building the UCSC track files.<br><br>
	      	Minimum reads size <input type="text" name="ucsc_mins" value="19"  style="width:50px"/><br>
	      	Maximum reads size <input type="text" name="ucsc_maxs" value="26"  style="width:50px"/><br>
	      	Minimum number of alignments <input type="text" name="ucsc_minrep" value="1"  style="width:50px"/><br>
	      	Maximum number of alignments <input type="text" name="ucsc_maxrep" value="20" style="width:50px"/><br>
	      </div>
	      
	      <br><b><input type=checkbox onclick="javascript:showParameters(this, 'sig_par');" name="dosig"> Search enriched region</b>
	      <div id="sig_par" class="confdiv">Settings to extract regions not annotated as known genomic features, but significantly enriched with reads.<br><br>
	      	<b>Select the subset of reads to work on :</b>
	      	Minimum reads size <input type="text" name="sig_mins" value="19"  style="width:50px"/><br>
	      	Maximum reads size <input type="text" name="sig_maxs" value="26"  style="width:50px"/><br>
	      	Minimum number of alignments <input type="text" name="sig_minrep" value="1"  style="width:50px"/><br>
	      	Maximum number of alignments <input type="text" name="sig_maxrep" value="20" style="width:50px"/><br><br>
		
	      	<b>Exclude reads annotated on : </b>(multiple selection allowed)
	      	<table id="excludetable"><tr><td>
	      	      <select multiple="multiple" id="sig_exclude"><option>Gene<option>pre-miRNA (miRBase)<option>mature miRNA (miRBase)<option>ncRNA (RFAM)<option>Repeats (Reapeatmasker)</select>
	      	</td></tr></table><br>
		
	      	<b>Define the statistical model :</b><br>
	      	Statistical model to simulate reads distribution <select name="sig_mod"><option checked>NB.ML<option>NB.012<option>Poisson</select><br>
	      	Windowing size <input type="text" name="sig_wst" value="100000"/><br>
	      	Windowing step <input type="text" name="sig_wsi" value="50000"/><br>
	      	Pvalues threshold <input type="text" name="sig_pv" value="0.0001"/><br>
	      </div><br>
	      <!--<div id="wrapper">&nbsp;</div>-->
	      
	      <br><br>
	      Email adress : <input type="text" name="umail" value=""  style="width:200px"/><br><br>
	     
	      <? 
		 if ($config_error==0){
		 print "<input type='submit'  value='Run analysis' /></center><br><br>";
		 }else{
		 print "<input type='submit'  value='Run analysis' disabled='disabled' /></center><br><br>";
		 }
		 ?>

</div>


</form>

<!--
<div id="Gtree" class="Gtree">
  <div class=ArboHaut>
    <a href="javascript:cacheArbo();"><img src=images/close.png align=right class=img></a>
    <a href="javascript:arboBack();"><img src=images/back.png align=right class=img></a>
    <input type=text size=55 align=center id=pathMan class=pathMan></input>&nbsp;<a href="javascript:call_serverA.launchA('pathMan','tree');"><img src=images/openFolder.png class=img></a>
    <input type="submit"  onclick="javascripts:validateSelection()" value="OK" />
  </div>
  <div id="tree" class="tree">
  </div>
</div>
--> 

<!-- Le reste peut être mis n'importe ou dans le html (les champs sont hidden ou c'est la fenêtre de parcours de l'arborescence qui a une position absolute -->
<!--<input type=hidden id=champBrowse></input>-->
<!--<input type=hidden id=pathBack></input>-->
<!-- Répertoire de départ au click sur le bouton browse (ici /) 
<input type=hidden id=base value="<?if (defined(INSTALL_DIR)){print INSTALL_DIR."/testdata";}else{print "/";}?>"></input>-->
</div>
<div id="bottom">
  &copy; Institut Curie - 2012 | Last modified: January 19, 2012 | <a href="mailto:bioinfo-ncproseq@curie.fr" title="contact us">Contact us</a>
</div>
<div style="margin-top:5px; height: 70px;">
  <table id="partner" align=center><tr>
      <td><img src="images/logo_curie.gif" height=75/></td>
      <td><img src="images/logo_cnrs.jpg"height=50/></td>
      <td><img src="images/inserm_logo.jpg" height=60/></td>
      <td><img src="images/ENS_logo.gif" height=50/></td>
      <td><img src="images/IBMP_logo.jpg" height=40/></td>
      <td><img src="images/eth_logo.gif" height=80/></td>
  </tr></table>
</div>

</div>
</div>
</body>
</html>
