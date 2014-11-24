package ST14;
use DBI;

use strict;
use Encode 'from_to';

my $selfurl;
my $myNum;
my %barcaPlayers;
my $global;
sub st14
{
	my ($q, $global) = @_;
	$myNum = $global->{student};
	$selfurl = $global->{selfurl};

	printH();
	printB($q);
	printF();
	return 1;
	
};

sub printH
{
	print "Content-type: text/html\n\n";
	print qq~
		<HTML>
		    <HEAD>
		       <TITLE>2nd lab</TITLE>
		    </HEAD>
			    ~;
};


sub printB
{
	my ($input) = @_;
	print	qq~
			    <BODY>
					    <menu type="toolbar">
						    	&#9675; <a href="$selfurl?act=show&student=$myNum" > Show all </a>	
						    	&#9675; <a href="$selfurl?act=addForm&student=$myNum" > Add element </a> 
						    	&#9675; <a href="$selfurl?act=updForm&student=$myNum" > Modify element </a> 
						    	&#9675; <a href="$selfurl?act=delForm&student=$myNum"> Delete element </a> 
						    	&#9675; <a href="$selfurl">Back to menu</a>
					    </menu>
				    <BR>~;
	
	doSmth($input);
		    
	print qq~</BODY>~;
};


sub printF
{
	print	qq~
			    <footer>
			    <BR>
			    <BR>
			    Melnikov N. (st $myNum) <BR>
			    </footer>
			</HTML>~;
};


sub doSmth
{
	my ($input) = @_;
	my $act = $input->param("act");
	my %methodsRef = 
	(
		'add' => \&addI,
		'upd' => \&updI,
		'del' => \&delI,
		'show' => \&showI,
		'addForm' => \&addF,
		'updForm' => \&updF,
		'delForm' => \&delF
	);

	if(defined $act) 
	{
		$methodsRef{$act}->($input);
	}
	else
	{
		showI();
	};


};

sub addF
{
	print qq~<FORM act="$selfurl" name = AddEL>
				Player num: <input type=text width = 40 name = "PlNum">
				Player name: <input type=text width = 40 name = "PlName"> 
			    Player position: <input type=text width = 40 name = "PlPosition">
			    Is captain: <input type=checkbox name = "isCaptain" value = 0 >
			    <INPUT TYPE="HIDDEN" NAME="act" VALUE ="add"/>
			    <INPUT TYPE="HIDDEN" NAME="student" VALUE =$myNum/>
			    <input type = submit /><BR>
		    </FORM>~;
};

sub updF
{
	print qq~<FORM act="$selfurl" name = UpdEl>
			Player num: <input type=text width = 40 name = "PlNum">
			Player name: <input type=text width = 40 name = "PlName"> 
		    Player position: <input type=text width = 40 name = "PlPosition"> 
		    Is captain: <input type=checkbox name = "isCaptain"  >		
	    	<INPUT TYPE="HIDDEN" NAME=act VALUE ="upd">
	    	<INPUT TYPE="HIDDEN" NAME="student" VALUE =$myNum/>
		    <input type = submit /><BR>
	    </FORM>~;
};


sub delF
{
	print qq~	<FORM act="$selfurl" name = DelEl>
					Player number: <input type=text width = 40 name = "PlNum">
				    <INPUT TYPE="HIDDEN" NAME=act VALUE ="del"> 
				    <INPUT TYPE="HIDDEN" NAME="student" VALUE =$myNum/>
				    <input type = submit /><BR>
			    </FORM>~;
};


sub addI
{
	my ($input) = @_;
	my $PlNum = $input->param("PlNum");
	my $PlName = $input->param("PlName");
	my $PlPosition = $input->param("PlPosition");
	my $isCaptain = "No";

	if (defined $input->param("isCaptain") )
	{
		$isCaptain = "Yes";
	};

 	#my $dbh = DBI->connect('DBI:mysql:mydb:localhost:3306', 'root', '', { RaiseError => 1, AutoCommit => 1});
	#$dbh->do("insert into mydb.barca_players (PlNum, PlName, PlPosition, isCaptain) values (?,?,?,?)",
	#		 undef,($PlNum, $PlName, $PlPosition,$isCaptain));
	
	#$dbh->disconnect();
	getdata();
	
	if (exists($barcaPlayers{$PlNum}))
	{
		print "There is already player with number ".$PlNum."<BR>";
		return 1;
	}

	$barcaPlayers{$PlNum} = { Name => $PlName, Position => $PlPosition, isCaptain => $isCaptain};

	saveData();
	showI();
};



