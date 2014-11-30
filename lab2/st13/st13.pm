package ST13;
use strict;

my @films = ();	

my @MENULINK =
(
	\&DoAdd,
	\&DoEdit,
	\&DoShow,
	\&DoSave,
	\&DoLoad,
	\&DoDelete,
	\&DoExit,
);

my @MENU = 
(
	"add",
	"edit",
	"show",
	"save",
	"load",
	"delete",
	"exit",
);

sub st13
{
	my ($q, $global) = @_;
	print $q->header();
	print "<h1>Welcome to my own version of IMDB :]</h1>";
	
	my $st = 0+$q->param('student');
	my $mi = 0+$q->param('menuitem');
	my $global = {selfurl => $ENV{SCRIPT_NAME}, student => $st, menuitem => $mi};
	if ($mi && defined $MENULINK[$mi-1])
	{	
		$MENULINK[$mi-1]->($q, $global);
	}
	else
	{
		menu($q,$global);
	}
}

sub menu
{
	my ($q, $global) = @_;
	my $i = 0;
	print "<pre>\n------------------------------\n";
	foreach my $s(@MENU)
	{
		$i++;
		print "<a href='$global->{selfurl}?student=3&menuitem=$i'>$i. $s</a>\n";
	}
	print "------------------------------</pre>";
}

sub DoAdd
{
	print "<br><h2>This function temporarily not working...</h2>"
}

sub DoEdit
{
	print "<br><h2>This function temporarily not working...</h2>"
}

sub DoShow
{
	print "<br><h2>This function temporarily not working...</h2>"
}

sub DoSave
{
	print "<br><h2>This function temporarily not working...</h2>"
}

sub DoLoad
{
	print "<br><h2>This function temporarily not working...</h2>"
}

sub DoDelete
{
	print "<br><h2>This function temporarily not working...</h2>"
}

sub DoExit
{
	print "<br><h2>This function temporarily not working...</h2>"
}

1;