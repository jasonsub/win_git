#!/usr/bin/perl -w

use 5.014;
use strict;
use warnings;

open MAT, ">", "matrix.txt";
#open VEC, ">", "marking.txt";

my $i;
my $j;
my (@Mat, @tmp);
@tmp = qw / 0 0 0 0 0 /;

print $#tmp;

for($j = 0; $j < 5; $j++){
	push @Mat, [@tmp];
}

$Mat[2][3] = 1;
for ($i = 0; $i <5;$i++){
	for($j=0;$j<5;$j++){
		print MAT "$Mat[$i][$j] ";
	}
	print MAT "\n";
}