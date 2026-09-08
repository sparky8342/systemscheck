#!/usr/bin/perl
use strict;
use warnings;

use Heap::PQ 'import';

my $fh;
open $fh, "<", "../inputs/8.txt";
my @data = <$fh>;
close $fh;
chomp($_) foreach @data;

my %nodes;
my $i;
foreach ($i = 0; $i < @data; $i++) {
	my $line = $data[$i];
	if ($line eq '') {
		last;
	}
	$line =~ /^(\w{3})-\[(\d+)\]\>(\w{3})$/;
	my ($from, $distance, $to) = ($1, $2, $3);
	$nodes{$from} = { distance => $distance, to => $to, chute => 1 };
}
$i++;
foreach (; $i < @data; $i++) {
	my $line = $data[$i];
	$line =~ /^(\w{3})\s(\d+)$/;
	my ($name, $rubbish) = ($1, $2);
	next if $name eq 'inc';
	$nodes{$name}{rubbish} = $rubbish;
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

my $heap = Heap::PQ->new('min', sub {
	$a->{time} <=> $b->{time} || $a->{location} cmp $b->{location}
});
foreach my $name (keys %nodes) {
	if ($nodes{$name}{chute}) {
		heap_push($heap, { location => $name , time => 0, total_time => 0 });
	}
}

while (1) {
	my $droid = heap_pop($heap);

	if ($droid->{location} eq 'inc') {
		printf("%d\n", $droid->{total_time});
		last;
	}

	if ($nodes{$droid->{location}}->{rubbish} > 0) {
		my @droids = ($droid);
		while (1) {
			my $next_droid = heap_peek($heap);
			if ($next_droid->{time} == $droid->{time} && $next_droid->{location} eq $droid->{location}) {
				push @droids, heap_pop($heap);
			} else {
				last;
			}
		}
		foreach my $droid (@droids) {
			my $time = $nodes{$droid->{location}}->{rubbish};
			$droid->{time} += $time;
			$droid->{total_time} += $time;
			heap_push($heap, $droid);
		}
		$nodes{$droid->{location}}->{rubbish} = 0;
	} else {
		$droid->{time} = $nodes{$droid->{location}}{distance} + $droid->{time};
		$droid->{total_time} += $nodes{$droid->{location}}{distance};
		$droid->{location} = $nodes{$droid->{location}}{to};
		heap_push($heap, $droid);
	}
}
