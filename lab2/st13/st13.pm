package ST13;
use strict;

my @films=();

sub st13
{
	my ($q, $global) = @_;
	main($q, $global);
}

sub main
{
	my ($q, $global) = @_;
	my $type = $q->param('type');
	
	my %MENU = (
		'add' 		=> \&DoAdd,
		'edit' 		=> \&DoEdit,
		'delete'	=> \&DoDelete,
	);
	
	printHeader($q);
	
	if($MENU{$type}) {
		$MENU{$type}->($q);
	} else {
		load($q);
		showall($q);
			
		showForm($q);
	}
	
	printFooter($q);
}

sub DoAdd
{
	my ($q) = @_;
	
	load($q);
	add($q);
	save($q);
	showall($q);
	showForm($q);
}

sub DoEdit
{
	my ($q) = @_;

	edit($q);
}

sub DoDelete
{
	my ($q) = @_;
	
	deleteline($q);
	load($q);
	showall($q);
	showForm($q);	
}

sub showForm
{
	my ($q) = @_;
	my $myself	= $q->param('student');
	
	my $newid = @films;
	
	print <<ENDOFTEXT;
	<tr>
		<form  method='get'>
		<td>$newid</td>
		<input type='hidden' name='student' value='$myself'>
		<input type='hidden' name='type' value='add'>
		<input type='hidden' name='id' value='$newid'>
		<td><input type='text' size=20 name=name></td>
		<td><input type='text' size=20 name=producer></td>
		<td><input type='text' size=5 name=score></td>
		<td><input type='text' size=20 name=year></td>
		<td><input type='submit' value='Add'></td>
		</form>
	</tr>
</table>
ENDOFTEXT
}

sub showall
{
	my ($q) = @_;
	my $myself	= $q->param('student');
	my $type = $q->param('type');
	my $targetid = $q->param('id');
	
	print <<ENDOFTABLE;
<table border='1'>
	<tr>
		<th>ID</th>
		<th>Movie</th>
		<th>Producer</th>
		<th>Score</th>
		<th>Year</th>
		<th>Buttons</th>
	</tr>
ENDOFTABLE

	my $j=0;
	 foreach my $i(@films)
	 {
		 print <<ENDOFITEM;
	<tr>
		<td>$j</td>
		<td>$i->{Movie}</td>
		<td>$i->{Producer}</td>
		<td>$i->{Score}</td>
		<td>$i->{Year}</td>
		<td><a href=\'$ENV{SCRIPT_NAME}?student=$myself&type=edit&id=$j'>Edit</a>&nbsp;&nbsp;&nbsp;
		<a href=\'$ENV{SCRIPT_NAME}?student=$myself&type=delete&id=$j''>Delete</a>
		</td>
	</tr>
ENDOFITEM
		 
		$j++;
	} 
	
}

sub add
{
	my ($q) = @_;
	my $targetid = $q->param('id');
	
	my $film={
		Movie => $q->param('name')."\n",
		Producer => $q->param('producer')."\n",
		Score => $q->param('score')."\n",
		Year => $q->param('year')."\n",
	};
	$films[$targetid]=$film;
}

sub edit
{
	my ($q) = @_;
	my $myself	= $q->param('student');
	my $targetid = $q->param('id');
	
	load($q);
	showall($q);
	
	print <<ENDOFFORM;
<tr>
	<form  method='get'>
		<td>$targetid</td>
		<input type='hidden' name='student' value='$myself'>
		<input type='hidden' name='type' value='add'>
		<input type='hidden' name='id' value='$targetid'>
		<td><input type='text' name='name' value='$films[$targetid]->{Movie}'></td>
		<td><input type='text' name='producer' value='$films[$targetid]->{Producer}'></td>
		<td><input type='text' name='score' value='$films[$targetid]->{Score}'></td>
		<td><input type='text' name='year' value='$films[$targetid]->{Year}'></td>
		<td><input type='submit' value='Edit'></td>
	</form>
</tr>
</table>
ENDOFFORM
	save($q);
}

sub deleteline
{
	my ($q) = @_;
	my $targetid = $q->param('id');
	
	load($q);
	splice(@films, $targetid, 1);
	save($q);
}

sub save
{
	my ($q) = @_;
	my $myself	= $q->param('student');
	my $type = $q->param('type');
	my $targetid = $q->param('id');
	
 
	my %hash;
	dbmopen(%hash, "lab2/st13/db", 0666);
	%hash=();
	my $id=0;
	foreach my $i(@films)
	{	
		$hash{$id}=$i->{Movie}.$i->{Producer}.$i->{Score}.$i->{Year};
		$id++;
	}
	dbmclose(%hash);
	return 1;
}

sub load
{
	my ($q) = @_;
	
	my $myself	= $q->param('student');
	my $type = $q->param('type');
	my $targetid = $q->param('id');
 
	my %hash=();
	dbmopen(%hash, "lab2/st13/db", 0666);
	@films=();
	my $id=0;
	foreach my $i(values %hash)
	{
		my @tmp = split /\n/, $i;
		my $film={
		Movie => "$tmp[0]\n",
		Producer => "$tmp[1]\n",
		Score => "$tmp[2]\n",
		Year => "$tmp[3]\n",
		};
		$films[$id]=$film;
		$id++;
	}
	
	dbmclose(%hash);
	return 1;
}

sub printHeader
{
	my($q) = @_;
	print $q->header();
	print <<HEADER;
<html>
<head>
<title>Hello world!</title>
</head>
<body>
<header>
<h1>My Movie Database (MMDb)</h1>
</header>
<a href='$ENV{SCRIPT_NAME}'>Back</a>
<hr>
HEADER
}

sub printFooter
{
	my ($q) = @_;
	print <<FOOTER;
<hr><footer>Mansurov Alexander, 2014</footer>
</body>
</html>
FOOTER
}
	
1;