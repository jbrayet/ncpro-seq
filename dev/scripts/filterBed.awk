# Copyleft ↄ⃝ 2012 Institut Curie
# Author(s): Jocelyn Brayet, Laurene Syx, Chongjian Chen, Nicolas Servant(Institut Curie) 2012 - 2015
# Contact: bioinfo.ncproseq@curie.fr
# This software is distributed without any guarantee under the terms of the GNU General
# Public License, either Version 2, June 1991 or Version 3, June 2007.

BEGIN{FS="\t";OFS="\t"}
{
if(!min_len){
min_len=18
} 
if(!max_len){
max_len=26
} 
if(!min_copy){
min_copy=1
} 
if(!max_copy){
max_copy=1
} 
if(max_copy<min_copy){
max_copy=min_copy
} 
if(max_len<min_len){
max_len=min_len
}
seq_len=$3-$2
if(((strand && $6==strand) || (!strand)) && (seq_len>=min_len) && (seq_len<=max_len) && ($5<=max_copy) && ($5>=min_copy)){
split($4,rname,"_")
read_num=rname[length(rname)]
print $1,$2,$3,$4,read_num/$5,$6
}
}
