#!/usr/bin/perl
use strict;
use warnings;

use Data::Dumper;

my @dirs = ([0, 1], [0, -1], [1, 0], [-1, 0]);

sub bfs {
	my ($grid) = @_;

	my $height = @$grid;
	my $width = length($grid->[0]);

	my @queue = ([0, 0, 0]);
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

my $fh;
open $fh, "<", "../inputs/2.txt";
my @grid = <$fh>;
close $fh;
chomp($_) foreach @grid;

print bfs(\@grid) . "\n";
