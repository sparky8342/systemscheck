#!/usr/bin/perl
use strict;
use warnings;

use Data::Dumper;

sub manhattan_dist {
	my ($relay1, $relay2) = @_;
	return abs($relay1->{x} - $relay2->{x}) + abs($relay1->{y} - $relay2->{y});
}

sub dfs {
	my ($relays, $id, $visited, $cache) = @_;
	if (exists($cache->{$id, $visited})) {
		return $cache->{$id, $visited}
	}

	if ($id == @$relays - 1) {
		return 1;
	}

	my $paths = 0;
	foreach my $neighbour (@{$relays->[$id]->{neighbours}}) {
		if (($visited & (1 << $neighbour)) == 0) {
			$visited |= (1 << $neighbour);
			$paths += dfs($relays, $neighbour, $visited, $cache);
			$visited ^= (1 << $neighbour);
		}
	}
	$cache->{$id, $visited} = $paths;
	return $paths;
}

my $fh;
open $fh, "<", "../inputs/3.txt";
my @data = <$fh>;
close $fh;
chomp($_) foreach @data;

my @relays;

for (my $i = 0; $i < @data; $i++) {
	if ($data[$i] eq '') {
		last;
	}
	$data[$i] =~ /^#.+\sX(\d+)\sY(\d+)/;
	push @relays, { id => $i, x => $1, y => $2 };
}

for (my $i = 0; $i < @relays - 1; $i++) {
	for (my $j = $i + 1; $j < @relays; $j++) {
		if (manhattan_dist($relays[$i], $relays[$j]) <= 5) {
			push @{$relays[$i]->{neighbours}}, $j;
			push @{$relays[$j]->{neighbours}}, $i;
		}
	}
}

my $visited = 1;
print dfs(\@relays, 0, $visited, {}) . "\n";

