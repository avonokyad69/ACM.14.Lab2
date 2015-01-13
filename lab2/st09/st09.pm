package ST09;
use strict;

my @snowboards=();

sub st09
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
	
	my $newid = @snowboards;
	
	print <<ENDOFTEXT;
	<tr><style type="text/css">
		TABLE {
		background: #dc0; /* Цвет фона таблицы */
		color: black; /* Цвет текста */
	}
	TD, TH {
		padding: 5px; /* Поля вокруг текста */
    border: 1px solid #fff; /* Рамка вокруг ячеек */
	}
	</style>
		<form  method='get'>
		<td>$newid</td>
		<input type='hidden' name='student' value='$myself'>
		<input type='hidden' name='type' value='add'>
		<input type='hidden' name='id' value='$newid'>
		<td><input type='text' size=30 name=company></td>
		<td><input type='text' size=10 name=size></td>
		<td><input type='text' size=15 name=color></td>
		<td><input type='text' size=15 name=year></td>
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
		<th>Company</th>
		<th>Size</th>
		<th>Color</th>
		<th>Year</th>
		<th>Buttons</th>
	</tr>
ENDOFTABLE

	my $j=0;
	 foreach my $i(@snowboards)
	 {
		 print <<ENDOFITEM;
	<tr>
		<td>$j</td>
		<td>$i->{Company}</td>
		<td>$i->{Size}</td>
		<td>$i->{Color}</td>
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
	
	my $snowboard={
		Company => $q->param('company')."\n",
		Size => $q->param('size')."\n",
		Color => $q->param('color')."\n",
		Year => $q->param('year')."\n",
	};
	$snowboards[$targetid]=$snowboard;
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
		<td><input type='text' name='company' value='$snowboards[$targetid]->{Company}'></td>
		<td><input type='text' name='size' value='$snowboards[$targetid]->{Size}'></td>
		<td><input type='text' name='color' value='$snowboards[$targetid]->{Color}'></td>
		<td><input type='text' name='year' value='$snowboards[$targetid]->{Year}'></td>
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
	splice(@snowboards, $targetid, 1);
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
	foreach my $i(@snowboards)
	{	
		$hash{$id}=$i->{Company}.$i->{Size}.$i->{Color}.$i->{Year};
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
	@snowboards=();
	my $id=0;
	foreach my $i(values %hash)
	{
		my @tmp = split /\n/, $i;
		my $snowboard={
		Company => "$tmp[0]\n",
		Size => "$tmp[1]\n",
		Color => "$tmp[2]\n",
		Year => "$tmp[3]\n",
		};
		$snowboards[$id]=$snowboard;
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
<title>Snowboards!</title>
</head>
<body>
<header>
<h1>My Snowboards (MMDb)</h1>
</header>
<a href='$ENV{SCRIPT_NAME}'>Back</a>
<hr>
HEADER
}

sub printFooter
{
	my ($q) = @_;
	print <<FOOTER;
<hr><footer>Kuzmin Sergey ASM-14-4, 2014</footer>
</body>
</html>
FOOTER
}
	
1;