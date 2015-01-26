package ST06;
use strict;

my @students=();

sub st06
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
	
	my $newid = @students;
	
	print <<ENDOFTEXT;
	<tr>
		<form  method='get'>
		<td>$newid</td>
		<input type='hidden' name='student' value='$myself'>
		<input type='hidden' name='type' value='add'>
		<input type='hidden' name='id' value='$newid'>
		<td><input type='text' size=20 name=name></td>
		<td><input type='text' size=20 name=surname></td>
		<td><input type='text' size=5 name=group></td>
		<td><input type='text' size=20 name=age></td>
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
		<th>Name</th>
		<th>Surname</th>
		<th>Group</th>
		<th>Age</th>
		<th>Buttons</th>
	</tr>
ENDOFTABLE

	my $j=0;
	 foreach my $i(@students)
	 {
		 print <<ENDOFITEM;
	<tr>
		<td>$j</td>
		<td>$i->{Name}</td>
		<td>$i->{Surname}</td>
		<td>$i->{Group}</td>
		<td>$i->{Age}</td>
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
	
	my $list={
		Name => $q->param('name')."\n",
		Surname => $q->param('surname')."\n",
		Group => $q->param('group')."\n",
		Age => $q->param('age')."\n",
	};
	$students[$targetid]=$list;
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
		<td><input type='text' name='name' value='$students[$targetid]->{Name}'></td>
		<td><input type='text' name='surname' value='$students[$targetid]->{Surname}'></td>
		<td><input type='text' name='group' value='$students[$targetid]->{Group}'></td>
		<td><input type='text' name='age' value='$students[$targetid]->{Age}'></td>
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
	splice(@students, $targetid, 1);
	save($q);
}

sub save
{
	my ($q) = @_;
	my $myself	= $q->param('student');
	my $type = $q->param('type');
	my $targetid = $q->param('id');
	
 
	my %hash;
	dbmopen(%hash, "lab2/st06/db", 0666);
	%hash=();
	my $id=0;
	foreach my $i(@students)
	{	
		$hash{$id}=$i->{Name}.$i->{Surname}.$i->{Group}.$i->{Age};
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
	dbmopen(%hash, "lab2/st06/db", 0666);
	@students=();
	my $id=0;
	foreach my $i(values %hash)
	{
		my @tmp = split /\n/, $i;
		my $list={
		Name => "$tmp[0]\n",
		Surname => "$tmp[1]\n",
		Group => "$tmp[2]\n",
		Age => "$tmp[3]\n",
		};
		$students[$id]=$list;
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
<title>The list of students</title>
</head>
<body>
<a href='$ENV{SCRIPT_NAME}'>Back</a>
<hr>
HEADER
}

sub printFooter
{
	my ($q) = @_;
	print <<FOOTER;
<hr><footer>Dyakonova Natalia, ASM-14-04
</footer>
</body>
</html>
FOOTER
}
	
1;