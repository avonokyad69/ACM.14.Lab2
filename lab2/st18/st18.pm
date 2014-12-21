package ST18;
use strict;
use CGI;
use CGI::Carp qw(fatalsToBrowser);
use encoding 'utf8' ;
use URI::Escape;

my $selfurl;
my $St;


my @student = ( 
	"Имя",
	"Фамилия",
	"Возраст",
	"Телефон",
	);
#my %Student;
my @elements =();



sub st18
{
	my @commands = (\&add, 
			   \&edit, 
			   \&del,
			   \&save, 
			   \&load,
			   \&show,
			   \&add_pre_process, 
			   \&edit_pre_process, 
			   \&del_pre_process);
			   
	my ($q, $global) = @_;
	my $cgi_app = new CGI;
	$St = $global->{student};
	$selfurl = $global->{selfurl};
	
	print $cgi_app->header(-type => "text/html", -charset => "UTF-8");
	
	my $act = $cgi_app->param("act");
	# Переданы параметры скрипту ?
	if(defined $act) {
		load();
		$commands[$act]->($cgi_app);
		save();
	}
	# Если нет выводим меню
	else {
	print qq~
			<html>
			    <Head>
			       <title>Лабораторная работа #2</title>
				   <STYLE type="text/css">
					a {
						display: block;
						width:200px;
						height: 25px;
						text-decoration:none;
						background:#f0f0f0;
						padding:5px;
						border: solid 1px #000;
					}
				   </style>
			    </Head>
				<body>
				    <center>
					<h3>Меню</h3>
							<a href="$selfurl?student=$St&act=5" > Показать </a>
						    <a href="$selfurl?student=$St&act=6" > Добавить </a>
						    <a href="$selfurl?student=$St&act=7" > Редактировать </a>
						    <a href="$selfurl?student=$St&act=8" > Удалить </a>
					</center>
				    <BR>
				</body>
				</html>
				    ~;
	}
	# Параметры обработаны формой
	if(defined $cgi_app->param("btn"))
	{
		print $cgi_app->start_html(
			-head=>$cgi_app->meta(
                   {
                     -http_equiv => 'Refresh',
                     -content => '2;URL='.$ENV{'SCRIPT_NAME'}
                   }
                 ));
		print $cgi_app->end_html();
		#print $cgi_app->redirect($ENV{'SCRIPT_NAME'});
	}	
};

1;


sub add_pre_process
{
	print qq~<center><FORM act="$selfurl" name = add_student>
				Имя<BR>
			    <input type=text width = 40 name = "name"> <BR>
			    Фамилия<BR>
			    <input type=text width = 40 name = "surname"> <BR>
			    Возраст<BR>
			    <input type=text width = 40 name = "age"><BR>
				Тел.<BR>
			    <input type=text width = 40 name = "tel"><BR>
			    <INPUT TYPE="HIDDEN" NAME="act" VALUE ="0"/>
			    <INPUT TYPE="HIDDEN" NAME="student" VALUE =$St/>
			    <input type = submit name = "btn" value = "Добавить"/><BR>
				<a href=\"$ENV{'SCRIPT_NAME'}\"><input type ="button" value="Назад в меню"/></a><br>
		    </FORM></center>~;
};

sub edit_pre_process
{
	print qq~<center><FORM act="$selfurl" name = edit_student>
			Индекс:<BR>
		    <input type=text width = 40 name = "index"> <BR>
			Имя:<BR>
		    <input type=text width = 40 name = "name"> <BR>
		    Фамилия:<BR>
		    <input type=text width = 40 name = "surname"> <BR>
		    Возраст:<BR>
		    <input type=text width = 40 name = "age"><BR>
			Телефон:<BR>
		    <input type=text width = 40 name = "tel"><BR>
	    	<INPUT TYPE="HIDDEN" NAME=act VALUE ="1">
	    	<INPUT TYPE="HIDDEN" NAME="student" VALUE =$St/>
		    <input type = submit name = btn  value = "Редактировать"/><BR>
			<a href=\"$ENV{'SCRIPT_NAME'}\"><input type ="button" value="Назад в меню"/></a><br>
	    </FORM></cnter>~;
};


