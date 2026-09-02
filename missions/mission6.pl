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

my %collisions;
for my $y (1..10000) {
	for my $asteroid (@asteroids) {
		$asteroid->{x} += $asteroid->{vx};
		$asteroid->{y} += $asteroid->{vy};
		for my $x (-10..10) {
			if ($asteroid->{x} == $x && $asteroid->{y} == $y) {
				$collisions{$x}++;
			}
		}
	}
}

printf("%d\n%d\n", $collisions{0}, (sort { $a <=> $b } values %collisions)[0]);
