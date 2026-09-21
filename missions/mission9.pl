#!/usr/bin/perl
use strict;
use warnings;

use Heap::PQ 'import';

my ($height, $width);

sub find_start_end {
	my ($grid) = @_;
	my ($start, $end);
	for (my $y = 0; $y < $height; $y++) {
		for (my $x = 0; $x < $width; $x++) {
			if ($grid->[$y][$x] eq '^') {
				$start = { x => $x, y => $y };
			} elsif ($grid->[$y][$x] eq '*') {
				$end = { x => $x, y => $y };
			}
		}
	}
	return ($start, $end);
}

sub bfs {
	my ($grid, $start, $end) = @_;

	my @queue = ({ x => $start->{x}, y => $start->{y}, distance => 0 });
	my %visited;
	$visited{$start->{x}, $start->{y}} = undef;
	while (@queue) {
		my $pos = shift @queue;

		if ($pos->{x} == $end->{x} && $pos->{y} == $end->{y}) {
			return $pos->{distance};
		}

		my $level = $grid->[$pos->{y}][$pos->{x}];
		if ($level eq '*' || $level eq '^') {
			$level = 0;
		}
		for (my $dy = -1; $dy <= 1; $dy++) {
			for (my $dx = -1; $dx <= 1; $dx++) {
				if ($dx == 0 && $dy == 0) {
					next;
				}
				my ($nx, $ny) = ($pos->{x} + $dx, $pos->{y} + $dy);
				my $grid_level = $grid->[$ny][$nx];
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
}

sub djikstra {
	my ($grid, $start, $end) = @_;

	my @distances;
	for my $y (0..$height) {
		push @distances, [(999999) x $width];
	}
	$distances[0][0] = 0;

	my $heap = Heap::PQ::new('min', sub {
		$a->{distance} <=> $b->{distance}
	});

	$start->{distance} = 0;
	heap_push($heap, $start);

	while (heap_size($heap)) {
		my $pos = heap_pop($heap);

		if ($pos->{x} == $end->{x} && $pos->{y} == $end->{y}) {
			return $pos->{distance};
		}

		my $level = $grid->[$pos->{y}][$pos->{x}];
		if ($level eq '*' || $level eq '^') {
			$level = 0;
		}

		for (my $dy = -1; $dy <= 1; $dy++) {
			for (my $dx = -1; $dx <= 1; $dx++) {
				if ($dx == 0 && $dy == 0) {
					next;
				}
	
				my $nx = $pos->{x} + $dx;
				my $ny = $pos->{y} + $dy;

				if ($nx < 0 || $nx == $width || $ny < 0 || $ny == $height) {
					next;
				}

				my $grid_level = $grid->[$ny][$nx];
				if ($grid_level eq '*' || $grid_level eq '^') {
					$grid_level = 0;
				}

				if (abs($level - $grid_level) > 1) {
					next;
				}
				
				my $new_dist = $pos->{distance} + 1;
				if ($grid_level > $level) {
					$new_dist += 4;
				}

				if ($distances[$nx][$ny] > $new_dist) {
					$distances[$nx][$ny] = $new_dist;
					heap_push($heap, { x => $nx, y => $ny, distance => $new_dist} );
				}
			}
		}
	}
}

my @grid;
my $fh;
open $fh, "<", "../inputs/9.txt";
while (my $line = <$fh>) {
	chomp($line);
	push @grid, [split/ /, $line];
}
close $fh;

($height, $width) = (scalar @grid, scalar @{$grid[0]});
my ($start, $end) = find_start_end(\@grid);

printf("%d\n", bfs(\@grid, $start, $end));
printf("%d\n", djikstra(\@grid, $end, $start));
