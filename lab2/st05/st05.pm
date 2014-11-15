package ST05;
use strict;
use CGI::Carp qw(fatalsToBrowser);
my $n = new CGI;
my %DATA;
my $student;
my $selfurl = "lab2.cgi";


sub st05
{
        my ($q, $global) = @_;
        $student = $global->{student};
        
        dbmopen(%DATA, 'lab2/st05/data1', 0666);
        print "Content-type: text/html; charset=windows-1251\n\n";
        ShowHeader ();

        my %MENU = ('doedit' => \&DoEdit,
                    'dodelete' => \&DoDelete,
                    'edit' => \&Edit);

        my $type =  $n->param("type");

        if($MENU{$type})
        {
                $MENU{$type}->();
        }

        ShowList();
        ShowFooter ();
        dbmclose(%DATA);
}

sub ShowHeader
{
        print <<ENDOFHTML;
<html>
<head>
</head>
<body>
<h1>Список студентов</h1>
ENDOFHTML
}

sub ShowList
{
ShowForm() unless ($n->param('type') eq 'edit');

        print <<STARTLIST;

<table>
<tr>
<td width = 235 bgcolor = #FAF0E6>
<strong>Фамилия</strong> </td>
<td width = 235 bgcolor = #FAF0E6>
<strong>Имя</strong> </td>
<td width = 80 bgcolor = #FAF0E6>
<strong>Возраст</strong> </td>
</tr>
STARTLIST

        foreach my $id(sort {$a <=> $b} keys %DATA)
        {
                next if($id eq 'MAXID');
                PrintItem(GetItem($id));
        }

        print '</table>';
}

sub ShowForm
{
        my ($item) = @_;
        print <<ENDOFFORM;
<table>
<tr>
<form action = $selfurl method = "post">
<input type = "hidden" name = "student" value = $student/>
<td width = 235>
<input required type = "text" name = "Surname" size = 29 maxlength = 30 value = $item->{Surname} > </td>
<td width = 235>
<input required type = "text" name = "Name" size = 29 maxlength = 30 value = $item->{Name}></td>
<td width = 80>
<input required type = "number" name = "Age" min = 15 max = 99 size = 10 maxlength = 2 value = $item->{Age}></td>
<input type = "hidden" name = "type" value = "doedit">
<input type = "hidden" name = "id" value = $item->{id}>
<td width = 50>
<input type = "submit" width = 40 value = "+"</td>
</tr>
</table>
</form>
ENDOFFORM
}

sub PrintItem
{
        my ($item) = @_;

       print <<ENDOFITEM;
<p align=left>

<tr>
<td width = 235 bgcolor = #FAF0E6>
$item->{Surname}</td>

<td width = 235 bgcolor = #FAF0E6>
$item->{Name}</td>

<td width = 80 bgcolor = #FAF0E6>
$item->{Age} </td >
<td>
<form action = $selfurl method = "post">
<input type = "hidden" name = "student" value = $student/>
<input type = "hidden" name = "type" value = "dodelete">
<input type = "hidden" name = "id" value =  $item->{id}>
<input type = "submit" value = "-"></td>
</form>
<td width = 100>
<form action = $selfurl method = "post">
<input type = "hidden" name = "student" value = $student/>
<input type = "hidden" name = "type" value = "edit">
<input type = "hidden" name = "id"   value =  $item->{id}>
<input type = "submit" value = "Edit"></td>
</form>
</tr>

ENDOFITEM
}

sub DoEdit
{
        my $id = 0+$n->param('id');
        $id = ++$DATA{MAXID} unless $id;

        $DATA{$id} = join ('::', $n->param("Surname"), $n->param("Name"), $n->param("Age"));
}

sub DoDelete
{
        my $id = 0+$n->param('id');
        delete $DATA{$id};
}

sub Edit
{
        my $id = 0+$n->param('id');
        ShowForm(GetItem(0+$n->param('id')));
}

sub GetItem
{
        my ($id) = @_;

        my $item = {id => $id};
        ($item->{Surname}, $item->{Name}, $item->{Age}) = split(/::/, $DATA{$id});
        return $item;
}

sub ShowFooter
{
        print <<ENDOFHTML;
</body>
</html>
ENDOFHTML
}