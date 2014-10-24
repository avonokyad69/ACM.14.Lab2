package ST10;

use strict;

use Text::Iconv;
my $iconvTo = Text::Iconv->new('cp866', 'cp1251');
my $iconvFrom = Text::Iconv->new('cp1251', 'cp866');

my %objects;

my %attributes = (
    'name' => 'First Name',
    'lastname' => 'Last Name',
    'age' => 'Age'
);
my @attributesSort = (
    'name',
    'lastname',
    'age',
);

my $currentAction;
my $studentId;

my %ACTIONS = 
(
	'add' => \&add,
	'edit' => \&edit,
	'remove' => \&remove,
	'list' => \&list
);

my %NAMES = 
(
	'add' => 'Add object',
	'edit' => 'Edit object',
	'remove' => 'Remove object',
	'list' => 'List of objects',
	'exit' => 'Exit',
);

sub list
{
    my ($q, $global) = @_;
    
    printHtmlHeader($q, $global);
    
    my @ids = get_ids();
    
    if(scalar @ids == 0) {
        print '<div class="empty">No results.</div>';
    }
    
    print '<div id="items-list">';
    foreach my $id (values @ids) {
        
        my $obj = $objects{$id};
        
        print '<div class="item clearfix">';
        print '<form class="manage-buttons right" method="post" action="' . $global->{selfurl} . '">';
        print '<div class="buttons"><button type="submit" name="action" value="edit">Edit</button> <button type="submit" name="action" value="remove" onclick="return confirm(\'Delete object?\');">&times Delete</button></div>';
        print '<div class="id">#' . ($id + 1) . '</div>';
        print '<input type="hidden" name="student" value="' . $studentId . '" /><input type="hidden" name="id" value="' . ($id + 1) . '" />
        </form><div class="clearfix"></div>';
        
        foreach my $key (values @attributesSort) {
            print '<div class="row clearfix">';
            print '<span class="label">' . $attributes{$key} . ':</span>';
            print '<span class="value">' . encode_entities($iconvTo->convert($obj->{$key})) . '</span>';
            print '</div>';
        }
        
        print '</div>';
    }
    print '</div>';
    
    printHtmlFooter();
}

sub edit
{
    my ($q, $global) = @_;
    
    my $id = $q->param('id');
    $id--;
    
    if(!defined $objects{$id}) {
        printErrorMessage($q, $global, 'Object not found.');
        return;
    }
    
    if($q->param('save')) {
        foreach my $key (keys %attributes) {
            $objects{$id}->{$key} = $iconvFrom->convert($q->param('field_' . $key));
        }
        
        save();
        print $q->redirect($global->{selfurl} . '?student=' . $studentId);
    }
    
    printItemForm($q, $global, $id, $objects{$id}, 'edit');
}

sub add
{
    my ($q, $global) = @_;
    
    my @ids = get_ids();
    my $id = 0;
    
    if(scalar @ids != 0) {
        $id = $ids[scalar @ids - 1]; # scalar @ids ¢®§¢à é ¥â ¤«¨­ã ¬ áá¨¢ 
        $id++;
    }
    
    my %obj;
    $objects{$id} = {};
    foreach my $key (keys %attributes) {
        $objects{$id}->{$key} = '';
    }
    
    if(!defined $objects{$id}) {
        printErrorMessage($q, $global, 'Object not found.');
        return;
    }
    
    if($q->param('save')) {
        foreach my $key (keys %attributes) {
            $objects{$id}->{$key} = $iconvFrom->convert($q->param('field_' . $key));
        }
        
        save();
        print $q->redirect($global->{selfurl} . '?student=' . $studentId);
    }
    
    printItemForm($q, $global, $id, $objects{$id}, 'add');
}

