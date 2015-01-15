package ST20;
use strict;

my @regions=();

sub st20
{
	my ($q, $global) = @_;
	main($q, $global);
}

sub main
{
	my ($q, $global) = @_;
	my $type = $q->param('type');
	
	my %MENU = (
		'new' 		=> \&DoAdd,
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
	
	my $newid = @regions;
	
	print <<ENDOFTEXT;
	<tr><style type="text/css">
		TABLE {
		background: #dc0; /* Цвет фона таблицы */
		color: black; /* Цвет текста */
	}
	TD, TH {
		padding: 3px; /* Поля вокруг текста */
    border: 1px solid #fff; /* Рамка вокруг ячеек */
	}
	</style>
		<form  method='get'>
		<td>$newid</td>
		<input type='hidden' name='student' value='$myself'>
		<input type='hidden' name='type' value='add'>
		<input type='hidden' name='id' value='$newid'>
		<td><input type='text' size=30 name=region_name></td>
		<td><input type='text' size=10 name=department></td>
		<td><input type='text' size=15 name=employees></td>
		<td><input type='text' size=15 name=income></td>
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
		<th>Region_name</th>
		<th>Department</th>
		<th>Employees</th>
		<th>Income</th>
		<th>Buttons</th>
	</tr>
ENDOFTABLE

	my $j=0;
	 foreach my $i(@regions)
	 {
		 print <<ENDOFITEM;
	<tr>
		<td>$j</td>
		<td>$i->{Region_name}</td>
		<td>$i->{Department}</td>
		<td>$i->{Employees}</td>
		<td>$i->{Income}</td>
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
	
	my $region={
		Region_name => $q->param('region_name')."\n",
		Department => $q->param('department')."\n",
		Employees => $q->param('employees')."\n",
		Income => $q->param('income')."\n",
	};
	$regions[$targetid]=$region;
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
		<td><input type='text' name='region_name' value='$regions[$targetid]->{Region_name}'></td>
		<td><input type='text' name='department' value='$regions[$targetid]->{Department}'></td>
		<td><input type='text' name='employees' value='$regions[$targetid]->{Employees}'></td>
		<td><input type='text' name='income' value='$regions[$targetid]->{Income}'></td>
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
	splice(@regions, $targetid, 1);
	save($q);
}

sub save
{
	my ($q) = @_;
	my $myself	= $q->param('student');
	my $type = $q->param('type');
	my $targetid = $q->param('id');
	
 
	my %hash;
	dbmopen(%hash, "lab2/st09/db", 0666);
	%hash=();
	my $id=0;
	foreach my $i(@regions)
	{	
		$hash{$id}=$i->{Region_name}.$i->{Department}.$i->{Employees}.$i->{Income};
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
	dbmopen(%hash, "lab2/st09/db", 0666);
	@regions=();
	my $id=0;
	foreach my $i(values %hash)
	{
		my @tmp = split /\n/, $i;
		my $region={
		Company => "$tmp[0]\n",
		Size => "$tmp[1]\n",
		Color => "$tmp[2]\n",
		Year => "$tmp[3]\n",
		};
		$regions[$id]=$region;
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
<title>My Business</title>
</head>
<body>
<header>
<h1>Regions</h1>
</header>
<a href='$ENV{SCRIPT_NAME}'>Back</a>
<hr>
HEADER
}

sub printFooter
{
	my ($q) = @_;
	print <<FOOTER;
<hr><footer>Max Chernyshev ASM-14-4, 2015</footer>
</body>
</html>
FOOTER
}
	
1;