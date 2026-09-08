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

#use Data::Dumper;
#print Dumper \%nodes;
#exit(0);

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

my @droids;
foreach my $name (keys %nodes) {
	if ($nodes{$name}{chute}) {
		push @droids, { location => $name , time => 0, total_time => 0 };
	}
}

while (1) {
	@droids = sort {
		$a->{time} <=> $b->{time}
		|| $a->{location} cmp $b->{location}
	} @droids;

	my $droid = $droids[0];

	if ($droid->{location} eq 'inc') {
		printf("%d\n", $droid->{total_time});
		last;
	}

	if ($nodes{$droid->{location}}->{rubbish} > 0) {
		my $time = $droid->{time};
		my $location = $droid->{location};
		my $amount = 1;
		my $id = 1;
		while ($droids[$id]->{time} == $time
			&& $droids[$id]->{location} eq $location) {
			$id++;
		}
		for (my $i = 0; $i < $id; $i++) {
			my $droid = shift @droids;
			$droid->{time} += $nodes{$location}->{rubbish};
			$droid->{total_time} += $nodes{$location}->{rubbish};
		}
		$nodes{$location}->{rubbish} = 0;
		next;
	}

	$droid = shift @droids;
	$droid->{time} = $nodes{$droid->{location}}{distance} + $droid->{time};
	$droid->{total_time} += $nodes{$droid->{location}}{distance};
	$droid->{location} = $nodes{$droid->{location}}{to};
	push @droids, $droid;
}
