package ST21;
use strict;
use warnings;
use CGI;

my %list = (
	1 => 'Add',
	2 => 'Edit',
	3 => 'Delete',
	4 => 'Show_all');
	
my %Items =();

sub st21
{
	my ($q, $global) = @_;
	my $q = new CGI;
	my $choice = $q->param('choice');
	Load_from_file();
	if(defined $choice)
	{
		my $func_call = \&{$list{$choice}};
		&$func_call($q, $global);
	}
	else
	{
		menu($q, $global);
	}	
	print "</BODY><a href=\"$global->{selfurl}?student=$global->{student}\">Назад</a><BR></HTML>";
}

sub menu
{
	my($q, $global) = @_;
	print $q->header('charset=windows-1251');
	print "<HTML><HEAD><TITLE>2nd lab</TITLE></HEAD><BODY><hr><menu type=\"toolbar\"><ul type=\"disc\">";

	foreach my $name (sort keys %list)
	{
		print "<li> <a href=\"$global->{selfurl}?choice=$name&student=$global->{student}\" > $list{$name} </a>	</li>";
	}
	
	print "</ul></menu><hr>";	
}

sub printForm
{
	my ($q, $global) = @_;
	my $value = 0+$q->param('choice');
	if(defined $value && $value != 3)
	{
		print qq~<FORM action="$global->{selfurl}" name = SaveAndUpd>
			    ФИО:<BR>
			    <input type=text width = 40 name = "name_"> <BR>
			    Позиция:<BR>
			    <input type=text width = 40 name = "pos_"> <BR>
			    Возраст:<BR>
			    <input type=text width = 40 name = "age_"> <BR>
			    Клуб:<BR>
			    <input type=text width = 40 name = "club_"> <BR>
			    <INPUT TYPE="HIDDEN" NAME="choice" VALUE ="$value"/>
			    <INPUT TYPE="HIDDEN" NAME="student" VALUE =$global->{student}/>
			    <input type = submit name = "btn" value = "Сохранить"/><BR>
		    </FORM>~;
	}elsif(defined $value)
	{
		print qq~<FORM action="$global->{selfurl}" name = SaveAndUpd>
			    ФИО:<BR>
			    <input type=text width = 40 name = "name_"> <BR>
			    <INPUT TYPE="HIDDEN" NAME="choice" VALUE ="$value"/>
			    <INPUT TYPE="HIDDEN" NAME="student" VALUE =$global->{student}/>
			    <input type = submit name = "btn" value = "Сохранить"/><BR>
		    </FORM>~;		
	}
}

sub Add
{
	my ($q, $global) = @_;
	
	my $name = $q->param('name_');
	my $pos = $q->param('pos_');
	my $age = 0+$q->param('age_');
	my $club = $q->param('club_');		
	
	if(!defined $name)
	{
		    printForm($q, $global);
	}
	else
	{
		push(@{$Items{$name}}, $pos, $age, $club);
		Save_to_file();
		menu($q, $global);
	}
}

sub Edit
{
	my ($q, $global) = @_;
	
	Show_all($q, $global);
	
	my $name = $q->param('name_');
	my $pos = $q->param('pos_');
	my $age = 0+$q->param('age_');
	my $club = $q->param('club_');		
	
	if(!defined $name)
	{
		    printForm($q, $global);
	}elsif(exists($Items{$name}))
	{
		@{$Items{$name}}[0] = $pos;
		@{$Items{$name}}[1] = $age;
		@{$Items{$name}}[2] = $club;
		Save_to_file();
	}else
	{
		print "\nНет такого игрока\n\n";
	};
}
 
sub Delete
{
	my ($q, $global) = @_;
	
	Show_all($q, $global);
	
	my $name = $q->param('name_');
	
	if(!defined $name)
	{
		    printForm($q, $global);
	}elsif(exists($Items{$name}))
	{
		delete($Items{$name});
		Save_to_file();
	}
	else
	{
		print "\nНет такого игрока:\n\n";
	}
}

sub Show_all
{
	print "==========================<br>";
	foreach my $name (keys %Items)
	{
		print "<li>$name: @{$Items{$name}}</li>";
	}
	
	print "==========================<br>";
}

sub Save_to_file
{	
	my %buff = ();
	dbmopen(%buff,"Shilenkov_dbm",0644) || die "Error open to file!";	
	my $buffStr;
	%buff = ();
	foreach my $name (keys %Items)
	{
		$buffStr = undef();		
		$buffStr = @{$Items{$name}}[0].":".@{$Items{$name}}[1].":".@{$Items{$name}}[2].";";
		$buff{$name} = $buffStr;
	};	
	dbmclose(%buff);
}

sub Load_from_file
{	
	my %buff = ();
	dbmopen(%buff,"Shilenkov_dbm",0644) || die "Error open to file!";		
	foreach my $name (keys %buff)
	{
		my @buffStr = undef();
		@buffStr = split(/;/, $buff{$name}); 
		foreach my $buffElem (@buffStr)
		{
			my @Value = split(/:/, $buffElem);
			push(@{$Items{$name}}, $Value[0], $Value[1], $Value[2]);
		};
	};	
	dbmclose(%buff);
}

return 1;
