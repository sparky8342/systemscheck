#!/usr/bin/perl
use strict;
use warnings;

my $fh;
open $fh, "<", "../inputs/6.txt";
my @data = <$fh>;
close $fh;
chomp($_) foreach @data;

my @asteroids;
for my $line (@data) {
	my ($x, $y, $vx, $vy) = split/[ ,]/, $line;
	push @asteroids, { x => $x, y => $y, vx => $vx, vy => $vy };
}

my $collisions = 0;
for my $y (1..10000) {
	for my $asteroid (@asteroids) {
		$asteroid->{x} += $asteroid->{vx};
		$asteroid->{y} += $asteroid->{vy};
		if ($asteroid->{x} == 0 && $asteroid->{y} == $y) {
			$collisions++;
		}
	}
}
print "$collisions\n";
