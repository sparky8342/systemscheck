#!/usr/bin/perl
use strict;
use warnings;

my $fh;
open $fh, "<", "../inputs/8.txt";
#open $fh, "<", "example.txt";
my @data = <$fh>;
close $fh;
chomp($_) foreach @data;

my %nodes;
foreach my $line (@data) {
	if ($line eq '') {
		last;
	}
	$line =~ /^(\w{3})-\[(\d+)\]\>(\w{3})$/;
	my ($from, $distance, $to) = ($1, $2, $3);
	$nodes{$from} = { distance => $distance, to => $to, chute => 1 };
}	

foreach my $name (keys %nodes) {
	$nodes{$nodes{$name}{to}}{chute} = 0;
}	

my @times;
foreach my $name (keys %nodes) {
	if ($nodes{$name}{chute}) {
		my $time = 0;
		while ($name ne 'inc') {
			$time += $nodes{$name}{distance};
			$name = $nodes{$name}{to};
		}
		push @times, $time;
	}
}

@times = sort { $a <=> $b } @times;
printf("%d\n", $times[0]);
