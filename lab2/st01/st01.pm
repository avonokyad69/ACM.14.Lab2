package ST01;
use strict;
use warnings;
use CGI;
use CGI::Carp qw(fatalsToBrowser);

my $Myfile='lab2\st01\AbramovData';
my @menu=
(
"Add object",
"Change",
"Delete",
"Print all elements"
);

my @option_func=
(
\&add,
\&delete,
\&change,
\&printall
);
my @students=();
sub st01
{
	my $q = new CGI;
	my $st =0+$q->param("menu_");
	my $global = {selfurl => $ENV{SCRIPT_NAME}, menu_=> $st};
	fromfile();
	if($st && defined $option_func[$st-1])
	{
		$option_func[$st-1]->($q, $global);
	}
	else
	{	
		menu($q, $global);
	}
}


sub menu
{
	my($q, $global) = @_;
	print $q->header('charset=windows-1251');
	print "<HTML><HEAD><TITLE>Second Lab</TITLE></HEAD><BODY><hr><menu type=\"toolbar\"><ul type=\"disc\">";
	print"<FORM>
	<HR>Press a text: <br>
	<P>Name of student:<BR><INPUT NAME=\"name_\" TYPE=TEXT maxsize=100><BR>
	<P>Surname of student:<BR><INPUT NAME=\"surname_\" TYPE=TEXT maxsize=100><BR>
	<P>Group of student:<BR><INPUT NAME=\"group_\" TYPE=TEXT maxsize=100><BR>
	<P>Age of student:<BR><INPUT NAME=\"age_\" TYPE=TEXT maxsize=100><BR>
	<P> Number of student:<BR><INPUT NAME=\"number_\" TYPE=TEXT maxsize=100><BR>
	<INPUT TYPE='radio' NAME=\"menu_\" VALUE=1> Add<BR>
	<INPUT TYPE='radio' NAME=\"menu_\" VALUE=2> Del<BR>
	<INPUT TYPE='radio' NAME=\"menu_\" VALUE=3> Change<BR>
	<INPUT TYPE='radio' NAME=\"menu_\" VALUE=4> Print all<BR>
	<INPUT TYPE='HIDDEN' NAME='student' VALUE =\"1\"/>
	<INPUT type='submit'> <INPUT type='reset'> <BR>";
	print "</BODY><BR><BR><a href=\"$global->{selfurl}\">Back to student list.</a><BR></FORM></HTML>";
}


sub add
{
	my($q, $global) = @_;
	my $name=$q->param('name_');
	my $surname=$q->param('surname_');
	my $group=$q->param('group_');
	my $age=$q->param('age_');
	my $sthash=
		{
			name=>$name,
			surname=>$surname,
			group=>$group,
			age=>$age
		};
	push(@students,$sthash);
	tofile();
	menu($q,$global);
}

sub delete
{
	my($q, $global) = @_;
	my $k=$q->param('number_');
	if (defined $students[$k-1])
	{ 
		splice(@students,$k-1,1);
		tofile();
	}
	menu($q,$global);	
}

sub change
{
	my($q, $global) = @_;
	my $k=$q->param('number_');
	if (defined $students[$k-1])
	{ 
		my $hashref=$students[$k-1];
		$hashref->{name}=$q->param("name_");
		$hashref->{surname}=$q->param('surname_');
		$hashref->{group}=$q->param('group_');
		$hashref->{age}=$q->param('age_');
		tofile();
	}
	menu($q,$global);	
}

sub printall
{	
	my ($q,$global) = @_;
	print $q->header('charset=windows-1251');
	print "<pre>\n------------------------------\n <ol value=1>";
	foreach	my $item (@students)
	{
		
		print "<li>Student: 
			Name:$item->{name} 
			Surname:$item->{surname} 
			Group:$item->{group} 
			Age:$item->{age} </li>";
	}
	print "------------------------------</pre></ol>
	<a href=\"$global->{selfurl}?student=1&menu_=0\">To menu.</a>";
}

sub tofile
{
	dbmopen(my %hash,$Myfile,0644);
	my $i=0;
	my $s;
	%hash=();
	foreach my $item(@students)
		{
		my @a=("name",$item->{name},"surname",$item->{surname},"group",$item->{group},"age",$item->{age});	
		$s=join(",",@a);
		$hash{$i}=$s;
		$i++;
		}
	dbmclose(%hash);	
}

sub fromfile
{
	dbmopen(my %hash,$Myfile,0644);
		while (( my $key,my $value) = each(%hash))
	{
		my @st=split(/,/,$hash{$key});
		$students[$key]={@st};
	}
	dbmclose(%hash);
};
1
