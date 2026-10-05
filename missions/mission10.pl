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

sub parse_data {
	my ($data) = @_;
	my @job_data = split/\n\n/, $data;
	my @jobs;
	foreach my $data (@job_data) {
		my @operation_data = split/\n/, $data;
		my $id = substr($operation_data[0], 1);
		shift @operation_data;
		my @operations;
		foreach my $line (@operation_data) {
			my (undef, $machine, $tool, $time) = split/\s/, $line;
			$machine = substr($machine, 1);
			$tool = substr($tool, 1);
			$time = substr($time, 1);
			push @operations, { machine => $machine, tool => $tool, time => $time };
		}
		push @jobs, { id => $id, operations => \@operations };
	}
	return \@jobs;
}

my ($fh, $data);
open $fh, "<", "../inputs/10.txt";
#open $fh, "<", "example.txt";
{
	local $/;
	$data = <$fh>;
}
close $fh;

my $jobs = parse_data($data);

my $total_time = 0;
foreach my $job (@$jobs) {
	my $location = 0;
	foreach my $operation (@{$job->{operations}}) {
		my $part_time = travel_time($location, $operation->{machine});
		my $tool_time = travel_time(0, $operation->{machine});
		my $travel_time = max($part_time, $tool_time);
		$total_time += $travel_time;
		$location = $operation->{machine};
		$total_time += $operation->{time};
	}

	$total_time += travel_time($location, 0);
}

printf("%d\n", $total_time);
