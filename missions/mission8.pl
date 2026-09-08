#!/usr/bin/perl
use strict;
use warnings;

use List::Util qw(min);
use Heap::PQ 'import';

my ($fh, $data);
open $fh, "<", "../inputs/8.txt";
{
	local $/;
	$data = <$fh>;
}
close $fh;

my @parts = split/\n\n/, $data;
my %nodes;
my %chutes;
foreach my $line (split/\n/, $parts[0]) {
	$line =~ /^(\w{3})-\[(\d+)\]\>(\w{3})$/;
	my ($from, $distance, $to) = ($1, $2, $3);
	$nodes{$from} = { distance => $distance, to => $to };
	$chutes{$from} = undef;
}
foreach my $line (split/\n/, $parts[1]) {
	$line =~ /^(\w{3})\s(\d+)$/;
	my ($name, $rubbish) = ($1, $2);
	next if $name eq 'inc';
	$nodes{$name}{rubbish} = $rubbish;
}

foreach my $name (keys %nodes) {
	delete($chutes{$nodes{$name}{to}});
}	

my $best_time = 999999;
foreach my $name (keys %chutes) {
	my $time = 0;
	while ($name ne 'inc') {
		$time += $nodes{$name}{distance};
		$name = $nodes{$name}{to};
	}
	$best_time = min($best_time, $time);
}

printf("%d\n", $best_time);

my $heap = Heap::PQ->new('min', sub {
	$a->{time} <=> $b->{time} || $a->{location} cmp $b->{location}
});
foreach my $name (keys %chutes) {
	heap_push($heap, { location => $name , time => 0, total_time => 0 });
}

while (1) {
	my $droid = heap_pop($heap);

	if ($droid->{location} eq 'inc') {
		printf("%d\n", $droid->{total_time});
		last;
	}

	if ($nodes{$droid->{location}}->{rubbish} > 0) {
		my ($time, $location) = ($droid->{time}, $droid->{location});
		my $added_time = $nodes{$droid->{location}}->{rubbish};

		$droid->{time} += $added_time;
		$droid->{total_time} += $added_time;
		heap_push($heap, $droid);

		while (1) {
			my $next_droid = heap_peek($heap);
			if ($next_droid->{time} == $time && $next_droid->{location} eq $location) {
				my $droid = heap_pop($heap);
				$droid->{time} += $added_time;
				$droid->{total_time} += $added_time;
				heap_push($heap, $droid);
			} else {
				last;
			}
		}

		$nodes{$droid->{location}}->{rubbish} = 0;
	} else {
		my $distance = $nodes{$droid->{location}}{distance};
		$droid->{time} += $distance;
		$droid->{total_time} += $distance;
		$droid->{location} = $nodes{$droid->{location}}{to};
		heap_push($heap, $droid);
	}
}
