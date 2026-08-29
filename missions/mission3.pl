#!/usr/bin/perl
package Relay;
use strict;
use warnings;

sub new {
	my ($class, %params) = @_;
	my $self = {
		neighbours => [],
		buffer => [],
		chunks_seen => {},
	};
	%$self = (%$self, %params);
	bless $self, $class;
	return $self;
}

sub add_neighbour {
	my ($self, $id, $dist) = @_;
	push @{$self->{neighbours}}, { id => $id, dist => $dist };
}

sub get_neighbours {
	my ($self) = @_;
	return $self->{neighbours};
}

sub buffer_len {
	my ($self) = @_;
	return @{$self->{buffer}};
}

sub get_chunk {
	my ($self, $pos) = @_;
	return $self->{buffer}->[$pos];
}

sub seen_chunk {
	my ($self, $chunk) = @_;
	return exists($self->{chunks_seen}->{$chunk});
}

sub remove_chunk {
	my ($self, $pos) = @_;
	splice @{$self->{buffer}}, $pos, 1;
}

sub add_to_buffer {
	my ($self, $chunk) = @_;
	push @{$self->{buffer}}, $chunk;
	$self->{chunks_seen}->{$chunk} = undef;
}

sub get_validation {
	my ($self) = @_;
	my $sum = 0;
	for (my $i = @{$self->{buffer}} - 5; $i < @{$self->{buffer}}; $i++) {
		$sum += $self->{buffer}->[$i];
	}
	$sum *= @{$self->{buffer}};
	return $sum;
}
	
package main;
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
	my @neighbours = @{$relays->[$id]->get_neighbours()};
	foreach my $neighbour (@neighbours) {
		my $id = $neighbour->{id};
		if (($visited & (1 << $id)) == 0) {
			$visited |= (1 << $id);
			$paths += dfs($relays, $id, $visited, $cache);
			$visited ^= (1 << $id);
		}
	}
	$cache->{$id, $visited} = $paths;
	return $paths;
}

sub count_paths {
	my ($relays) = @_;
	my $start = 0;
	my $visited = 1;
	my $cache = {};
	return dfs($relays, $start, $visited, $cache);
}


sub sort_neighbours {
	my ($neighbours, $relays) = @_;
	@$neighbours = sort {
		$a->{dist} <=> $b->{dist} || @{$relays->[$a->{id}]->{buffer}} <=> @{$relays->[$b->{id}]->{buffer}} || $a->{id} <=> $b->{id}
	} @$neighbours;
	return $neighbours;
}
			

sub send_message {
	my ($relays) = @_;

	my $move = 1;

	while ($move) {	
		$move = 0;

		for (my $i = 0; $i < @$relays - 1; $i++) {
			my $relay = $relays->[$i];

			if ($relay->buffer_len() > 0) {
				my $neighbours = sort_neighbours($relay->get_neighbours(), $relays);
							
				my $chunk_id = 0;
				my $n_id = 0;
				while ($chunk_id < $relay->buffer_len()) {
					my $chunk = $relay->get_chunk($chunk_id);

					my $sent = 0;
					for my $j ($n_id..@$neighbours-1, 0..$n_id - 1) {	
						my $neighbour_relay_id = $neighbours->[$j]->{id};
						my $neighbour_relay = $relays->[$neighbour_relay_id];

						if (!$neighbour_relay->seen_chunk($chunk)) {
							$relay->remove_chunk($chunk_id);
							$neighbour_relay->add_to_buffer($chunk);
							$sent = 1;
							$move = 1;
							$n_id = ($j + 1) % @$neighbours;
							last;
						}
					}
					if (!$sent) {
						$chunk_id++;
					}
				}
			}
		}
	}

	printf("%d\n", $relays->[@$relays - 1]->get_validation());

	#13328 wrong
}


my $fh;
open $fh, "<", "../inputs/3.txt";
#open $fh, "<", "example2.txt";
my @data = <$fh>;
close $fh;
chomp($_) foreach @data;

my @relays;
my $i;
for ($i = 0; $i < @data; $i++) {
	if ($data[$i] eq '') {
		last;
	}
	$data[$i] =~ /^#.+\sX(\d+)\sY(\d+)/;
	my $relay = Relay->new(id => $i, x => $1, y => $2);
	push @relays, $relay;
}
my @message = split/,/,$data[$i+1];

for (my $i = 0; $i < @relays - 1; $i++) {
	for (my $j = $i + 1; $j < @relays; $j++) {
		my $dist = manhattan_dist($relays[$i], $relays[$j]);
		if ($dist <= 5) {
			$relays[$i]->add_neighbour($j, $dist);
			$relays[$j]->add_neighbour($i, $dist);
		}
	}
}

printf("%d\n", count_paths(\@relays));

for my $chunk (@message) {
	$relays[0]->add_to_buffer($chunk);
}

send_message(\@relays);
