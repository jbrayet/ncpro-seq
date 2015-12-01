#!/usr/bin/perl

use strict;
use warnings;
use CGI;

#On crée notre objet qui initialise le CGI

package Ajax;

sub new
{
	my($classe) = shift;
	
	my $self = {};

	bless($self, $classe);
	
	$self->{CGI} = CGI->new();
	
	print $self->{CGI}->header('text/html;charset=UTF-8;q=0.9,*/*;q=0.8');
	
	return $self;
}

#Méthode qui nous permet de recevoir les données du client et les renvois sous forme de tableau

sub getDataFromClient
{
	my ($self) = shift;
	
	return $self->{CGI}->param("keywords");
}

#Méthode qui envoit des données au client

sub sendResultToClient
{
	my ($self, $data_to_send) = @_;
	
	print $data_to_send;
}

#Notre incroyable methode qui transforme du texte
sub change
{
	my ($self) = shift;
	
	my $result;
	
	my @texte = $self->getDataFromClient();
	
	foreach(@texte)
	{
		$result = $_;
	}	

	my $filename;
	my $path;
	my $dirname=$result;

	if($dirname=~/.+\/$/){chop($dirname);}

	my $paths="<input type=hidden value=$dirname id=pathManH></input>";
	if (-r $dirname){
	    opendir (DIR,$dirname) || die "can't opendir $dirname: $!";
	    while($filename = readdir(DIR)){
		if(($filename!~/^\./)&&($filename!~/~$/)){
		    if($dirname eq "/"){
			$path="/".$filename;
		    }
		    else{
			$path=$dirname."/".$filename;
		    }
		    
		    ##if($filename!~/.+\..+/){
		    if (-d $path){
			#$paths.="<input type=hidden id=$filename value=$path></input><div><img src=images/folder.png class=img>&nbsp;<a href=\"javascript:call_serverA.launchA('$filename','tree');fillInput('pathManH');\" class=ahref>$filename</a></div>";
			$paths.="<input type=hidden id=$filename value=$path></input><div><img src=images/folder.png class=img>&nbsp;<a ondblclick=\"javascript:call_serverA.launchA('$filename','tree');fillInput('pathManH');\" onclick=\"javascript:fileSelect(this, '$filename');\" onmouseover=\"this.style.cursor='pointer';\" class=ahref>$filename</a></div>";
		    }
		    else{
			#$paths.="<input type=hidden id=$filename value=$path></input><div><img src=images/file.png class=img>&nbsp;<a href=\"javascript:fillField('$filename');\" class=ahref>$filename</a></div>";
			$paths.="<input type=hidden id=$filename value=$path></input><div><img src=images/file.png class=img>&nbsp;<a ondblclick=\"javascript:fillField('$filename');\" onclick=\"javascript:fileSelect(this, '$filename');\" onmouseover=\"this.style.cursor='pointer';\" class=ahref>$filename</a></div>";
			
		    }
		}
	    }
	    
	    closedir(DIR);
	}else{
	    $paths="<font color='red'><b>Error : File $dirname is not readable by http user. Please check the rights accordingly.</b></font>";
	}
	$self->sendResultToClient($paths);
}

1;



## 	Le main    ##

my $ajax = Ajax->new();

$ajax->change();

