#!/usr/bin/perl -w

use 5.014;
use strict;
use warnings;

my $readin = "({{{{1'b0,var_19},1'b0},1'b0},1'b0} + {{{{1'b0,1'b0},1'b0},1'b0},var_19});";
#my $readin = "((-{2'b00,tmp_2}) * var_10);"; 
#my $readin = "((var_16 + var_17) + var_18);";
#my $readin = "(((-{2'b00,tmp_2}) * var_10) + (((-{7'b0000000,I4}) * var_10) + (((-{7'b0000000,I5}) * var_10) + (((-{7'b0000000,I6}) * var_10) + ((var_11 * var_11) + 29'b00000000000000000000000000000)))));";
#my $readin = "{3'b000,((24'b000000000000000000000001 * var_18) + ((24'b000000000000000000000001 * var_17) + ((24'b000000000000000000000001 * var_16) + 24'b000000000000000000000000)))};";
my @items = split /\s+/, $readin;
chomp(@items);

my $i = 0;  # split with comma
while($items[$i])  {
	if ( ($items[$i] =~ /,/) && (index($items[$i], ",")!= 0) )  {
		my @comma = split /,/, $items[$i];
		my $new_comma = join " , ", @comma;
		@comma = split /\s+/, $new_comma;
		splice(@items, $i, 1, @comma);
		$i += 2;
	}
	$i ++;
}

$i = 0;
my $flag_unit = 0;
my $cnt_unit = 0;
my $unit = 99;
my $cnt_tmp = 0;
my $def_var = "ORIGIN";

my $minus = 0;
my $flag_minus = 0;

#print "@items\n";

while ($items[$i])  #maybe not full set; also can try eq "==" etc.
{
#################################################################################### fix this! use eq, see what happens
################ we only have , + * < == here######################################
	if ($items[$i] =~ /\+|\-|\*|\<|\=\=|,/)  {
		$cnt_unit ++;
		if (($items[$i] =~ /\-/) && ($items[$i] =~ /\(/) && ($items[$i] =~ /\)/) )  {$flag_minus = 1; $minus = $i;}
		#print "I'm in!\n$items[$i]\n";
		#my $front_end = substr($items[$i-2], -1, 1);
		#my $rear_init = substr($items[$i], -1, 1);  #maybe no need to pick only last character...
		#if ($front_end =~ /}|\)/)  {$i++; next;}
		#if ($rear_init =~ /{|\(/)  {$i++; next;}
		if (!$i) {$i++; next;}
		if ($items[$i-1] =~ /\}|\)/)  {$i++; next;}
		if ($items[$i+1] =~ /\{|\(/)  {$i++; next;}
		if ($items[$i] =~ /\-/) {$i++; next;}
		if (!$flag_unit) {$unit = $i;}
		$flag_unit = 1;
	}
	$i ++;
}
#print "$cnt_unit\n";
#print "$items[$unit-1]    AND    $items[$unit]    AND    $items[$unit+1]\n";

##################################################################################### if no unit? Then directly assign!!
if (!$cnt_unit)  {}#{goto direct assign: $def_var = $item[0]}

