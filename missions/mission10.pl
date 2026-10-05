#!/usr/bin/perl
use strict;
use warnings;

use List::Util qw(max);

#  0  1  2  3  4
#  5  6  7  8  9
# 10 11 12 13 14
# 15 16 17 18 19
# 20 21 22 23 24

sub machine_x_y {
	my ($machine) = @_;
	return ($machine % 5, int($machine / 5));
}	

sub travel_time {
	my ($loc1, $loc2) = @_;
	my ($x1, $y1) = machine_x_y($loc1);
	my ($x2, $y2) = machine_x_y($loc2);
	return abs($x1 - $x2) + abs($y1 - $y2);
}

my ($fh, $data);
open $fh, "<", "../inputs/10.txt";
#open $fh, "<", "example.txt";
{
	local $/;
	$data = <$fh>;
}
close $fh;

my @jobs = split/\n\n/, $data;

my $total_time = 0;
foreach my $job (@jobs) {
	my @operations = split/\n/, $job;
	shift @operations;

	my $location = 0;
	foreach my $operation (@operations) {
		my (undef, $machine, undef, $time) = split/\s/, $operation;
		$machine = substr($machine, 1);
		$time = substr($time, 1);
		my $part_time = travel_time($location, $machine);
		my $tool_time = travel_time(0, $machine);
		my $travel_time = max($part_time, $tool_time);
		$total_time += $travel_time;
		$location = $machine;
		$total_time += $time;
	}

	$total_time += travel_time($location, 0);
}

printf("%d\n", $total_time);