sub del_pre_process
{
	show();
	print qq~	<center><FORM act="$selfurl" name = delete_student>
					Индекс:<BR>
					<input type=text width = 40 name = "index"><BR>
				    <INPUT TYPE="HIDDEN" NAME=act VALUE ="2"> 
				    <INPUT TYPE="HIDDEN" NAME="student" VALUE =$St/>
				    <input type = submit name = btn value = "Delete"/><BR>
			    </FORM></center>~;
};

# Добавление
sub add
{
	my ($params) 		= @_;
	my $name 			= $params->param("name");
	my $surname		    = $params->param("surname");
	my $age				= $params->param("age");
	my $tel			    = $params->param("tel");
	#
	push(@elements,
	{
		$student[0] => $name,
		$student[1] => $surname,
		$student[2] => $age,
		$student[3] => $tel
	});
	print "Добавление...";
};

sub edit
{
	my ($params) 		= @_;
	my $index			= $params->param("index");
	my $name 			= $params->param("name");
	my $surname		    = $params->param("surname");
	my $age				= $params->param("age");
	my $tel			    = $params->param("tel");
	
	if ($index =~ /^\d+$/) 
	{
		if($index >= 0 && $index <= $#elements)
		{
			$elements[$index]->{$student[0]} = $name;
			$elements[$index]->{$student[1]} = $surname;
			$elements[$index]->{$student[2]} = $age;
			$elements[$index]->{$student[3]} = $tel;	
		}
		print "Редактирование...";
	}
	else
	{
		print "Ошибочный индекс !\n";
	};
};


sub del
{
	show();
	my ($params) 		= @_;
	my $index	 		= $params->param("index");
	if ($index =~ /^\d+$/ && $index >= 0 && $index <= $#elements)
	{
		splice @elements, $index, 1;
		print "Удаление элемента с индексом [".$index."]...\n";
	}
	else
	{
		print "Ошибочный индекс !\n";
	};
};
# Вывод данных
sub show
{
	# Строим таблицу
	print '<center><form><table>';
	print "<tr><td>Индекс</td><td>$student[0]</td><td>$student[1]</td><td>$student[2]</td><td>$student[3]</td></tr>";
	my $i = 0;
	# Выводим все хеши хранящиеся внутри массива
	for my $href ( @elements ) 
	{
		print "<tr><td>[".$i++."]</td><td>$href->{$student[0]}</td><td>$href->{$student[1]}</td><td>$href->{$student[2]}</td><td>$href->{$student[3]}</td></tr>";
	}
	print "<tr><td>Всего элементов</td><td colspan=4><center>".scalar @elements."</center></td></tr>";
	print '<tr><td colspan=5><center><input type="submit" value="Назад"/></center></td></tr>';
	print "</table></form></center>";
};
# Сохранение
sub save
{

	dbmopen(my %recs, "My_Student_Base", 0644) || die "Cannot open DBM dbmfile: $!";
	
	%recs = ();
	my $i = 0;
	# Выводим данные в виде строк параметры, внутри строки разделены табуляциями	
	for my $elem ( @elements )
	{
		$recs {$i++} = join("\t", 
			uri_escape($elem->{$student[0]}),
			uri_escape($elem->{$student[1]}),
			uri_escape($elem->{$student[2]}),
			uri_escape($elem->{$student[3]})
			);
	}
	# Закрыли
	dbmclose(%recs);
};
# Загрузка
sub load
{
	# Открыли файл
	dbmopen(my %recs, "My_Student_Base", 0644) || die "Cannot open DBM dbmfile: $!";
	# Очищаем массив
	#splice @elements, 0, $#elements + 1;
	my $i = 0;
	# Читаем 
	while ((my $key, my $val) = each %recs)
	{
		# Получили и разобрали строку
		my @cur_entry = split /\t/, $val;
		push @elements, 
		{
			$student[0] => uri_unescape($cur_entry[0]),
			$student[1] => uri_unescape($cur_entry[1]),
			$student[2] => uri_unescape($cur_entry[2]),
			$student[3] => uri_unescape($cur_entry[3])
		};
	}
	# Закрываем
	dbmclose(%recs);
};