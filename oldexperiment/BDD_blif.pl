#!/usr/bin/perl -w

use 5.014;
use strict;
use warnings;

open BL, ">", "65bit_BDD.blif";

my $size = 65;

my $d = 1;
my $c = 1;
my $b = 1;
my $i = 0;
# my @idx = qw /1 0 6 6 15 12 23 21 31 14 32 1 2 15 23 19 26 28 30 13 17 22 25 3 16 10 31 5 22 2 7 12 26 10 29 20 25 8 24 18 30 4 24 11 14 3 7 19 21 11 18 8 16 28 29 9 27 17 27 9 20 4 13 5 32/;

my @idx = qw /1 0 7 7 46 14 31 43 53 29 63 45 64 1 2 31 46 18 56 23 27 40 62 16 44 30 55 3 47 35 43 12 41 52 55 9 32 21 27 26 50 19 33 26 37 10 57 40 60 36 49 20 22 10 19 50 62 5 54 13 45 3 8 18 53 21 51 37 42 15 48 25 41 22 34 48 57 59 61 11 24 16 36 34 52 4 15 12 63 6 30 2 8 14 56 35 38 25 61 20 28 33 54 17 42 4 32 29 51 13 17 9 4 7 23 38 59 60 39 58 24 58 39 49 11 28 5 44 6 64/;
my $j = 1;

print BL ".model outputBDD\n.inputs ";
for($i=0;$i<$size;$i++){
print BL "a$i b$i ";
}
print BL "\n.outputs R\n.names b0 a1 d0\n11 1\n";

while ($j < $size) {
	printf BL (".names a%d a%d c%d\n01 1\n10 1\n", $idx[2*$j-1], $idx[2*$j], $c); $c++;
	printf BL (".names b%d c%d d%d\n11 1\n", $b, $c-1, $d); $b++; $d++;
	$j ++;
}

print BL ".names d0 d1 tmp0\n01 1\n10 1\n";
for($i = 2; $i < $size; $i++){
	printf BL (".names tmp%d d%d tmp%d\n01 1\n10 1\n", $i-2, $i, $i-1);
}

printf BL (".names tmp%d d%d R\n01 1\n10 1\n", $size-2, $size-1);
print BL ".end\n";
