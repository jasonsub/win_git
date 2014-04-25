#!/usr/bin/perl -w

use 5.014;
use strict;
use warnings;

my $sample = "({{{{1'b0,var_19},1'b0},1'b0},1'b0} + {{{{1'b0,1'b0},1'b0},1'b0},var_19});";
my @items = split /\s+/, $sample;

#my @comma = split /,/, $items[$_];
my @comma = split /,/, $items[0];

my $new_comma = join " , ", @comma;
@comma = split /\s+/, $new_comma;
#my @tmp;

splice(@items, 0, 1, @comma);
print "@items\n";

=cut
#testbench
my $i = -1;
while ($comma[$i+1])  {
	$i ++;
}
my $leng = $i;
#test end

#for ($i = $leng; $i >= $_; $i--)  {
for ($i = $leng; $i >= 0; $i--)  {
	unshift @tmp, pop(@items);
}
$i = -1;
while($comma[$i+1])  {
	$i ++;
}
push @items, @comma;
#$j += $i;
$leng += $i;
push @items, @tmp;
=cut
my $i = 0;
while ($items[$i])  {
	print "$items[$i]\n";
	$i++;
}
$sample = join " ", @items;

print "$sample\n";