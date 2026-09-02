#!/usr/bin/perl
use strict;
use warnings;
use List::Util qw(max);

my $fh;
open $fh, "<", "../inputs/1.txt";
my @data = <$fh>;
close $fh;
chomp($_) foreach @data;

my %times;
my $disabled_count = 0;
my $disabled_time;
my $max_time = 0;
my $max_disabled_count = 0;
my $max_disabled_time = 0;
for my $line (@data) {
	my ($time, $id, $state) = split/ /, $line;
	$time = substr($time, 2);
	$id = substr($id, 1);

	if ($state eq 'disabled') {
		$times{$id} = $time;
		$disabled_count++;
		$disabled_time = $time;
	} elsif ($state eq 'enabled') {
		$max_time = max($max_time, $time - $times{$id});

		if ($disabled_count > $max_disabled_count) {
              		$max_disabled_count = $disabled_count;
              		$max_disabled_time = $time - $disabled_time;
		} elsif ($disabled_count == $max_disabled_count) {
              		my $time_diff = $time - $disabled_time;
              		if ($time_diff > $max_disabled_time) {
                		$max_disabled_time = $time_diff;
			}
		}
          	
		$disabled_count--;
	}
}

printf("%d\n%d\n", $max_time, $max_disabled_time);
