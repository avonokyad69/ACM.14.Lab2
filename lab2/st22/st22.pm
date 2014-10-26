package ST22;
use strict;

my %myRoomItems;
sub st22
{
	my ($q, $global) = @_;
	print "Content-type: text/html\n\n";
	print qq~
			<HTML>
			    <HEAD>
			       <TITLE>2nd lab</TITLE>
			    </HEAD>
			    <BODY>
				    <hr>
					    <menu type="toolbar">
					    	<ul type="square">
						    	<li> <a href="/cgi-bin/Shishkina2ndLab.pl?action=0" > Show all </a>	</li>
						    	<li> <a href="/cgi-bin/Shishkina2ndLab.pl?action=8" > Add element </a> </li>
						    	<li> <a href="/cgi-bin/Shishkina2ndLab.pl?action=9" > Modify element </a> </li>
						    	<li> <a href="/cgi-bin/Shishkina2ndLab.pl?action=10"> Delete element </a> </li>
						    	<li> <a href="/cgi-bin/Shishkina2ndLab.pl?action=6" > Save to DB </a> </li>
						    	<li> <a href="/cgi-bin/Shishkina2ndLab.pl?action=7" > Load from DB </a> </li>
						    </ul>
					    </menu>
					 <hr>
				    <BR>
				    ~;

	mainFunc();

	print qq~
			    </BODY>
			    <footer>
			    Designed by: ShishkinaV (st22) <BR>
			    <a href="$global->{selfurl}">Back</a><BR>
			    </footer>
			</HTML>~;

	
	
};

1;

sub mainFunc
{
	my @arr = (\&showAllItems, \&addItem, \&updateItem, \&deleteItem, \&saveToFile, 
				\&loadFromFile, \&saveToDB, \&loadFromDB, \&addItemForm, \&updItemForm, \&delItemForm);
	

	my $cgiAPI = new CGI;
	my $action = $cgiAPI->param("action");
	#print $action."<BR>";
	#print $cgiAPI->query_string."<BR>";
	#print $cgiAPI->Dump."<BR>";

	#my @hash = %myRoomItems;
	#print "@hash"."<BR>";
	if(defined $action) {
		loadFromFile();
		$arr[$action]->($cgiAPI);
		saveToFile();
	};


};

sub addItemForm
{
	print qq~<FORM action="/cgi-bin/Shishkina2ndLab.pl" name = SaveAndUpd>
				Element name:<BR>
			    <input type=text width = 40 name = "nameEl"> <BR>
			    Element color:<BR>
			    <input type=text width = 40 name = "colorEl"> <BR>
			    Element description:<BR>
			    <Textarea name = "descriptionEl" rows = 12 cols = 50 ></Textarea><BR>
			    <INPUT TYPE="HIDDEN" NAME="action" VALUE ="1"/>
			    <input type = submit name = "btn" value = "Save"/><BR>
		    </FORM>~;
};

sub updItemForm
{
	print qq~<FORM action="/cgi-bin/Shishkina2ndLab.pl" name = SaveAndUpd>
			Element name:<BR>
		    <input type=text width = 40 name = "nameEl"> <BR>
		    Element color:<BR>
		    <input type=text width = 40 name = "colorEl"> <BR>
		    Element description:<BR>
		    <Textarea name = "descriptionEl" rows = 12 cols = 50 ></Textarea><BR>
	    	<INPUT TYPE="HIDDEN" NAME=action VALUE ="2">
		    <input type = submit name = btn  value = "Save changes"/><BR>
	    </FORM>~;
};


sub delItemForm
{
	print qq~	<FORM action="/cgi-bin/Shishkina2ndLab.pl" name = DelEl>
					Element name:<BR>
				    <input type=text width = 40 name = "nameEl">
				    <INPUT TYPE="HIDDEN" NAME=action VALUE ="3"> 
				    <input type = submit name = btn value = "Delete"/><BR>
			    </FORM>~;
};






sub addItem
{
	my ($params) = @_;
	my $name = $params->param("nameEl");
	my $color = $params->param("colorEl");
	my $details = $params->param("descriptionEl");
	print $name;
	print $color;
	print $details;
	$myRoomItems{$name} = { color=> $color, details=> $details};
};

sub deleteItem
{
	#print "deleteItem\n";
	my ($params) = @_;
	my $name = $params->param("nameEl");
	if(exists($myRoomItems{$name}))
	{	
		delete($myRoomItems{$name});
	}
	else
	{
		print "There is no elemet with name = ".$name."\n";
	};
};

sub updateItem
{
	my ($params) = @_;
	my $name = $params->param("nameEl");
	my $color = $params->param("colorEl");
	my $details = $params->param("descriptionEl");

	if(exists($myRoomItems{$name}))
	{
		$myRoomItems{$name} = {color=> $color, details=> $details};
	}
	else
	{
		print "There is no elemet with name = ".$name."\n";
	};
};

sub showAllItems
{
	my $resStr;
	$resStr .=  "<ul type=square>";
	while((my $name,my $item) = each %myRoomItems)
	{
		$resStr .= "<li>"."Name of element: " .$name."; ";
		while((my $itemKey,my $itemInfo) = each %{$myRoomItems{$name}})
		{
			#print "Item info: ".$itemKey." ".$itemInfo."<BR>";
			$resStr .=$itemKey." of element: ".$itemInfo."; "
		};
		$resStr .= "</li>";
	};
	$resStr .= "</ul>";	
	print $resStr;
};

sub saveToFile
{
	#print "<BR>"."saveToFile"."<BR>";
	#if (defined %myRoomItems){
		my %buffHash;
		dbmopen(%buffHash,"ShishkinaDB",0644) || die "Error open to file!";
		#%buffHash = undef();
		my $bufStr = undef();
		
		while((my $name,my $item) = each %myRoomItems)
		{
			$bufStr = undef();
			foreach my $itemKey (keys %{$myRoomItems{$name}})
			{
				$bufStr = $bufStr.${$myRoomItems{$name}}{$itemKey}.";";
				#print $bufStr."<BR>";
			};		
			#print $name.": ".$bufStr." ";
			$buffHash{$name} = $bufStr;
		};
		my @bufArr = %buffHash;
		dbmclose(%buffHash);		
	#};
};

sub loadFromFile
{
	#print "<BR>"."loadFromFile\n"."<BR>";
	#if (defined %myRoomItems){	

		my %buffHash = undef();
		my $bufStr;
		dbmopen(%buffHash,"ShishkinaDB",0644) || die "Error open to file!";

		while((my $name,my $item) = each %buffHash)
		{
			my @buf12 = undef();
			@buf12 =  split(/;/, $buffHash{$name}); 
			#print $name.": "."<BR>".$buffHash{$name}."<BR>";
			#print $name.": "."<BR>"."@buf12"."<BR>";
			#print $name.": "."<BR>".$item."<BR>";
			#foreach my $bufItem (@buf12)
			#{
				#my @hashArr = split(/:=/, $bufItem); 
				#print " "."@hashArr"." "."<BR>";
				#print "0: ".@buf12[0].";1: ".@buf12[1]." ";
			$myRoomItems{$name} = {color => @buf12[0], details =>  @buf12[1]};
			#};
		};
		dbmclose(%buffHash);
	#};
};

sub saveToDB
{
	return 1;
};

sub loadFromDB
{
	return 1;
}


