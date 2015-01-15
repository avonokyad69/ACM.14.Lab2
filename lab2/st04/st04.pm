package ST04;
use strict;

my @lists=();

sub st04
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
	
	my $newid = @lists;
	
	print <<ENDOFTEXT;
	<tr>
		<form  method='get'>
		<td>$newid</td>
		<input type='hidden' name='student' value='$myself'>
		<input type='hidden' name='type' value='add'>
		<input type='hidden' name='id' value='$newid'>
		<td><input type='text' size=20 name=name></td>
		<td><input type='text' size=20 name=marka></td>
		<td><input type='text' size=5 name=number></td>
		<td><input type='text' size=20 name=schet></td>
		<td><input type='submit' value='Dobavit'></td>
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
		<th>Imya_vladelcya</th>
		<th>Marka_avtomobilya</th>
		<th>Nomer_garaja</th>
		<th>Nomer_scheta</th>
		<th>Buttons</th>
	</tr>
ENDOFTABLE

	my $j=0;
	 foreach my $i(@lists)
	 {
		 print <<ENDOFITEM;
	<tr>
		<td>$j</td>
		<td>$i->{Imya_vladelcya}</td>
		<td>$i->{Marka_avtomobilya}</td>
		<td>$i->{Nomer_garaja}</td>
		<td>$i->{Nomer_scheta}</td>
		<td><a href=\'$ENV{SCRIPT_NAME}?student=$myself&type=edit&id=$j'>Izmenit</a>&nbsp;&nbsp;&nbsp;
		<a href=\'$ENV{SCRIPT_NAME}?student=$myself&type=delete&id=$j''>Udalit</a>
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
		Imya_vladelcya => $q->param('name')."\n",
		Marka_avtomobilya => $q->param('marka')."\n",
		Nomer_garaja => $q->param('number')."\n",
		Nomer_scheta => $q->param('schet')."\n",
	};
	$lists[$targetid]=$list;
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
		<td><input type='text' name='name' value='$lists[$targetid]->{Imya_vladelcya}'></td>
		<td><input type='text' name='marka' value='$lists[$targetid]->{Marka_avtomobilya}'></td>
		<td><input type='text' name='number' value='$lists[$targetid]->{Nomer_garaja}'></td>
		<td><input type='text' name='schet' value='$lists[$targetid]->{Nomer_scheta}'></td>
		<td><input type='submit' value='Izmenit'></td>
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
	splice(@lists, $targetid, 1);
	save($q);
}

sub save
{
	my ($q) = @_;
	my $myself	= $q->param('student');
	my $type = $q->param('type');
	my $targetid = $q->param('id');
	
 
	my %hash;
	dbmopen(%hash, "lab2/st04/db", 0666);
	%hash=();
	my $id=0;
	foreach my $i(@lists)
	{	
		$hash{$id}=$i->{Imya_vladelcya}.$i->{Marka_avtomobilya}.$i->{Nomer_garaja}.$i->{Nomer_scheta};
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
	dbmopen(%hash, "lab2/st04/db", 0666);
	@lists=();
	my $id=0;
	foreach my $i(values %hash)
	{
		my @tmp = split /\n/, $i;
		my $list={
		Imya_vladelcya => "$tmp[0]\n",
		Marka_avtomobilya => "$tmp[1]\n",
		Nomer_garaja => "$tmp[2]\n",
		Nomer_scheta => "$tmp[3]\n",
		};
		$lists[$id]=$list;
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
<title>Spisok chlenov garajnogo kooperativa!</title>
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
<hr><footer>
Spisok chlenov garajnogo kooperativa <br /> 
by Vorobev Nikita, ASM-14-04
</footer>
</body>
</html>
FOOTER
}
	
1;