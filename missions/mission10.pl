#!/usr/bin/perl
use strict;
use warnings;

use List::Util qw(max);

#  0  1  2  3  4
#  5  6  7  8  9
# 10 11 12 13 14
# 15 16 17 18 19
# 20 21 22 23 24

use constant END_OPERATION => 1;
use constant TOOL_RETURN => 2;
use constant PART_RETURN => 3;

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
		push @jobs, {
			id => $id - 1,
			operations => \@operations,
			current_op => 0,
			current_op_in_progress => 0,
			part_location => 0,
			done => 0,
		};
	}
	return \@jobs;
}

my ($fh, $data);
open $fh, "<", "../inputs/10.txt";
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


sub activate_job {
	my ($job, $events, $machines_busy, $tools_busy, $current_time, $job_id) = @_;
	if ($job->{done}) {
		return;
	}

	if (!$job->{current_op_in_progress}) {
		my $machine = $job->{operations}->[$job->{current_op}]->{machine};
		my $tool = $job->{operations}->[$job->{current_op}]->{tool};
		if (!$machines_busy->[$machine] && !$tools_busy->[$tool]) {
			$job->{current_op_in_progress} = 1;
			$machines_busy->[$machine] = 1;
			$tools_busy->[$tool] = 1;

			my $part_time = travel_time($job->{part_location}, $machine);
			my $tool_time = travel_time(0, $machine);
			my $travel_time = max($part_time, $tool_time);
			my $operation_time = $job->{operations}->[$job->{current_op}]->{time} + $travel_time;
	
			push @$events, {
				type => END_OPERATION,
				time => $current_time + $operation_time,
				job => $job_id,
				machine => $machine,
			};
			push @$events, {
				type => TOOL_RETURN,
				time => $current_time + $operation_time + travel_time($machine, 0),
				tool => $tool,
			};

			$job->{part_location} = $machine;
		} elsif ($job->{part_location} != 0) {
			$job->{current_op_in_progress} = 1;
			push @$events, {
				type => PART_RETURN,
				time => $current_time + travel_time($job->{part_location}, 0),
				job_part_reset => $job_id,
			};
		}
	}
}


my @machines_busy;
my @tools_busy;

my @events;
my $current_time = 0;

my $done_count = 0;

while($done_count < @$jobs) {
	for (my $job_id = 0; $job_id < @$jobs; $job_id++) {
		my $job = $jobs->[$job_id];
		activate_job($job, \@events, \@machines_busy, \@tools_busy, $current_time, $job_id);
	}

	@events = sort { $a->{time} <=> $b->{time} } @events;	

	$current_time = $events[0]->{time};

	while ($events[0]->{time} == $current_time) {
		my $event = shift @events;
		if ($event->{type} == END_OPERATION) {
			my $job = $jobs->[$event->{job}];
			$job->{current_op_in_progress} = 0;
			$job->{current_op}++;
			if ($job->{current_op} == @{$job->{operations}}) {
				$job->{done} = 1;
				$done_count++;
			}
			$machines_busy[$event->{machine}] = 0;
		} elsif ($event->{type} == PART_RETURN) {
			my $job = $jobs->[$event->{job_part_reset}];
			$job->{current_op_in_progress} = 0;
			$job->{part_location} = 0;
		} elsif ($event->{type} == TOOL_RETURN) {
			$tools_busy[$event->{tool}] = 0;
		}
	}
}	

if (@events) {
	@events = sort { $b->{time} <=> $a->{time} } @events;	
	$current_time = $events[0]->{time};
}

printf("%d\n", $current_time);
