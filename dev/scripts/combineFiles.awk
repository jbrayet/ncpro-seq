#this script is used to combine columns from multiple files with the same first column

# Copyleft ↄ⃝ 2012 Institut Curie
# Author(s): Jocelyn Brayet, Laurene Syx, Chongjian Chen, Nicolas Servant(Institut Curie) 2012 - 2015
# Contact: bioinfo.ncproseq@curie.fr
# This software is distributed without any guarantee under the terms of the GNU General
# Public License, either Version 2, June 1991 or Version 3, June 2007.

#
BEGIN{FS="\t";OFS="\t";fidx=2;cur_n=0;}
{
if(NR==FNR){
    a[$1]=$0;
} 
if(NR>FNR){
    if(fidx<ARGIND){
	fidx=ARGIND;
	for(j in a){
	    n=split(a[j],arr,"\t");
	    for(x=1;x<=(cur_n-n);x++){
		a[j]=a[j]"\t"0;
	    }
	} 
    }
    if(fidx==ARGIND){
	if(a[$1]){
	    for(x=2;x<=NF;x++)
		a[$1]=a[$1]"\t"$x;
	    cur_n=split(a[$1],arr,"\t");
	} 
	else{
	    bk=0;
	    for(i=1;i<((NF-1)*(ARGIND-1));i++){
		bk=bk"\t0";
	    } 
	    a[$1]=$1"\t"bk; 
	    for(x=2;x<=NF;x++)
		a[$1]=a[$1]"\t"$x;
	    cur_n=split(a[$1],arr,"\t");
	}
    }
}
}
END{
    print a["idx"];
    for(j in a){
	n=split(a[j],arr,"\t");
	for(x=1;x<=(cur_n-n);x++){
	    a[j]=a[j]"\t"0;
	} 
	if(a[j]~/idx/){
#	    print a[j];
	}
	else{
	    if(a[j])
		print a[j]|"sort -n";
	}
    }
}
