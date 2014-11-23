package ST16;
use strict;
use CGI;
use CGI::Carp qw(fatalsToBrowser);

my %list;

sub st16
{
	readfile();
	my ($q, $global) = @_;
	my $me=$q->param('student');
	print $q->header('charset=windows-1251');
	my $id=$q->param('id');
	my $nextid=keys %list;
	if(!$id){$id=keys %list;}
	my $action=0;
	my $temp={};
	if($q->param('action') == 1)
	{
		$temp={
		title => $list{$id}->{title},
		country => $list{$id}->{country},
		year => $list{$id}->{year},
		mark => $list{$id}->{mark}};		 
	}	
	if($q->param('action') == 2)
	{
		delete $list{$id};
		$id=keys %list;
		savefile();
		readfile();
	}
	if($q->param('action') == 3)
	{
		my $added={
			title => $q->param('v1')."\n",
			country => $q->param('v2')."\n",
			year => $q->param('v3')."\n",
			mark => $q->param('v4')."\n"};		 
		$list{$id}=$added;
		$id=(keys %list);
		savefile();
		readfile();
		
	}
	print "<body>
	<a href=' $ENV{SCRIPT_NAME}'\>К списку работ</a>
	<table border='1'>	
    <tr>
    <th>ID</th>
    <th>Название</th>
    <th>Страна</th>
    <th>Год</th>
    <th>Оценка</th>
	<th>Действия</th>
	</tr>";
	foreach my $j (sort keys %list ) {
        my $i = $list{$j};
		print"<tr><td>$j</td>
		<td>$i->{title}</td>
		<td>$i->{country}</td>
		<td>$i->{year}</td>
		<td>$i->{mark}</td>
		<td><a href=\'$global->{selfurl}?student=$me&action=1&id=$j'>Изменить</a>&nbsp;&nbsp;&nbsp;
		<a href=\'$global->{selfurl}?student=$me&action=2&id=$j'>Удалить</a></td>
		</tr>";
    }	
	print"<tr>
	<form  method='get'>
	<td>$id</td>
	<input type='hidden' name='student' value='$me'>
	<input type='hidden' name='action' value='3'>
	<input type='hidden' name='id' value='$id'>
	<td><input type='text' size=20 name=v1 value='$temp->{title}'></td>
	<td><input type='text' size=20 name=v2 value='$temp->{country}'></td>
	<td><input type='text' size=5 name=v3 value='$temp->{year}'></td>
	<td><input type='text' size=20 name=v4 value='$temp->{mark}'></td>
	<td><input type='submit' value='Применить/добавить'></td></tr>
	</table></form></body>";
savefile();
}

sub savefile
{
	my %filehash;
	dbmopen(%filehash, "lab2/st16/database", 0644);
	%filehash=();
	my $iter=1;
	foreach my $j(sort keys %list)
	{	
		my $i = $list{$j};
		my $text=$i->{title}.$i->{country}.$i->{year}.$i->{mark};
		$filehash{$iter}=$text;
		$iter++;
	}
	dbmclose(%filehash);
	return 1;
}

sub readfile
{
	my %filehash=();
	dbmopen(%filehash, "lab2/st16/database", 0644);
	%list =();
	foreach my $j(sort keys %filehash)
	{
		my $i = $filehash{$j};
		my @strtoarr = split /\n/, $i;
		my $movie={
			title => "$strtoarr[0]\n",
			country => "$strtoarr[1]\n",
			year => "$strtoarr[2]\n",
			mark => "$strtoarr[3]\n",
		};
		$list{$j}=$movie;
	}
	dbmclose(%filehash);
	return 1;
}
1;
