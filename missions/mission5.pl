#!/usr/bin/perl
use strict;
use warnings;
use List::Util qw(min max);

my $fh;
open $fh, "<", "../inputs/5.txt";
my @data = <$fh>;
close $fh;
chomp($_) foreach @data;

my %plate = ();
my %limits = ( min_x => 99999, max_x => -1, min_y => 99999, max_y => -1 );
foreach my $line (@data) {
	my @coords = split/ /, $line;
	@coords = map { my ($x, $y) = split/,/, $_; {'x' => $x, 'y' => $y} } @coords;
	$limits{min_x} = min($limits{min_x}, $coords[0]->{x});
	$limits{max_x} = max($limits{max_x}, $coords[1]->{x});
	$limits{min_y} = min($limits{min_y}, $coords[0]->{y});
	$limits{max_y} = max($limits{max_y}, $coords[2]->{y});
	for my $x ($coords[0]->{x}..$coords[1]->{x}) {
		$plate{$x, $coords[0]->{y}} = undef;
	}
	for my $y ($coords[1]->{y}..$coords[2]->{y}) {
		$plate{$coords[1]->{x}, $y} = undef;
	}
	for my $x ($coords[3]->{x}..$coords[2]->{x}) {
		$plate{$x, $coords[3]->{y}} = undef;
	}
	for my $y ($coords[0]->{y}..$coords[3]->{y}) {
		$plate{$coords[0]->{x}, $y} = undef;
	}
}
$limits{min_x}--;
$limits{max_x}++;
$limits{min_y}--;
$limits{max_y}++;

my @queue = ({ x => $limits{min_x}, y => $limits{min_y} });
my %visited;
$visited{$limits{min_x}, $limits{min_y}} = undef;
my %material;

while (@queue) {
	my $pos = shift @queue;

	for my $dx (-1..1) {
		for my $dy (-1..1) {
			if ($dx == 0 && $dy == 0) {
				next;
			}

			my $new_x = $pos->{x} + $dx;
			my $new_y = $pos->{y} + $dy;

			if ($new_x < $limits{min_x} || $new_x > $limits{max_x}
			|| $new_y < $limits{min_y} || $new_y > $limits{max_y}) {
				next;
			}

			if (exists($plate{$new_x, $new_y})) {
				$material{$new_x, $new_y} = undef;
				next;
			}

			if (exists($visited{$new_x, $new_y})) {
				next;
			}

			push @queue, { x => $new_x, y => $new_y };
			$visited{$new_x, $new_y} = undef;
		}
	}
}

printf("%d\n", scalar keys %material);
