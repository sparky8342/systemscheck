#!/usr/bin/perl
use strict;
use warnings;
use List::Util qw(min max);

sub neighbours {
	my ($pos) = @_;
	return [
		{ x => $pos->{x} + 1, y => $pos->{y} - 1, z => $pos->{z} + 0},
		{ x => $pos->{x} - 1, y => $pos->{y} + 1, z => $pos->{z} + 0},
		{ x => $pos->{x} + 1, y => $pos->{y} + 0, z => $pos->{z} - 1},
		{ x => $pos->{x} + 0, y => $pos->{y} + 1, z => $pos->{z} - 1},
		{ x => $pos->{x} + 0, y => $pos->{y} - 1, z => $pos->{z} + 1},
		{ x => $pos->{x} - 1, y => $pos->{y} + 0, z => $pos->{z} + 1},
	];
}

my $fh;
open $fh, "<", "../inputs/12.txt";
chomp (my $data = <$fh>);
close $fh;

my %grid;
foreach my $coords (split/:/, $data) {
	my ($x, $y, $z) = split/,/, $coords;
	$grid{$x, $y, $z} = undef;
}

my $start = { x => 0, y => 0, z => 0 };
my @queue = ($start);
my %visited;
$visited{0, 0, 0} = undef;

my $space = 0;

while (@queue) {
	my $pos = shift @queue;
	$space++;

	foreach my $neighbour (@{neighbours($pos)}) {
		if (exists($grid{$neighbour->{x}, $neighbour->{y}, $neighbour->{z}})) {
			next;
		}
		if (exists($visited{$neighbour->{x}, $neighbour->{y}, $neighbour->{z}})) {
			next;
		}
		push @queue, $neighbour;
		$visited{$neighbour->{x}, $neighbour->{y}, $neighbour->{z}} = undef;
	}
}	

printf("%d\n", $space);
