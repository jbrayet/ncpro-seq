var current_sel;
var current_filename;
var cgi_path;

function validateSelection(){
    document.getElementById('Gtree').style.display="none";
    var field = document.getElementById('champBrowse').value;
    var chemin=current_filename;
    if (current_filename != 'undefined'){
	if (document.getElementById("pathManH").value == "/")
	    var chemin=document.getElementById("pathManH").value+current_filename;
	else
	    var chemin=document.getElementById("pathManH").value+"/"+current_filename;
    }
    else
	var chemin=document.getElementById("pathManH").value;
    document.getElementById(field).value = chemin;
}


function fileSelect(inlink, filename){
    if (typeof(current_sel) != 'undefined')
	current_sel.style.backgroundColor="";
    inlink.style.backgroundColor="darkgray";
    current_sel=inlink;
    current_filename=filename;
}

function cacheArbo(){
	document.getElementById('Gtree').style.display="none";
}

function openArbo(champ, cpath){
    cgi_path=cpath;
    document.getElementById('Gtree').style.display="";
    fillInput('base');
    document.getElementById('champBrowse').value=champ;
    call_serverA.launchA('base', 'tree');
}

function fillField(file){
    document.getElementById('Gtree').style.display="none";
    var field = document.getElementById('champBrowse').value;
    var chemin=document.getElementById(file).value;
    document.getElementById(field).value = document.getElementById(file).value;
    
}
		
function arboBack(){
	var pathBack = document.getElementById('pathManH').value;
	var expressionBack = new RegExp ("(.+)\/.+$");
	var resultat = expressionBack.test(pathBack);
	expressionBack.exec(pathBack);
	if(resultat==true){var pathBack2=RegExp.$1;}
	else{var pathBack2="/";}
	document.getElementById('pathBack').value = pathBack2;
	call_serverA.launchA('pathBack','tree');
	fillInput('pathManH');
}
	
function fillInput(chp){
	document.getElementById('pathMan').value = document.getElementById(chp).value;
}

function CallServerA (){
	this.xhr_objectA;
	this.server_responseA;
	this.createXMLHTTPRequestA = createXMLHTTPRequestA;
	this.sendDataToServerA = sendDataToServerA;
	this.displayAnswerA = displayAnswerA;
	this.launchA = launchA;
}

// create XMLHttpRequest object
function createXMLHTTPRequestA(){
	this.xhr_objectA = null;
	if(window.XMLHttpRequest){
	   this.xhr_objectA = new XMLHttpRequest();
	}else if(window.ActiveXObject){
	   this.xhr_objectA = new ActiveXObject("Microsoft.XMLHTTP");
	}else{
	   alert("Your browser doesn't provide XMLHttprequest functionality");
	   return;
	}
}

// send data to server and get response in sync mode through server_response
function sendDataToServerA (data_to_send){
	var xhr_objectA = this.xhr_objectA;
	//xhr_objectA.open("POST", "../../cgi-bin/browse.pl", false);
    xhr_objectA.open("POST", cgi_path, false);
	xhr_objectA.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
	xhr_objectA.send(data_to_send);
	if(xhr_objectA.readyState == 4){	
		this.server_responseA = xhr_objectA.responseText;
	}
}

// send server_response in DOM tree
function displayAnswerA (to){	
	document.getElementById(to).innerHTML = this.server_responseA;
}

function launchA (from,to){
    current_filename='undefined';
    this.sendDataToServerA(document.getElementById(from).value);
    this.displayAnswerA(to);
}

var call_serverA = new CallServerA();
call_serverA.createXMLHTTPRequestA();