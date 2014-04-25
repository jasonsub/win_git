#!/usr/bin/perl -w

use 5.014;
use strict;
use warnings;

my @lines;
foreach(0..32)
{$lines[$_] = 0;}

#print @lines;
my @items;
foreach(0..32){
	push @items, [@lines];
}

my $i=0;
my $j=0;

for($i = 0; $i<33; $i++){
	for($j = 0; $j<33; $j++){
		if(&onb($i,$j)) {$items[$i][$j] = 1;}
	}
}

for($i = 0; $i<33; $i++){
	for($j = 0; $j<33; $j++){
		print "$items[$i][$j] ";
	}
	print "\n";
}

sub onb{
	my $a = $_[0];
	my $b = $_[1];
	my $sum;
	my $diff;
	$sum = 2**$a + 2**$b;
	$diff = 2**$a - 2**$b;
	while($diff < 0){
		$diff = $diff + 67;
	}
	$sum = $sum%67;
	$diff = $diff%67;
	if (($sum == 1) || ($sum == 66) || ($diff == 1) || ($diff == 66))
	{ return 1;}
	else {return 0;}
}