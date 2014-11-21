#!C:/Dwimperl/perl/bin/perl.exe

package ST15;
use strict;
use CGI;
use CGI::Carp qw(fatalsToBrowser);

my @Objects=();
undef @Objects;
my $Path='basename';

my @RefToMenuItems =
(
	\&edit,
	\&delete,
	\&save
);
my @Attributes=(
	'Name',
	'Attribute1',
	'Attribute2',
	'Attribute3',
	);
	
sub st15{
	Lab2Main();
 }

sub menu{
	my ($q, $global) = @_;
	print $q->header('charset=windows-1251');
	my $i = 0;
	print 
	"<pre>
		<table cellspacing=\"0\">
			<tr>
				<th>
					№&nbsp;
				</th>
				<th>
					El Name&nbsp;
				</th>
				<th>
					Delete
				</th>
			</tr>";
	foreach my $s(@Objects){
		$i++;
		print  "<tr>
				<td>
					$i
				</td>
				<td>
					<a href=\"$global->{selfurl}?Num=$i&action=1&student=$global->{st}\">
						$s->{$Attributes[0]}
					</a>
				</td>
				<td>
					&nbsp;
					<a href=\"$global->{selfurl}?Num=$i&action=2&student=$global->{st}\">
						Del
					</a>
				</td>
			</tr>";
	}
	print 
		"</table>
	</pre>
	<FORM>
		<button type=\"submit\" name=\"action\" value=\"1\">
			Add
		</button>
		<INPUT TYPE=\"hidden\" NAME =\"student\" value=\"$global->{st}\">
		<a href=\"$global->{selfurl}\">
			Exit
		</a>
	</FORM>";
}

sub LoadFromFile{
	dbmopen(my %hash, $Path, 0);
	foreach my $k(sort keys %hash){
		my $ref = {};
		my @Buff1 = split(/<;>/, $hash{$k});
		foreach(@Buff1){
			my ($key, $val) = split(/<,>/, $_);
			$ref->{$key}=$val;
		}
		@Objects=(@Objects,$ref);
	}
	dbmclose(%hash);
} 	

sub SaveToFile{
	dbmopen(my %hash, $Path, 0644) or die;
	%hash = ();
	my $counter=0;
	foreach my $ref(@Objects){
		foreach(@Attributes){
			$hash{$counter} .= "$_<,>$ref->{$_}<;>";
		}
		$counter ++;
	}
	dbmclose(%hash)
}


sub Lab2Main{
	my $q = new CGI;
	my $st	= 0+$q->param('student');
	my $act = 0+$q->param('action');
	my $global = {selfurl => $ENV{SCRIPT_NAME}, st => $st};	
	if($act && defined $RefToMenuItems[$act-1]){
		$RefToMenuItems[$act-1]->($q, $global);
	}
	else{
		LoadFromFile();
		menu($q, $global);
	}
}

sub save{
	my ($q, $global) = @_;
	my $i = $q->param('Num');
	LoadFromFile();
	my $elem = {};
	foreach(@Attributes){
		$elem->{$_}=$q->param($_);
	}
	if(!$i){
		@Objects=(@Objects, $elem);
	}
	else{
		$Objects[$i-1]=$elem;
	}
	SaveToFile();
	menu($q, $global);
}

sub delete{
	my ($q, $global) = @_;
	my $i = $q->param('Num');
	LoadFromFile();
	splice(@Objects, $i-1, 1);
	SaveToFile();
	menu($q, $global);
}

sub edit {
	my ($q, $global) = @_;
	LoadFromFile();
	my $i = $q->param('Num');
	print "Content-type: text/html\n\n";
	print 
	"<FORM>
		<INPUT TYPE=\"hidden\" NAME =\"Num\" value=\"$i\">
		<INPUT TYPE=\"hidden\" NAME =\"student\" value=\"$global->{st}\">";
	my $str ="";
	foreach my $el(@Attributes){
		if($i){
			print 
			"<INPUT TYPE=\"Text\" NAME =\"$el\" value=\"$Objects[$i-1]->{$el}\">
			<br>";
		}
		else {
			print 
			"<INPUT TYPE=\"Text\" NAME =\"$el\" value=\"$el\">
			<br>";
		}
	}
	print
		"<button type=\"submit\" name=\"action\" value=\"3\">
			Save
		</button>
	</FORM>";	
}
