#!/usr/bin/perl
use strict;
use warnings;
use List::Util qw(min max);

sub hash_key {
	my ($pos) = @_;
	return sprintf("%d_%d_%d", $pos->{x}, $pos->{y}, $pos->{z});
}

sub unpack_key {
	my ($k) = @_;
	my ($x, $y, $z) = split/_/, $k;
	return { x => $x, y => $y, z => $z };
}

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
	my $pos = { x => $x, y => $y, z => $z };
	$grid{hash_key($pos)} = undef;
}

my $start = { x => 0, y => 0, z => 0 };
my @queue = ($start);
my %visited = ( hash_key($start) => undef );

my %spaces;

while (@queue) {
	my $pos = shift @queue;
	$spaces{hash_key($pos)} = undef;

	foreach my $neighbour (@{neighbours($pos)}) {
		my $hk = hash_key($neighbour);
		if (exists($grid{$hk}) || exists($visited{$hk})) {
			next;
		}
		push @queue, $neighbour;
		$visited{$hk} = undef;
	}
}	

printf("%d\n", scalar %spaces);


# TODO use something better for parts 2 and 3
my $most_steps = 0;
my $least_steps = 999999;

foreach my $space_key (keys %spaces) {
	my $space = unpack_key($space_key);

	$space->{steps} = 0;
	my @queue = ($space);
	my %visited = ( $space_key => undef );

	my $end;
	while (@queue) {
		my $pos = shift @queue;
		$most_steps = max($most_steps, $pos->{steps});
		$end = $pos;

		foreach my $neighbour (@{neighbours($pos)}) {
			my $hk = hash_key($neighbour);
			if (!exists($spaces{$hk}) || exists($visited{$hk})) {
				next;
			}
			$neighbour->{steps} = $pos->{steps} + 1;
			push @queue, $neighbour;
			$visited{$hk} = undef;
		}
	}

	$least_steps = min($least_steps, $end->{steps});
}

printf("%d\n%d\n", $most_steps, $least_steps);
