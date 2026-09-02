#!/usr/bin/perl
use strict;
use warnings;

my $fh;
open $fh, "<", "../inputs/7.txt";
my @data = <$fh>;
close $fh;
chomp($_) foreach @data;

my $sum = 0;
my %loads;
foreach my $line (@data) {
	my ($id, $in, $out) = split/ /, $line;
	my $efficiency = int(100 * $out / $in);
	if ($efficiency < 97) {
		$sum += $efficiency;
		($id) = $id =~ /^\d+\|(.*)$/;
		while ($id =~ /(\w{3})/g) {
			$loads{$1} += $efficiency;
		}
	}

}

printf("%d\n%d\n", $sum, (sort { $b <=> $a } values %loads)[0]);
