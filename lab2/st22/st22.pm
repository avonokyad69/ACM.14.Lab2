package ST22;
use strict;
use Encode 'from_to';

my $selfurl;
my $stNum;
my %myRoomItems;

sub st22
{
	my ($q, $global) = @_;
	my ($q, $global) = @_;
	my $cgiAPI = new CGI;
	$stNum = $global->{student};
	$selfurl = $global->{selfurl};
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
						    	<li> <a href="$selfurl?student=$stNum&action=0" > Show all </a>	</li>
						    	<li> <a href="$selfurl?student=$stNum&action=8" > Add element </a> </li>
						    	<li> <a href="$selfurl?student=$stNum&action=9" > Modify element </a> </li>
						    	<li> <a href="$selfurl?student=$stNum&action=10"> Delete element </a> </li>
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
			    <a href="$selfurl">Back</a><BR>
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

	if(defined $action) {
		loadFromFile();
		$arr[$action]->($cgiAPI);
		saveToFile();
	};


};

sub addItemForm
{
	print qq~<FORM action="$selfurl" name = Save>
				Element name:<BR>
			    <input type=text width = 40 name = "nameEl"> <BR>
			    Element color:<BR>
			    <input type=text width = 40 name = "colorEl"> <BR>
			    Element description:<BR>
			    <Textarea name = "descriptionEl" rows = 12 cols = 50 ></Textarea><BR>
			    <INPUT TYPE="HIDDEN" NAME="action" VALUE ="1"/>
			    <INPUT TYPE="HIDDEN" NAME="student" VALUE =$stNum/>
			    <input type = submit name = "btn" value = "Save"/><BR>
		    </FORM>~;
};

sub updItemForm
{
	print qq~<FORM action="$selfurl" name = Upd>
			Element name:<BR>
		    <input type=text width = 40 name = "nameEl"> <BR>
		    Element color:<BR>
		    <input type=text width = 40 name = "colorEl"> <BR>
		    Element description:<BR>
		    <Textarea name = "descriptionEl" rows = 12 cols = 50 ></Textarea><BR>
	    	<INPUT TYPE="HIDDEN" NAME=action VALUE ="2">
	    	<INPUT TYPE="HIDDEN" NAME="student" VALUE =$stNum/>
		    <input type = submit name = btn  value = "Save changes"/><BR>
	    </FORM>~;
};


sub delItemForm
{
	print qq~	<FORM action="$selfurl" name = DelEl>
					Element name:<BR>
				    <input type=text width = 40 name = "nameEl">
				    <INPUT TYPE="HIDDEN" NAME=action VALUE ="3"> 
				    <INPUT TYPE="HIDDEN" NAME="student" VALUE =$stNum/>
				    <input type = submit name = btn value = "Delete"/><BR>
			    </FORM>~;
};






sub addItem
{
	my ($params) = @_;
	my $name = $params->param("nameEl");
	my $color = $params->param("colorEl");
	my $details = $params->param("descriptionEl");
	$myRoomItems{$name} = { color=> $color, details=> $details};
};

sub deleteItem
{
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
			$resStr .=$itemKey." of element: ".$itemInfo."; "
		};
		$resStr .= "</li>";
	};
	$resStr .= "</ul>";	
	print $resStr;
};

sub saveToFile
{
		my %buffHash;
		dbmopen(%buffHash,"ShishkinaDB",0644) || die "Error open to file!";
		my $bufStr = undef();
		
		while((my $name,my $item) = each %myRoomItems)
		{
			$bufStr = undef();
			foreach my $itemKey (keys %{$myRoomItems{$name}})
			{
				$bufStr = $bufStr.${$myRoomItems{$name}}{$itemKey}.";";
			};		
			$buffHash{$name} = $bufStr;
		};
		my @bufArr = %buffHash;
		dbmclose(%buffHash);		
	#};
};

sub loadFromFile
{
		my %buffHash = undef();
		my $bufStr;
		dbmopen(%buffHash,"ShishkinaDB",0644) || die "Error open to file!";

		while((my $name,my $item) = each %buffHash)
		{
			my @buf12 = undef();
			@buf12 =  split(/;/, $buffHash{$name}); 
			$myRoomItems{$name} = {color => @buf12[0], details =>  @buf12[1]};
		};
		dbmclose(%buffHash);
};

sub saveToDB
{
	return 1;
};

sub loadFromDB
{
	return 1;
}