sub delI
{
	my ($input) = @_;
	my $PlNum = $input->param("PlNum");

	#my $dbh = DBI->connect('DBI:mysql:mydb:localhost:3306', 'root', '', { RaiseError => 1, AutoCommit => 1});
	#$dbh->do("delete from mydb.barca_players where PlNum = ?",
	#		 undef, ($PlNum));
	#$dbh->disconnect();
	getdata();
	if (!exists($barcaPlayers{$PlNum}))
	{
		print "There is no player with number ".$PlNum."<BR>";
		return 1;
	}

	delete($barcaPlayers{$PlNum});
	saveData();
	showI();
};


sub updI
{
	my ($input) = @_;
	my $PlNum = $input->param("PlNum");
	my $PlName = $input->param("PlName");
	my $PlPosition = $input->param("PlPosition");
	my $isCaptain = "No";

	if (defined $input->param("isCaptain") )
	{
		$isCaptain = "Yes";
	};

	#my $dbh = DBI->connect('DBI:mysql:mydb:localhost:3306', 'root', '', { RaiseError => 1, AutoCommit => 1});
	#$dbh->do( "update mydb.barca_players set PlName = ?, PlPosition = ?, isCaptain=?  where PlNum=?", 
	#			undef, ($PlName, $PlPosition,$isCaptain, $PlNum) );

	#$dbh->disconnect();
	getdata();

	if (!exists($barcaPlayers{$PlNum}))
	{
		print "Can't find player with number ".$PlNum."<BR>";
		return 1;
	}

	$barcaPlayers{$PlNum} = { Name => $PlName, Position => $PlPosition, isCaptain => $isCaptain};

	saveData();
	showI();
};





sub encodeVariables
{
	my (@input) = @_;

	foreach my $var(@input)
	{
		from_to($var,'cp866','windows-1251');
	};
};



sub getData111
{
	%barcaPlayers = ();
	my $dbh = DBI->connect('DBI:mysql:mydb:localhost:3306', 'root', '', { RaiseError => 1, AutoCommit => 1});
	my $sql = $dbh->prepare("select PlNum, PlName, PlPosition, isCaptain from mydb.barca_players order by PlNum");
	$sql->execute();
	while (my $rowAsArr = $sql->fetchrow_hashref())
	{
		my $PlNum = $$rowAsArr{"PlNum"};
		my $PlName = $$rowAsArr{"PlName"};
		my $PlPosition = $$rowAsArr{"PlPosition"}; 
		my $isCaptain = $$rowAsArr{"isCaptain"};
		$barcaPlayers{$PlNum} = { Name => $PlName, Position => $PlPosition, isCaptain => $isCaptain};
	};
	$sql->finish();
	$dbh->disconnect();
};

sub getdata 
{
	my %buffHash = ();
	dbmopen(%buffHash,"barcaplayersDB",0644) || die "Error open to file!";

	foreach my $num (keys %buffHash)
	{;
		my @InfoArr =  split(/;/, $buffHash{$num}); 
		$barcaPlayers{$num} = { Name => @InfoArr[0], Position => @InfoArr[1], isCaptain => @InfoArr[2] };
	};
	dbmclose(%buffHash);
};

sub saveData
{
	my %buffHash = ();
	dbmopen(%buffHash,"barcaplayersDB",0644) || die "Error open to file!";
	my $InfoStr = undef();
	

	foreach my $num (keys %barcaPlayers)
	{
		$InfoStr = undef();
		foreach my $info (sort keys %{$barcaPlayers{$num}})
		{
			$InfoStr = $InfoStr.${$barcaPlayers{$num}}{$info}.";";
		};		
		$buffHash{$num} = $InfoStr;
	};
	my @bufArr = %buffHash;
	dbmclose(%buffHash);	
};

sub showI
{
	my $resStr;
	#getData();
	$resStr .= "<table border=1 >";
	$resStr .= "<tr><th>Player number</th><th>Player name</th><th>Player position</th><th>Is player captain</th></tr>";
	while((my $PlNum,my $PlData) = each %barcaPlayers)
	{
		encodeVariables(($PlNum,$$PlData{Name},$$PlData{Position},$$PlData{isCaptain}));
		$resStr.= "<tr><td>$PlNum</td><td>$$PlData{Name}</td><td>$$PlData{Position}</td><td>$$PlData{isCaptain}</td></tr>";
	};
	$resStr .= "</table>";	
	print $resStr;
};


1;