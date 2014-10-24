#!C:/Perl64/bin/Perl.exe
use strict;
use CGI;
use CGI::Carp qw(fatalsToBrowser);

my @DATABASE=();
my $pathFile='654';
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
	
Lab2Main();

sub menu{
	my ($q, $global) = @_;
	print $q->header('charset=windows-1251');
	my $i = 0;
	print "<pre><table cellspacing=\"0\"><tr><th>№&nbsp;</th><th>Название эл-та&nbsp;</th><th>Del</th></tr>";
	foreach my $s(@DATABASE){
		$i++;
		print "<tr><td>$i</td><td><a href=\"$global->{selfurl}?ElN=$i&wtd=1\">$s->{$ElNames[0]}</a></td><td>&nbsp;<a href=\"$global->{selfurl}?ElN=$i&wtd=2\">X</a></td>";
	}
	print "</table></pre><FORM><button type=\"submit\" name=\"wtd\" value=\"1\">Добавить</button></FORM>";
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

sub Lab2Main{
	my $q = new CGI;
	my $st	= 0+$q->param('ElN');
	my $wtd = 0+$q->param('wtd');
	my $global = {selfurl => $ENV{SCRIPT_NAME}, ElN => $st};	
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
	dbmopen(my %g, $pathFile, 0644);
	my $str = "";
	foreach my $o(@ElNames){
		my $par=$q->param($o);
		$str.="$o<==>$par<===>";
	}
	if (!$global->{ElN}){
		$g{keys %g} = $str;
	}else{
		$g{$global->{ElN}-1} = $str;
	}
	dbmclose(%g);
	ReadFromDatabase();
	menu($q, $global);
}

sub delete{
	my ($q, $global) = @_;
	ReadFromDatabase();
	splice(@DATABASE, $global->{ElN}-1, 1);
	my $i=0;
	dbmopen(my %g, $pathFile, 0644);
	%g = ();
	foreach my $ref2hash(@DATABASE) {
		foreach my $o(@ElNames) {
			$g{$i} = $g{$i}."$o<==>$ref2hash->{$o}<===>";
		}
		$i++;
	}
	dbmclose(%g);
	menu($q, $global);
}

sub edit {
	my ($q, $global) = @_;
	ReadFromDatabase();
	print $q->header('charset=windows-1251');
	print "<FORM><INPUT TYPE=\"hidden\" NAME =\"ElN\" value=\"$global->{ElN}\">";
	my $str ="";
	foreach my $el(@ElNames) {
		if($global->{ElN}){print "<INPUT TYPE=\"Text\" NAME =\"$el\" value=\"$DATABASE[$global->{ElN}-1]->{$el}\"><br>";}
		else {print "<INPUT TYPE=\"Text\" NAME =\"$el\" value=\"$el\"><br>";}
	}
	print"<button type=\"submit\" name=\"wtd\" value=\"3\">Сохранить</button></FORM>";	
}