sub printItemForm
{
    my ($q, $global, $id, $obj, $action) = @_;
    
    printHtmlHeader($q, $global);
    
    print '<div class="item clearfix">';
    if($id) {
        print '<div class="manage-buttons right"><div class="id">#' . ($id + 1) . '</div></div><div class="clearfix"></div>';
    }
    print '<form class="item-form" method="post" action="' . $global->{selfurl} . '">';
    print '<input type="hidden" name="student" value="' . $studentId . '" />';
    print '<input type="hidden" name="id" value="' . ($id + 1) . '" />';
    print '<input type="hidden" name="action" value="' . $action . '" />';

    foreach my $key (values @attributesSort) {
        print '<div class="row clearfix">';
        print '<span class="label">' . $attributes{$key} . ':</span>';
        print '<span class="value"><input type="text" name="field_' . $key . '" value="' . encode_entities($iconvTo->convert($obj->{$key})) . '" /></span>';
        print '</div>';
    }
    
    print '<div class="row clearfix"><span class="label"></span><span class="value"><button type="submit" name="save" value="1">Save</button></span></div>';
    print '</form></div>';
    
    printHtmlFooter();
}

sub remove
{
    my ($q, $global) = @_;
    
    my $id = $q->param('id');
    $id--;
       
    if($q->request_method() != 'POST') {
        printErrorMessage($q, $global, 'Bad request.');
        return;
    }
    
    if(!defined $objects{$id}) {
        printErrorMessage($q, $global, 'Object not found.');
        return;
    }
    
    delete $objects{$id};
    save();
    
    print $q->redirect($global->{selfurl} . '?student=' . $studentId);
}

sub save
{
    my $fileName = 'st10/data/data';
    
    if(-e $fileName . '.dir') {
        unlink($fileName . '.dir');
    }
    if(-e $fileName . '.pag') {
        unlink($fileName . '.pag');
    }
    
    if(!(-w $fileName)) {
        #die "File '$fileName' doesn't have write permission";
    }

    my %hash;
    dbmopen(%hash, $fileName, 0666);
    
    my $template = '';
    foreach my $key (keys %attributes) {
        $template .= 'u i ';
    }
    foreach my $key (keys %objects) {
        my $code = 'pack("' . $template . '"';
        foreach my $attr (sort keys %attributes) {
            my $c = '$objects{$key}->{' . $attr . '}, 1';
            $code .= ', ' . $c;
        }
        $code .= ');';
        
        my $packed;
        eval '$packed = ' . $code;

        $hash{$key} = $packed;
    }
    
    dbmclose(%hash);
}

sub load
{
    my $fileName = 'st10/data/data';
    
    %objects = ();
    
    my %hash;
    dbmopen(%hash, $fileName, 0666);
    
    my $template = '';
    foreach my $key (keys %attributes) {
        $template .= 'u i ';
    }
    my @attr_keys = sort keys %attributes;
    foreach my $key (keys %hash) {
        my @d = unpack($template, $hash{$key});
        $objects{$key} = {};
        my $i = 0;
        foreach my $k (keys @d) {
            if(($k % 2) != 0) {
                next;
            }
            $objects{$key}->{$attr_keys[$i]} = $d[$k];
            $i++;
        }
    }
    
    dbmclose(%hash);
}

sub st10
{
    my ($q, $global) = @_;
    
    $studentId = int($q->param('student'));
    
    load();

    my $action = $q->param('action');
    if(defined $ACTIONS{$action}) {
        $currentAction = $action;
        $ACTIONS{$action}->($q, $global);
    } else {
        $currentAction = 'list';
        $ACTIONS{'list'}->($q, $global);
    }
}

sub get_ids
{
    my @ids;
    foreach my $id (keys %objects) {
        push @ids, $id;
    }
    @ids = sort {$a<=>$b} @ids;
    
    return @ids;
}

sub trim 
{
    my $s = shift; $s =~ s/\s+$//g; 
    return $s;
}

sub printErrorMessage
{
    my ($q, $global, $message) = @_;
    
    printHtmlHeader($q, $global);
    print '<div class="flash-error">' . $message . '</div>';
    printHtmlFooter();
}