while ($cnt_unit)  {
	
	if ((!$flag_minus) && (!$flag_unit)) {print "What a mess!!!!\n"; last;}
	#take out part w/o (){}
	my $tmp_var01 = $items[$unit-1];
	my $tmp_var02 = $items[$unit+1];
##################################################################################### judge "-" "[:]"
#first, need to fix judge "-" as one unit operator
	if ($flag_minus)  {
		my $pos_minus = index ($items[$minus], "-");
		my $end_minus = index ($items[$minus], ")");
		my $start_minus = $pos_minus -1;
		$tmp_var01 = substr($items[$minus], $pos_minus+1, $end_minus-$pos_minus-1);
		print "I got an minus, var: $tmp_var01\n";
		substr($items[$minus], $start_minus, $end_minus-$start_minus+1) = "my_var_$cnt_tmp";
		$cnt_tmp ++;
		$flag_minus = 0;
		$cnt_unit --;
		$flag_unit = 0;
		$i = 0;
		while ($items[$i])
		{
			if ($items[$i] =~ /\+|\-|\*|\<|\=\=|,/)  {
				if (($items[$i] =~ /\-/) && ($items[$i] =~ /\(/) && ($items[$i] =~ /\)/) )  {
					print "I found a minus again!\n";
					$flag_minus = 1; $minus = $i;last;
				}
				if (!$i) {$i++; next;}
				if ($items[$i-1] =~ /\}|\)/)  {$i++; next;}
				if ($items[$i+1] =~ /\{|\(/)  {$i++; next;}
				if ($items[$i] =~ /\-/) {$i++; next;}
				if (!$flag_unit) {$unit = $i;}
				$flag_unit = 1;
			}
			$i ++;
		}
		next;
	}













	while ($tmp_var01 =~ /\{|\(/) {$tmp_var01 = substr($tmp_var01, 1);}
	while ($tmp_var02 =~ /\}|\)/) {$tmp_var02 = substr($tmp_var02, 0, length($tmp_var02)-1);}
	
	#search 2 operands in hash, find out the bits
	
	# for example, C = A + B, we are getting representing for C, and change A + B to C.
	my $name_C;
	my $tmp_long = $items[$unit-1].$items[$unit+1];
	my $br_left; my $br_right;
	if ($items[$unit] eq ",")  {
		$br_left = rindex ($tmp_long, "{");
		$br_right = index ($tmp_long, "}");
		print "Catenated!\n";
	}
	else  {
		$br_left = rindex ($tmp_long, "(");
		$br_right = index ($tmp_long, ")");
	}
	substr($tmp_long, $br_left, 1) = "";
	substr($tmp_long, $br_right - 1, 1) = "";  #because the length of str will decrease when we remove first one
	
	$cnt_unit --;  #we have successfully got one
	if ($cnt_unit)  {  #not the last one, build new my_var
		$name_C = "my_var_$cnt_tmp";
		$cnt_tmp ++;
	}
	else {$name_C = $def_var;}  #last one, just give head var name
	
	
	###################
	
	my $clip = substr($tmp_long, $br_left, $br_right - $br_left -1);
	print "Clipped string: $clip\n";
	substr($tmp_long, $br_left, $br_right - $br_left -1) = $name_C;  #substitude name of C
	
	given($items[$unit])  {  #okay, output with A, B, C and maybe other parameter like n
		when(/\+/)  {print "constrains about $tmp_var01 + $tmp_var02 : \n";}
#		when(/\-/)  {print "constrains about $tmp_var01 - $tmp_var02 : \n";}
		when(/\*/)  {print "constrains about $tmp_var01 * $tmp_var02 : \n";}
#		when(/\%/)  {print "constrains about $tmp_var01 % $tmp_var02 : \n";}
		when(/\</)  {print "constrains about $tmp_var01 < $tmp_var02 : \n";}
#		when(/\<\=/)  {print "constrains about $tmp_var01 <= $tmp_var02 : \n";}
#		when(/\>/)  {print "constrains about $tmp_var01 > $tmp_var02 : \n";}
#		when(/\>\=/)  {print "constrains about $tmp_var01 >= $tmp_var02 : \n";}
		when(/\=\=/)  {print "constrains about $tmp_var01 == $tmp_var02 : \n";}
		when(/,/)  {print "constrains about { $tmp_var01 , $tmp_var02 }: \n";}
		default {print "No match! But I got $items[$unit] as operator\n";}
	}
	print "This is the cycle $cnt_unit, with tmp_var name : $name_C \n*********************************************\n";
	
	splice(@items, $unit-1, 3, $tmp_long);  # yeah, substitude of original 'A' '+' 'B' for 'C'
	
	print "\nNow string: @items\n\n";
	
	if (!$cnt_unit) {last;}
	
	$i = 0; $flag_unit = 0;  # start new searching
	while ($items[$i])
	{
		if ($items[$i] =~ /\+|\-|\*|\<|\=\=|,/)  {
			if (($items[$i] =~ /\-/) && ($items[$i] =~ /\(/) && ($items[$i] =~ /\)/) )  {
				print "I found a minus!\n";
				$flag_minus = 1; 
				$minus = $i;
				last;
			}
			if (!$i) {$i++; next;}
			if ($items[$i-1] =~ /\}|\)/)  {$i++; next;}
			if ($items[$i+1] =~ /\{|\(/)  {$i++; next;}
			if ($items[$i] =~ /\-/) {$i++; next;}
			if (!$flag_unit) {$unit = $i;}
			$flag_unit = 1;
		}
		$i ++;
	}
}