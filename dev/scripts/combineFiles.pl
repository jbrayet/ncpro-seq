# Copyleft ↄ⃝ 2012 Institut Curie
# Author(s): Jocelyn Brayet, Laurene Syx, Chongjian Chen, Nicolas Servant(Institut Curie) 2012 - 2015
# Contact: bioinfo.ncproseq@curie.fr
# This software is distributed without any guarantee under the terms of the GNU General
# Public License, either Version 2, June 1991 or Version 3, June 2007.

#The script is used to combine multiple files side by side

use strict;

my %combine_hit;
my $total_col_num=0;
foreach (@ARGV){
    my $cur_file=$_;
    open(IN,"$cur_file") || die;
    my %name_checked;
    my $cur_col_num=0;
    while(<IN>){
	chomp $_;
	if(/^(\S+)\s+(.*)/){
	    my ($name,$hits)=($1,$2);
	    my @cur_col=split(/\t/,$hits);
	    $cur_col_num=$#cur_col+1;
	    if($combine_hit{$name}){
		$combine_hit{$name}.="\t" . $hits;
}
	    else{
		my $fill_zero="\t0"x$total_col_num;
		$combine_hit{$name}.=$fill_zero . "\t" . $hits;
}
	    $name_checked{$name}=1;
}
}
    $total_col_num+=$cur_col_num;

    foreach my $id (keys %combine_hit){
	if(!$name_checked{$id}){
	    my $fill_zero="\t0"x$cur_col_num;
	    $combine_hit{$id}.=$fill_zero;
}
}
    close(IN);
}

print "idx",$combine_hit{"idx"},"\n" if ($combine_hit{"idx"});
foreach my $id (sort {$a<=>$b} keys %combine_hit){
    next if ($id eq "idx");
    print $id,$combine_hit{$id},"\n";
}
