#!/usr/bin/perl -w

use 5.014;
use strict;
use warnings;

open BL, ">", "spec_5bit.blif"; # change filename

my $size = 5; # change this size

my $d = 1;
my $c = 1;
my $b = 1;
my $i = 0;
# my @idx = qw /1 0 6 6 15 12 23 21 31 14 32 1 2 15 23 19 26 28 30 13 17 22 25 3 16 10 31 5 22 2 7 12 26 10 29 20 25 8 24 18 30 4 24 11 14 3 7 19 21 11 18 8 16 28 29 9 27 17 27 9 20 4 13 5 32/;

my @idx = qw /1 0 0 3 3 4 1 2 2 4/;
my $j = 1;

print BL ".model specckt\n.inputs ";
for($i=0;$i<$size;$i++){
print BL "a$i b$i ";
}
my $k;
for($k = 0; $k < $size; $k++){
printf BL "\n.outputs R\n.names b%d a%d d0\_r%d\n11 1\n", $k, $k+1, $k;
$j = 1; $b = 1; $c = 1; $d = 1;
while ($j < $size) {
	printf BL (".names a%d a%d c%d\_r%d\n01 1\n10 1\n", $idx[2*$j-1], $idx[2*$j], $c, $k); $c++;
	printf BL (".names b%d c%d d%d\_r%d\n11 1\n", $b, $c-1, $d, $k); $b++; $d++;
	$j ++;
}
$i = 0;
printf BL ".names d0\_r%d d1\_r%d tmp0\_r%d\n01 1\n10 1\n", $k, $k, $k;
for($i = 2; $i < $size; $i++){
	printf BL (".names tmp%d\_r%d d%d\_r%d tmp%d\_r%d\n01 1\n10 1\n", $i-2,$k, $i,$k, $i-1,$k);
}

printf BL (".names tmp%d\_r%d d%d\_r%d R%d\n01 1\n10 1\n", $size-2,$k, $size-1,$k,$k);
}
print BL ".end\n";
