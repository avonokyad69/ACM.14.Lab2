package ST12;
use strict;
use CGI;
use CGI::Carp qw(fatalsToBrowser);

my @DATABASE=();
my $pathFile='lab2\st12\datafiles\654';
my @MODULES =
(
	\&edit,
	\&delete,
	\&save
);
my @ElNames=(
	'Название',
	'Жесткость',
	'Прогиб',
	'Ширина',
	'Система закладных',
	'Форма',
	'Сердечник'
	);
	
sub st12{
	Lab2Main();
}

sub menu{
	my ($q, $global) = @_;
	print $q->header('charset=windows-1251');
	my $i = 0;
	print "<pre><table cellspacing=\"0\"><tr><th>№&nbsp;</th><th>Название эл-та&nbsp;</th><th>Del</th></tr>";
	foreach my $s(@DATABASE){
		$i++;
		print "<tr><td>$i</td><td><a href=\"$global->{selfurl}?ElN=$i&wtd=1&student=$global->{st}\">$s->{$ElNames[0]}</a></td>
		<td>&nbsp;<a href=\"$global->{selfurl}?ElN=$i&wtd=2&&student=$global->{st}\">X</a></td>";
	}
	print "</table></pre><FORM><button type=\"submit\" name=\"wtd\" value=\"1\">Добавить</button>
	<INPUT TYPE=\"hidden\" NAME =\"student\" value=\"$global->{st}\"><a href=\"$global->{selfurl}\">EXIT</a></FORM>";
}

sub ReadFromDatabase{
	dbmopen(my %g, $pathFile, 0);
	foreach my $k(sort keys %g){
		my $ref2hash = {};
		my @array = split(/<===>/, $g{$k});
		foreach my $ar(@array){
			my ($key, $val) = split(/<==>/, $ar);
			$ref2hash->{$key}=$val;
		}
		@DATABASE=(@DATABASE,$ref2hash);
	}
	dbmclose(%g);
} 
sub SaveInDatabase{
	dbmopen(my %g, $pathFile, 0644);
	%g = ();
	my $i = 0;
	foreach my $ref2hash(@DATABASE){
		foreach my $o(@ElNames){
			$g{$i} .= "$o<==>$ref2hash->{$o}<===>";
		}
		$i++;
	}
	dbmclose(%g)
}

sub Lab2Main{
	my $q = new CGI;
	my $st	= 0+$q->param('student');
	my $wtd = 0+$q->param('wtd');
	my $global = {selfurl => $ENV{SCRIPT_NAME}, st => $st};	
	if($wtd && defined $MODULES[$wtd-1]){
		$MODULES[$wtd-1]->($q, $global);
	}
	else{
		ReadFromDatabase();
		menu($q, $global);
	}
}

sub save{
	my ($q, $global) = @_;
	my $elnum = $q->param('ElN');
	ReadFromDatabase();
	my $elem = {};
	foreach my $o(@ElNames){
		$elem->{$o}=$q->param($o);
	}
	if(!$elnum){
		@DATABASE=(@DATABASE, $elem);
	}else{$DATABASE[$elnum-1]=$elem;}
	SaveInDatabase();
	menu($q, $global);
}

sub delete{
	my ($q, $global) = @_;
	my $elnum = $q->param('ElN');
	ReadFromDatabase();
	splice(@DATABASE, $elnum-1, 1);
	SaveInDatabase();
	menu($q, $global);
}

sub edit {
	my ($q, $global) = @_;
	ReadFromDatabase();
	my $elnum = $q->param('ElN');
	print $q->header('charset=windows-1251');
	print "<FORM><INPUT TYPE=\"hidden\" NAME =\"ElN\" value=\"$elnum\">
	<INPUT TYPE=\"hidden\" NAME =\"student\" value=\"$global->{st}\">";
	my $str ="";
	foreach my $el(@ElNames) {
		if($elnum){print "<INPUT TYPE=\"Text\" NAME =\"$el\" value=\"$DATABASE[$elnum-1]->{$el}\"><br>";}
		else {print "<INPUT TYPE=\"Text\" NAME =\"$el\" value=\"$el\"><br>";}
	}
	print"<button type=\"submit\" name=\"wtd\" value=\"3\">Сохранить</button></FORM>";	
}