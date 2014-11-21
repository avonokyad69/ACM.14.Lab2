package ST08;
use strict;
use CGI;
use CGI::Carp qw(fatalsToBrowser);

my @humans=();

my $q=new CGI;
my $myself	= $q->param('student');
my $action = $q->param('action');
my $targetid = $q->param('id'); 


 
 sub st08
{

	my ($q, $global) = @_;
	print $q->header('charset=windows-1251');
	if($action eq "edit")
		{			
			edit();			
		}
	elsif($action eq "delete")
		{		
			deleteline();
			fromfile();
			showall();
			footer()
		}
	elsif($action eq "apply")
	{
		fromfile();
		add();
		tofile();
		showall();
		footer()
	}
		else
		{
			fromfile();
			showall();
			
			footer()
		}
	
	
	#fromfile();
	#showall();
	

}
sub footer
{
	my $newid=@humans;
	print "<tr>
	<form  method='get'>
	<td>$newid</td>
		<input type='hidden' name='student' value='$myself'>
		<input type='hidden' name='action' value='apply'>
		<input type='hidden' name='id' value='$newid'>
		<td><input type='text' size=20 name=v1></td>
		<td><input type='text' size=20 name=v2></td>
		<td><input type='text' size=5 name=v3></td>
		<td><input type='text' size=20 name=v4></td>
		<td><input type='submit' value='Добавить'></td></tr>
		</table>"
}

sub showall
{
	my ($q, $global) = @_;

	print "
	<a href=' $ENV{SCRIPT_NAME}'\>К списку</a>
	<table border='1'>	
    <tr>
    <th>ID</th>
    <th>Имя</th>
    <th>Фамилия</th>
    <th>Возраст</th>
    <th>Доп. инфо</th>
	<th>Кнопочки</th>
	</tr>";
	my $j=0;
	 foreach my $i(@humans)
	 {
		 print "<tr><td>$j</td>
		 <td>$i->{Name}</td>
		 <td>$i->{SurName}</td>
		 <td>$i->{Age}</td>
		 <td>$i->{Sth}</td>
		 <td><a href=\'$global->{selfurl}?student=$myself&action=edit&id=$j'>Изменить</a>&nbsp;&nbsp;&nbsp;
		 <a href=\'$global->{selfurl}?student=$myself&action=delete&id=$j''>Удалить</a>
		</td>
		
		 </tr>";
		 
		$j++;
	} 
	
}
sub add
{
	my $human={
	Name => $q->param('v1')."\n",
	SurName => $q->param('v2')."\n",
	Age => $q->param('v3')."\n",
	Sth => $q->param('v4')."\n",
	};
	$humans[$targetid]=$human;
}
sub edit
{
	my ($q, $global) = @_;
	fromfile();
	showall();
	print "<tr>
	<form  method='get'>
	
	<td>$targetid</td>
	<input type='hidden' name='student' value='$myself'>
	<input type='hidden' name='action' value='apply'>
	<input type='hidden' name='id' value='$targetid'>
	<td><input type='text' size=20 name=v1 value='$humans[$targetid]->{Name}'></td>
	<td><input type='text' size=20 name=v2 value='$humans[$targetid]->{SurName}'></td>
	<td><input type='text' size=5 name=v3 value='$humans[$targetid]->{Age}'></td>
	<td><input type='text' size=20 name=v4 value='$humans[$targetid]->{Sth}'></td>
	<td><input type='submit' value='Применить'></td></tr>
	</form>
	</table>";
	tofile();
}
sub deleteline()
{
	fromfile();
	splice( @humans, $targetid, 1);
	tofile();
}
 sub tofile
 {
	my %filehash;
	dbmopen(%filehash, "lab2/st08/file", 0644);
	%filehash=();
	my $id=0;
	foreach my $i(@humans)
	{	
		$filehash{$id}=$i->{Name}.$i->{SurName}.$i->{Age}.$i->{Sth};
		$id++;
	}
	dbmclose(%filehash);
	return 1;
 }
 sub fromfile
 {
	my %filehash=();
	dbmopen(%filehash, "lab2/st08/file", 0644);
	@humans=();
	my $id=0;
	foreach my $i(values %filehash)
	{
		my @tmp = split /\n/, $i;
		my $human={
		Name => "$tmp[0]\n",
		SurName => "$tmp[1]\n",
		Age => "$tmp[2]\n",
		Sth => "$tmp[3]\n",
		};
		$humans[$id]=$human;
		$id++;
	}
	
	dbmclose(%filehash);
	return 1;

 }

	
1;









