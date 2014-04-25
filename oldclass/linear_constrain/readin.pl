#!/usr/bin/perl -w

use 5.014;
use strict;
use warnings;

open BEDROCK, ">", "transf.dat";

#qw "input output wire assign";

my @var;
my $cnt_tmp = 0;
my $cnt_lines = 0;

while (<>) {
	chomp;
	$cnt_lines ++;
	my $read_in = $_;
	my @items = split /\s+/;
	my $i = 1;
	my $flag_io = 0;
	my $flag_eq = 0;
	my $cnt_eq = 0;
	my $def_var;
	next unless $items[1];
	#next if /assign/;  #no, we need assigned variables
	#print "$items[1] $items[2] \n";
	while ( $items[$i] ) {
		$_ = $items[$i];
		if (/input|output/) {$flag_io = 1;}
		if (/=/ && !$flag_eq)
		{
			$flag_eq = 1;
			$cnt_eq = $i;
		}
		$i ++;
	}
	$_ = "";  #I forgot what I wanna do here
	my $leng = $i-1;
	if ($flag_io) {$_ = $items[$leng]; s/;/\n/; print BEDROCK $_; } # -1 more is [] info, if no [] then max 1
	if ($flag_eq) {$_ = $items[$cnt_eq-1]; print BEDROCK "$_\n"; }
	chomp;
	if ($_) {push @var, $_; $def_var = $_;}
	$_ = $read_in;
	if (/assign/) {pop @var;}  # as u know @var only works if u wanna print signal names out, so u can ignore these if error occurs
	#before shift, need upper limit constrain based on bits definition
	if ($flag_eq) {
		if ($items[1] =~ /[.]/) {#print upper limit var<2}
		foreach (0..$cnt_eq) {
			shift @items; 
			if(/[.]/)  {
				#pick number between [ and : , page136
				#print upper limit (maximum) with $def_var
				# store bits count n in hash
			}
		}
		print "@items\n";
		#find "+"
		#judge whether left side is not ) right side is not (, if yes, get primitive var first
		my $unit = 99; #it seems that we can simply put it @ 0... I really freaked out
		my $j = 0;
		while ($j <= $leng) {
			if ($items[$j] =~ /,+/) {# &comma($items[$_]);}
			$j ++;
		}
		
		my $flag_unit = 0;
		my $cnt_unit = 0;
		#find position $unit, bool $flag_unit, record count $cnt_unit;
		while ($flag_unit)  {
			#judge if either operand contains "-", or "[:]", if so calc this first
			#do calc for unit oeprator, consider one side is const
			#judge if not the last operator, generate tmp_"$cnt_tmp"; if last, use $def_var
			#remove immediate () or {}
			# splice(@items, $unit-1, 3, @new_op);  # 3 means it's a 2-operand calc
			
			#again, find next $unit
		}
	#anything left?	Sure, store bit info for every var (esp. tmp_var!!!)
	}
}
print "@var\n";
#print "\n\n@var[0]";


<<TXT;
limitations: 
1, need blank isolating every operator
2, no excess braces/brackets()
3, write only one definition in only one line
4, no blank lines (perhaps), and NO COMMENTS!
TXT