#!/usr/bin/perl -w

use 5.014;
use strict;
use warnings;

open MAT, ">", "matrix.txt";
open VEC, ">", "marking.txt";

my $flag_graph = 0;
my @tran;
my @place;
my @record;
my $init;
my $i;
my $j;

while(<>){
	chomp;
	my $read_in = $_;
	my @items = split /\s+/;
	$i = 1;
	my $flag_name = 0;
	my $flag_place = 0;
	if($items[0] =~ /inputs|outputs/){
		while($items[$i]){
			push @tran, $items[$i];
			$i ++;
		}
		next;
	}
	if($items[0] =~ /graph/){
		$flag_graph = 1;
		next;
	}
	if($items[0] =~ /marking/){
		$init = substr($items[1],1,length($items[1])-2);
		$flag_graph = 0;
		next;
	}
	if($items[0] =~ /.end/){
		last;
	}
	if($flag_graph && !($items[0] =~ /marking/)){
#		print "Reading $items[0].....\n";
		push @record, $read_in;
		if(!&member($items[0])) {
			push @place, $items[0];
		}
	}
}

print @tran;
print "\n";
print @place;
print "\n";

my $k = 0;
while($place[$k]){
	if($place[$k] eq $init){
		print VEC "1 ";
	}
	else{
		print VEC "0 ";
	}
	$k++;
}
my %key;
for($i=0;$i<=$#place;$i++){
	$key{$place[$i]} = $i;
}
for($j=0;$j<=$#tran;$j++){
	$key{$tran[$j]} = $j;
}
#print $init;
#print "$key{$init}\n";
my @Mat;
for($j = 0; $j <= $#place; $j++){
	push @Mat, [@tran];
}
for ($i = 0; $i <= $#place;$i++){
	for($j=0;$j<= $#tran;$j++){
		$Mat[$i][$j]=0;
	}
}
$k = 0;

while($record[$k]){
	$_ = $record[$k];
	my @items = split /\s+/;
	if(!&member($items[0])){
		$i = 1;
		while($items[$i]){
			my $x = $key{$items[0]};
			my $y = $key{$items[$i]};
			print "I'm in row $items[0], x is $x, y is $y. \n";
			$Mat[$x][$y] = $Mat[$x][$y] + 1;
			$i++;
		}
	}
	else{
		$i = 1;
		while($items[$i]){
			my $y = $key{$items[0]};
			my $x = $key{$items[$i]};
			$Mat[$x][$y] = $Mat[$x][$y] - 1;
			$i++;
		}
	}
	$k++;
}
for ($i = 0; $i <= $#place;$i++){
	for($j=0;$j<=$#tran;$j++){
		print MAT "$Mat[$i][$j] ";
	}
	print MAT "\n";
}

sub member {
	my $num = $_[0];
	my $p;
	my $flag = 0;
	for ($p = 0; $p <= $#tran; $p ++){
		if($tran[$p] eq $num) 
		{$flag=1;}
	}
	print "flag = $flag, $num\n";
	return $flag;
}