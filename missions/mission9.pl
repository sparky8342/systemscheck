#!/usr/bin/perl
use strict;
use warnings;

my @grid;
my $fh;
open $fh, "<", "../inputs/9.txt";
while (my $line = <$fh>) {
	chomp($line);
	push @grid, [split/ /, $line];
}
close $fh;

my $height = @grid;
my $width = @{$grid[0]};

my ($start, $end);
for (my $y = 0; $y < $height; $y++) {
	for (my $x = 0; $x < $width; $x++) {
		if ($grid[$y][$x] eq '^') {
			$start = { x => $x, y => $y };
		} elsif ($grid[$y][$x] eq '*') {
			$end = { x => $x, y => $y };
		}
	}
}

my @queue = ({ x => $start->{x}, y => $start->{y}, distance => 0 });
my %visited;
$visited{$start->{x}, $start->{y}} = undef;
while (@queue) {
	my $pos = shift @queue;

	if ($pos->{x} == $end->{x} && $pos->{y} == $end->{y}) {
		printf("%d\n", $pos->{distance});
		last;
	}

	my $level = $grid[$pos->{y}][$pos->{x}];
	if ($level eq '*' || $level eq '^') {
		$level = 0;
	}
	for (my $dy = -1; $dy <= 1; $dy++) {
		for (my $dx = -1; $dx <= 1; $dx++) {
			if ($dx == 0 && $dy == 0) {
				next;
			}
			my ($nx, $ny) = ($pos->{x} + $dx, $pos->{y} + $dy);
			my $grid_level = $grid[$ny][$nx];
			if ($grid_level eq '*' || $grid_level eq '^') {
				$grid_level = 0;
			}
			if (abs($level - $grid_level) > 1) {
				next;
			}
			if (exists($visited{$nx, $ny})) {
				next;
			}

			push @queue, { x => $nx, y => $ny, distance => $pos->{distance} + 1 };
			$visited{$nx, $ny} = undef;
		}
	}
}