sub printHtmlHeader
{
    my ($q, $global) = @_;
    
    my $css = getCss();
    my $menu = getMenu($q, $global);
    
    print $q->header('Content-type: text/html; charset=cp1251');
    
    print <<HTML;
<!DOCTYPE html>
<html>
    <head>
        <meta charset="cp1251" />
        <title>Kartoteka</title>
        <style type="text/css">
        $css
        </style>
    </head>
    <body>
        <div class="page-header">
            <h1 class="left">Kartoteka</h1>
            $menu
            <div class="clearfix"></div>
        </div>
HTML
}

sub printHtmlFooter
{
    print <<HTML;
        <div id="footer">
        &copy; 2014 Petr Kuklianov
        </div>
    </body>
</html>    
HTML
}

sub getMenu
{
    my ($q, $global) = @_;
    
    my $html = '<ul id="menu">
    <li><a href="' . $global->{selfurl} . '?student=' . $studentId . '&action=list">List of objects</a></li>
    <li><a href="' . $global->{selfurl} . '?student=' . $studentId . '&action=add">Add object</a></li>
    <li><a href="' . $global->{selfurl} . '">Exit</a></li>
</ul>';
    
    return $html;
}

sub encode_entities
{
    my ($str) = @_;
    
    $str =~ s/"/&quot;/g;
    $str =~ s/'/&apos;/g;
    $str =~ s/</&lt;/g;
    $str =~ s/>/&gt;/g;
    
    return $str;
}

sub getCss
{
    return <<CSS;
.clearfix {
  *zoom: 1;
}

.clearfix:before,
.clearfix:after {
  display: table;
  line-height: 0;
  content: "";
}

.clearfix:after {
  clear: both;
}
.left {
    float: left;
}
.right {
    float: right;
}
body {
    font-family: Arial, sans-serif;
    margin: 1em 5em;
    font-size: 16px;
}
#footer {
    color: gray;
    font-size: 8pt;
    border-top: 1px solid #aaa;
    padding-top: 1em;
    margin-top: 3em;
}
a {
    color: #08c;
}
a:hover {
    text-decoration: none;    
}
.page-header {
    border-bottom: 1px solid #ddd;
    margin-bottom: 20px;
}
h1 {
    color: #5a5a5a;
    margin: 0px 10px 5px 0px;
}
#menu {
    list-style: none;
    margin-top: 10px;
    float: left;
}
#menu li {
    float: left;
    margin-right: 10px;
    padding-right: 10px;
    border-right: 1px solid #ccc;
}
#menu li:last-child {
    border-right: none;
}
#menu li.active a {
    font-weight: bold;
    text-decoration: none;
}
.item {
    border: 1px solid #ccc;
    border-radius: 5px;
    padding: 3px 10px 10px;
    margin-bottom: 10px;
    width: 600px;
}
.item .id {
    float: left;
    color: #3a87ad;
    font-weight: bold;
    margin-top: 3px;
    margin-left: 10px;
}
.item .label {
    float: left;
    width: 150px;
    min-height: 10px;
    font-size: 13px;
    font-weight: bold;
    color: #666;
    display: block;
}
.item .value {
    float: left;
    width: 445px;
    border-bottom: 1px dashed #ddd;
    margin-bottom: 5px;
    padding-bottom: 5px;
}
.item form.manage-buttons {
    float: right;
}
.item form.manage-buttons .buttons {
    float: left;
}
.item-form {
    margin-top: 5px;
}
div.flash-error, div.flash-notice, div.flash-success {
    border: 2px solid #DDDDDD;
    margin-bottom: 1em;
    padding: 0.8em;
}
div.flash-error {
    background: none repeat scroll 0 0 #FBE3E4;
    border-color: #FBC2C4;
    color: #8A1F11;
}
div.flash-notice {
    background: none repeat scroll 0 0 #FFF6BF;
    border-color: #FFD324;
    color: #514721;
}
div.flash-success {
    background: none repeat scroll 0 0 #E6EFC2;
    border-color: #C6D880;
    color: #264409;
}
div.flash-error a {
    color: #8A1F11;
}
div.flash-notice a {
    color: #514721;
}
div.flash-success a {
    color: #264409;
}
CSS
}
