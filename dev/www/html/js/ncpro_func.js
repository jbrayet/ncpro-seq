function rmRow(tab){
    /*
    alert($('#'+tab+' tr').length);
    $('#'+tab+' tr button.delete').click(function(){
	alert("toto");
	$(this).parents('tr').remove();return false;
    });
*/
    if ($('#'+tab+' tr').length > 1){
	$('#'+tab+' tbody:last tr:last').remove();
    }
    //$(this).parents('tr').remove();

}

function addFileRow(tab, name){
    var curind = $('#'+tab+' tr').length;
    curind++;
    $('#'+tab+' tr:last').after("<tr><td><input name='"+name+"' id='"+name+curind+"' style=\"width:400px\"><button type=\"button\" onclick=\"javascript:addFileRow('"+tab+"','"+name+"')\">+</button><button type=\"button\" onclick=\"javascript:rmRow('"+tab+"','"+name+"')\">-</button></td></tr>");
}

function addncrnaRow(tab, rname, opts){
    $('#'+tab+' tr:last').after("<tr><td><select class=\"selfoc\" name='"+rname+"_sel'>"+opts+"</select><select name='"+rname+"_ext' onchange=\"setpm(this,'"+rname+"');\"><option>Extend the annotation<option>Shorten the annotation<option>Focus on the 5' end<option>Focus on the 3' end</select> from <select name='"+rname+"_3pm' ><option>+</select><input type='text' value='0' name='"+rname+"_3val' style=\"width:50px\" /> to <select name='"+rname+"_5pm' ><option>+</select><input type='text' value='0' name='"+rname+"_5val' style=\"width:50px\"/></td></tr>");
}

function addrmskRow(tab, rname, opts){
    $('#'+tab+' tbody:last').append("<tr><td><select class=\"selfoc\" name='"+rname+"_sel'>"+opts+"</select><div class='"+rname+"_options' style=\"display:inline;\"><select name='"+rname+"_ext' onchange=\"setpm(this,'"+rname+"');\"><option>Extend the annotation<option>Shorten the annotation<option>Focus on the 5' end<option>Focus on the 3' end</select> from <select name='"+rname+"_3pm' ><option>+</select><input type='text' value='0' name='"+rname+"_3val' style=\"width:50px\"/> to <select name='"+rname+"_5pm' ><option>+</select><input type='text' value='0' name='"+rname+"_5val' style=\"width:50px\"/></div></td></tr>");
    
    var thischeck = $('#rmskfulllength');
    if (! thischeck.is (':checked')){
      $('.rmsk_options').hide();
    }
}

function importdata(){
    document.getElementById('wrapper').style.display="none"; 
}

function showParameters(cbox, parid){
    if (cbox.checked==true){
	$('#'+parid).show(400);
    }else{
	$('#'+parid).hide(500);
    }
}

function oeist(rname){
    document.write("<div class='"+rname+"_options' style=\"display:inline\"><select name='"+rname+"_ext' onchange=\"setpm(this,'"+rname+"');\"><option>Extend the annotation<option>Shorten the annotation<option>Focus on the 5' end<option>Focus on the 3' end</select> from <select name='"+rname+"_3pm' ><option>+</select><input type='text' value='0' name='"+rname+"_3val' style=\"width:50px\"/> to <select name='"+rname+"_5pm' ><option>+</select><input type='text' value='0' name='"+rname+"_5val' style=\"width:50px\"//></div>");
}

function setpm(selvar,pm){
    var rownum = $(selvar).closest('tr').index();
    if (rownum == -1){rownum=0}
    var s1=document.getElementsByName(pm+"_5pm")[rownum];
    s1.options.length=0;
    var s2=document.getElementsByName(pm+"_3pm")[rownum];
    s2.options.length=0;
    
    if (selvar.options[0].selected == true){
	s1.add(new Option("+", "+"),  null);
	s2.add(new Option("+", "+"),  null);
    }else if (selvar.options[1].selected == true){
	s1.add(new Option("-", "-"),  null);
	s2.add(new Option("-", "-"),  null);
    }
    else if (selvar.options[2].selected == true || selvar.options[3].selected == true){
	s1.add(new Option("+", "+"),  null);
	s1.add(new Option("-", "-"), s1.options[0]);
	s2.add(new Option("+", "+"),  null);
	s2.add(new Option("-", "-"), s2.options[0]);
    }
}

function getExtendCode(sel, ext, pm3, pm5, val3, val5){
    var maincode="";
    for (i=0; i<sel.length; i++){
	var code=sel[i].value;
	if (ext[i].value=="Extend the annotation"){
	    code=code+"_e";
	}else if (ext[i].value=="Shorten the annotation"){
	    code=code+"_i";
	}else if (ext[i].value=="Focus on the 5' end"){
	    code=code+"_s";
	}else if (ext[i].value=="Focus on the 3' end"){
	    code=code+"_t";
	}else{
	    $('#alertError').append("Error : Extension code not valid<br>");
	}
	code=code+"_"+pm3[i].value+val3[i].value+"_"+pm5[i].value+val5[i].value;
	if (maincode=="")
	    maincode=code;
	else
	    maincode=maincode+","+code;
    }
    return maincode;
}

function setbowtieindex(){
    if($('#org').val() == "TAIR9"){
	$('#bowtie_index').val('a_thaliana');	
	$('#bowtie_index_c').val('a_thaliana_c');	
    }else if($('#org').val() == "dm3"){
	$('#bowtie_index').val('d_melanogaster_dm3');	
	$('#bowtie_index_c').val('d_melanogaster_dm3_c');	
    }else if($('#org').val() == "c6"){
	$('#bowtie_index').val('c_elegans_c6');	
	$('#bowtie_index_c').val('c_elegans_c6_c');	
    }else{
	$('#bowtie_index').val($('#org').val());
	$('#bowtie_index_c').val($('#org').val()+"_c");
    }
}

