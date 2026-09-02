#!/usr/bin/perl
use strict;
use warnings;

my $fh;
open $fh, "<", "../inputs/7.txt";
my @data = <$fh>;
close $fh;
chomp($_) foreach @data;

my $sum = 0;
foreach my $line (@data) {
	my (undef, $in, $out) = split/ /, $line;
	my $efficiency = int(100 * $out / $in);
	if ($efficiency < 97) {
		$sum += $efficiency;
	}
}

printf("%d\n", $sum);
