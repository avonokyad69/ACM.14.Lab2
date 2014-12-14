package ST17;
use strict;
use CGI;
use CGI::Carp qw(fatalsToBrowser);
my $selfurl;
my $St;


my %Car;

sub st17
{
	my ($q, $global) = @_;
	my $cgi_app = new CGI;
	$St = $global->{student};
	$selfurl = $global->{selfurl};
	print "Content-type: text/html; charset=windows-1251\n\n";
	print qq~
			<html>
			    <Head>
			       <title>Tikhonov_Lab2</title>
			    </Head>
			    <h1>The AutoPark of Your Dream</h1>
			    <h3>Menu of actions:</h3>
			    <body>
				    
					    <ul type="disc">
						    <li> <a href="$selfurl?student=$St&act=0" > Show AutoPark </a>	</li>
						    <li> <a href="$selfurl?student=$St&act=6" > Add new CAR </a> </li>
						    <li> <a href="$selfurl?student=$St&act=7" > Edit CAR </a> </li>
						    <li> <a href="$selfurl?student=$St&act=8"> Delete CAR from list </a> </li>
						</ul>
					
				    <BR>
				    ~;

	my @commands = (\&view_list, 
			   \&add_elem, 
			   \&edit_elem,
			   \&del_elem, 
			   \&save_data, 
			   \&load_list, 
			   \&add_elem_view, 
			   \&edit_elem_view, 
			   \&del_elem_view);
	
	my $act = $cgi_app->param("act");

	if(defined $act) {
		load_list();
		$commands[$act]->($cgi_app);
		save_data();
	};

    print "</body><a href=\"$selfurl\">Back to list of lab's</a><br></html>";
		
};

1;


sub add_elem_view
{
	print qq~<FORM act="$selfurl" name = Save>
				Model of car:<BR>
			    <input type=text width = 40 name = "model_of_car"> <BR>
			    Power of engine:<BR>
			    <input type=text width = 40 name = "power_of_engine"> <BR>
			    Price of car:<BR>
			    <input type=text width = 40 name = "price_of_car"><BR>
			    <INPUT TYPE="HIDDEN" NAME="act" VALUE ="1"/>
			    <INPUT TYPE="HIDDEN" NAME="student" VALUE =$St/>
			    <input type = submit name = "btn" value = "Save"/><BR>
		    </FORM>~;
};

sub edit_elem_view
{
	print qq~<FORM act="$selfurl" name = edit_car_view>
			Model of CAR:<BR>
		    <input type=text width = 40 name = "model_of_car"> <BR>
		    Power of engine:<BR>
		    <input type=text width = 40 name = "power_of_engine"> <BR>
		    Price of CAR:<BR>
		    <input type=text width = 40 name = "price_of_car"><BR>
	    	<INPUT TYPE="HIDDEN" NAME=act VALUE ="2">
	    	<INPUT TYPE="HIDDEN" NAME="student" VALUE =$St/>
		    <input type = submit name = btn  value = "Confirm and Save"/><BR>
	    </FORM>~;
};


sub del_elem_view
{
	print qq~	<FORM act="$selfurl" name = Delete_car_view>
					Model of Car:<BR>
				    <input type=text width = 40 name = "model_of_car">
				    <INPUT TYPE="HIDDEN" NAME=act VALUE ="3"> 
				    <INPUT TYPE="HIDDEN" NAME="student" VALUE =$St/>
				    <input type = submit name = btn value = "Delete"/><BR>
			    </FORM>~;
};


sub add_elem
{
	my ($params) = @_;
	my $model_car       = $params->param("model_of_car");
	my $power_of_engine = $params->param("power_of_engine");
	my $price_of_car    = $params->param("price_of_car");
	
	$Car{$model_car} = { 
						 Power=> $power_of_engine, 
						 Price=> $price_of_car
					   };
};

sub del_elem
{
	my ($params) = @_;
	my $model_car = $params->param("model_of_car");
	if(exists($Car{$model_car}))
	{	
		delete($Car{$model_car});
	}
	else
	{
		print "Car with name ".$model_car." doesn't exist!\n";
	};
};

sub view_list
{
	load_list();
	my $list_car;
	$list_car .=  "<ul type=disc>";
	while((my $model_car,my $item) = each %Car)
	{
		$list_car .= "<li>Model of car: " .$model_car.", ";
		while((my $key,my $data) = each %{$Car{$model_car}})
		{
			$list_car .=$key.": ".$data.", ";
		};
		$list_car .= "</li>";
	};
	$list_car .= "</ul>";	
	print $list_car;
};

sub edit_elem
{
	my ($params) = @_;
	my $model_car       = $params->param("model_of_car");
	my $power_of_engine = $params->param("power_of_engine");
	my $price_of_car    = $params->param("price_of_car");

	if(exists($Car{$model_car}))
	{
		$Car{$model_car} = {Power=> $power_of_engine, Price=> $price_of_car};
	}
	else
	{
		print "Car with name ".$model_car." doesn't exist!\n";
	};
};

sub save_data
{
		my %hash_data;
		dbmopen(%hash_data,"My_AutoPark",0644) || die "Error open to file!";
		my $tmp = undef();
		
		while((my $model_car,my $item) = each %Car)
		{
			$tmp = undef();
			foreach my $itemKey (keys %{$Car{$model_car}})
			{
				$tmp = $tmp.${$Car{$model_car}}{$itemKey}.",";
			};		
			$hash_data{$model_car} = $tmp;
		};
		my @bufArr = %hash_data;
		dbmclose(%hash_data);		
	
};

sub load_list
{
		my %hash_data = undef();
		my $tmp;
		dbmopen(%hash_data,"My_AutoPark",0644) || die "Error open to file!";

		while((my $model_car,my $item) = each %hash_data)
		{
			my @tmp_buf = undef();
			@tmp_buf =  split(/,/, $hash_data{$model_car}); 
			$Car{$model_car} = {
								Power => @tmp_buf[0], 
								Price =>  @tmp_buf[1]
							   };
		};
		dbmclose(%hash_data);
};
