#!/usr/bin/perl
use strict;
use warnings;

my $fh;
open $fh, "<", "../inputs/11.txt";
my $data = <$fh>;
close $fh;
chomp($data);

my @bytes = split/ /, $data;

my @output;

for (my $i = 0; $i < @bytes; $i++) {
	if ($bytes[$i] eq 'FF') {
		my $countback = hex($bytes[$i+1]);
		my $copy = hex($bytes[$i+2]);
		my $start = @output - $countback;
		my $end = $start + $copy - 1;
		push @output, @output[$start..$end];
		$i += 2;
	} else {
		push @output, $bytes[$i];
	}
}

printf("%d\n", scalar @output);
