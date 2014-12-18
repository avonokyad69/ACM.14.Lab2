package ST03;
use strict;
use CGI;
use CGI::Carp qw(fatalsToBrowser);

my $data = "test/data";

my $q;
my %hash;

my $student;
my $selfurl = "lab2.cgi";

my %oplist = (
  del => \&confirm,
  yes => \&remove,
  add => \&add,
  edt => \&edit, 
  set => \&set 
);

sub st03 {
	$q = shift;
	my $title = 'Список книг';

	$q->charset('utf8');
	print $q->header;
	print $q->start_html($title);
	print $q->h1($title);

	dbmopen(%hash, $data, 0666);

	my $done;
	foreach my $op (keys %oplist) {
		if (defined($q->param($op))) {
	  		$oplist{$op}->();
			$done = 1;
		}
	}
	normal() unless $done;

	print $q->h2('Список книг');
	print $q->start_table();
	print $q->Tr([
		$q->th(['Автор', 'Название', 'Год']),
	]);

	foreach my $id (sort keys %hash) {
		$q->param('id', $id);
		print $q->start_form(-action => $q->url(), -method => 'get'),
			$q->hidden('id', $id),
			$q->Tr(
				$q->td([
					split ("##", $hash{$id}),
					$q->submit('edt', 'Изменить'),
					$q->submit('del', 'Удалить'),
				]),
		
			),
			$q->end_form;
	}
	print $q->end_table;

	dbmclose(%hash);
	print $q->end_html;
}

sub normal {
	print $q->h2('Добавление данных');
	print $q->start_table();
	print $q->Tr([
		$q->th(['Автор', 'Название', 'Год']),
		$q->start_form(-action => $q->url(), -method => 'post'),
		$q->td([
			$q->textfield(-name => 'a_a', -size => 20),
			$q->textfield(-name => 'a_n', -size => 30),
			$q->textfield(-name => 'a_y', -size => 5),
			$q->submit('add', 'Добавить'),
		]),
		$q->end_form
	]);
	print $q->end_table;
}

sub edit {
    my $id = $q->param('id');
	my @temp = split "##", $hash{$id};
	print $q->h2('Изменение данных');
	print $q->start_table();
	print $q->Tr([
		$q->th(['Автор', 'Название', 'Год']),
		$q->start_form(-action => $q->url(), -method => 'post'),
		$q->hidden('id', $id),
		$q->td([
			$q->textfield(-name => 'e_a', -value => $temp[0], -size => 20),
			$q->textfield(-name => 'e_n', -value => $temp[1], -size => 30),
			$q->textfield(-name => 'e_y', -value => $temp[2], -size => 5),
			$q->submit('set', 'Изменить'),
		]),
		#$q->end_formmy $q
	]);
	print $q->end_table;
}

sub confirm {
    my $id = $q->param('id');
	my @temp = split "##", $hash{$id};
	print $q->h2('Подтвердите удаление записи');
	print $q->start_table();
	print $q->Tr([
		$q->th(['Автор', 'Название', 'Год']),
		$q->start_form(-action => $q->url(), -method => 'post'),
		$q->hidden('id', $id),
		$q->td([
			split ("##", $hash{$id}),
			$q->submit('yes', 'Удалить'),
		]),
		$q->end_form
	]);
	print $q->end_table;
}

sub add {
    my $id = [sort keys %hash]->[-1] + 1;
    my $autor = $q->param('a_a');
    my $title = $q->param('a_n');
    my $year = $q->param('a_y');
	if ($autor . $title . $year) {
		print $q->h2('Запись добавлена');
		$hash{$id} = join "##", ($autor, $title, $year);
	}
	normal();
}

sub set {
    my $id = $q->param('id');
    my $autor = $q->param('e_a');
    my $title = $q->param('e_n');
    my $year = $q->param('e_y');
	if ($autor . $title . $year) {
		print $q->h2('Запись изменена');
		$hash{$id} = join "##", ($autor, $title, $year);
	}
	normal();
}

sub remove {
    my $id = $q->param('id');
	print $q->h2('Запись удалена');
	delete $hash{$id}; 
	normal();
}

1;
