#!/usr/bin/perl
use strict;
use warnings;
use List::Util qw(min max shuffle);

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
				$material{$new_x . '_' . $new_y} = undef;
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


#for (my $y = $limits{min_y}; $y <= $limits{max_y}; $y++) {
#	for (my $x = $limits{min_x}; $x <= $limits{max_x}; $x++) {
#		if (exists($material{$x . '_' . $y})) {
#			print "#";
#		} else {
#			print ".";
#		}
#	}
#	print "\n";
#}
#print "\n";

my @dirs = (
	{ dx =>  0, dy =>  1 },
	{ dx =>  0, dy => -1 },
	{ dx =>  1, dy =>  0 },
	{ dx => -1, dy =>  0 },
);

# find all shapes

my @shapes = ({ x => 0, y => 0, size => 0});
while(%material) {
	my $start = (keys %material)[0];
	my %visited;
	$visited{$start} = undef;
	my ($x, $y) = split/_/, $start;

	outer:
	while (1) {
		for my $dir (@dirs) {
			my ($new_x, $new_y) = ($x + $dir->{dx}, $y + $dir->{dy});
			my $key = $new_x . '_' . $new_y;
			if (exists($material{$key})) {
				if (!exists($visited{$key})) {
					$visited{$key} = undef;
					($x, $y) = ($new_x, $new_y);
					next outer;
				}
			}
		}
		last;
	}

	my @coords;
	for my $key (keys %visited) {
		delete($material{$key});
		push @coords, [split/_/, $key];
	}

	@coords = sort { $a->[1] <=> $b->[1] || $a->[0] <=> $b->[0] } @coords;

	push @shapes, { x => $coords[0][0], y => $coords[0][1], size => scalar @coords };
}

sub dist {
	my ($shape1, $shape2) = @_;
	return abs($shape1->{x} - $shape2->{x}) + abs($shape1->{y} - $shape2->{y});
}

my @path = ();
foreach my $shape (@shapes) {
	push @path, $shape;
}
push @path, ({ x => 0, y => 0, size => 0});

my $l = scalar @path - 1;

my $pr = 1;

# a bit janky, runs forever and looks for improvements to the path
# submit answer when it looks stable
while(1) {
	my ($x, $y) = (0, 0);
	my $moves = 0;
	for (my $i = 1; $i < @path; $i++) {
		$moves = $moves + abs($x - $path[$i]->{x}) + abs($y - $path[$i]->{y}) + $path[$i]->{size};
		($x, $y) = ($path[$i]->{x}, $path[$i]->{y});
	}
	$moves = $moves + $x + $y;

	if ($pr) {
		foreach my $shape (@path) {
			print $shape->{x} . " " . $shape->{y} . ", ";
		}
		print "$moves\n";
	}

	my $dist = 0;
	for (my $i = 0; $i < @path - 1; $i++) {
		$dist += dist($path[$i], $path[$i+1]);
	}

	my @backup = @path;

	my $n = int(rand($l - 2)) + 2;
	my @take;
	my %seen;
	for (my $i = 0; $i < $n; $i++) {
		my $val;
		do {
			$val = int(rand($l - 1)) + 1;
		} while (exists($seen{$val}));
		$seen{$val} = undef;
		push @take, $val;
	}

	my @values;
	foreach my $pos (@take) {
		push @values, $path[$pos];
	}
	@values = shuffle @values;
	for (my $i = 0; $i < @values; $i++) {
		$path[$take[$i]] = $values[$i];
	}

	my $new_dist = 0;
	for (my $i = 0; $i < @path - 1; $i++) {
		$new_dist += dist($path[$i], $path[$i+1]);
	}

	$pr = 0;
	if ($new_dist > $dist) {
		@path = @backup;
	} elsif ($new_dist < $dist) {
		$pr = 1;
	}
}
