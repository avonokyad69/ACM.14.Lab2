package ST19;
use strict;
use CGI;
use CGI::Carp qw(fatalsToBrowser);

my @contacts=();

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
	my $newid=@contacts;
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
    <th>Мобильный телефон</th>
    <th>Электронная почта</th>
	<th>Кнопки</th>
	</tr>";
	my $j=0;
	 foreach my $i(@contacts)
	 {
		 print "<tr><td>$j</td>
		 <td>$i->{FirstName}</td>
		 <td>$i->{LastName}</td>
		 <td>$i->{MobilePhone}</td>
		 <td>$i->{Email}</td>
		 <td><a href=\'$global->{selfurl}?student=$myself&action=edit&id=$j'>Изменить</a>&nbsp;&nbsp;&nbsp;
		 <a href=\'$global->{selfurl}?student=$myself&action=delete&id=$j''>Удалить</a>
		</td>
		
		 </tr>";
		 
		$j++;
	} 
	
}
sub add
{
	my $contact={
	FirstName => $q->param('v1')."\n",
	LastName => $q->param('v2')."\n",
	MobilePhone => $q->param('v3')."\n",
	Sth => $q->param('v4')."\n",
	};
	$contacts[$targetid]=$contact;
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
	<td><input type='text' size=20 name=v1 value='$contacts[$targetid]->{FirstName}'></td>
	<td><input type='text' size=20 name=v2 value='$contacts[$targetid]->{LastName}'></td>
	<td><input type='text' size=5 name=v3 value='$contacts[$targetid]->{MobilePhone}'></td>
	<td><input type='text' size=20 name=v4 value='$contacts[$targetid]->{Email}'></td>
	<td><input type='submit' value='Применить'></td></tr>
	</form>
	</table>";
	tofile();
}
sub deleteline()
{
	fromfile();
	splice( @contacts, $targetid, 1);
	tofile();
}
 sub tofile
 {
	my %filehash;
	dbmopen(%filehash, "lab2/st19/file", 0644);
	%filehash=();
	my $id=0;
	foreach my $i(@contacts)
	{	
		$filehash{$id}=$i->{FirstName}.$i->{LastName}.$i->{MobilePhone}.$i->{Email};
		$id++;
	}
	dbmclose(%filehash);
	return 1;
 }
 sub fromfile
 {
	my %filehash=();
	dbmopen(%filehash, "lab2/st19/file", 0644);
	@contacts=();
	my $id=0;
	foreach my $i(values %filehash)
	{
		my @tmp = split /\n/, $i;
		my $contact={
		FirstName => "$tmp[0]\n",
		LastName => "$tmp[1]\n",
		MobilePhone => "$tmp[2]\n",
		Email => "$tmp[3]\n",
		};
		$contacts[$id]=$contact;
		$id++;
	}
	
	dbmclose(%filehash);
	return 1;

 }

	
1;









