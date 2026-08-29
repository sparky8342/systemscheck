#!/usr/bin/perl
use strict;
use warnings;

use Heap::PQ 'import';

my @dirs = ([0, 1], [0, -1], [1, 0], [-1, 0]);
my ($width, $height);

sub bfs {
	my ($grid) = @_;

	my @queue = ([0, 0, 0]); # x, y, distance
	my %visited;
	$visited{0,0} = undef;

	while (@queue) {
		my $pos = shift @queue;

		if ($pos->[0] == $width - 1 && $pos->[1] == $height - 1) {
			return $pos->[2];
		}

		for my $dir (@dirs) {
			my $new_x = $pos->[0] + $dir->[0];
			my $new_y = $pos->[1] + $dir->[1];
			if ($new_x < 0 || $new_x == $width || $new_y < 0 || $new_y == $height) {
				next;
			}
			if (substr($grid->[$new_y], $new_x, 1) eq '#') {
				next;
			}
			if (!exists($visited{$new_x, $new_y})) {
				push @queue, [$new_x, $new_y, $pos->[2] + 1];
				$visited{$new_x, $new_y} = undef;
			}
		}
	}
}

sub next_to_wall {
	my ($grid, $x, $y) = @_;

	for my $dx (-1..1) {
		for my $dy (-1..1) {
			if ($dx == 0 && $dy == 0) {
				next;
			}

			my $new_x = $x + $dx;
			my $new_y = $y + $dy;
			if ($new_x < 0 || $new_x == $width || $new_y < 0 || $new_y == $height) {
				next;
			}
			if (substr($grid->[$new_y], $new_x, 1) eq '#') {
				return 1;
			}
		}
	}
	return 0;
}

sub djikstra {
	my ($grid) = @_;

	my @distances;
	for my $y (0..$height) {
		push @distances, [(999999) x $width];
	}
	$distances[0][0] = 0;

	my $heap = Heap::PQ::new('min', sub {
		$a->[2] <=> $b->[2]
	});

	heap_push($heap, [0, 0, 0]);

	while (heap_size($heap)) {
		my $pos = heap_pop($heap);

		if ($pos->[0] == $width - 1 && $pos->[1] == $height - 1) {
			return $pos->[2];
		}

		for my $dir (@dirs) {
			my $new_x = $pos->[0] + $dir->[0];
			my $new_y = $pos->[1] + $dir->[1];
			if ($new_x < 0 || $new_x == $width || $new_y < 0 || $new_y == $height) {
				next;
			}
			if (substr($grid->[$new_y], $new_x, 1) eq '#') {
				next;
			}

			my $new_dist = $pos->[2] + 1;
			if (next_to_wall($grid, $new_x, $new_y)) {
				$new_dist++;
			}
			if ($distances[$new_x][$new_y] > $new_dist) {
				$distances[$new_x][$new_y] = $new_dist;
				heap_push($heap, [$new_x, $new_y, $new_dist]);
			}
		}
	}
}

my $fh;
open $fh, "<", "../inputs/2.txt";
my @grid = <$fh>;
close $fh;
chomp($_) foreach @grid;
$height = @grid;
$width = length($grid[0]);

print bfs(\@grid) . "\n";
print djikstra(\@grid) . "\n";
