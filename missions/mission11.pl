#!/usr/bin/perl
use strict;
use warnings;

sub decode {
	my ($bytes) = @_;
	return _decode($bytes, 0, scalar @$bytes, 0, {});
}

sub decodeFE {
	my ($bytes) = @_;
	return _decode($bytes, 0, scalar @$bytes, 1, {});
}

sub _decode {
	my ($bytes, $start, $len, $decodeFE, $cache) = @_;
	if (exists($cache->{$start, $len})) {
		return $cache->{$start, $len};
	}

	my $add = 0;

	for (my $i = $start; $i < $start + $len; $i++) {
		if ($bytes->[$i] eq 'FF') {
			$add += hex($bytes->[$i+2]);
			$i += 2;
		} elsif ($bytes->[$i] eq 'FE' && $decodeFE) {
			$add += _decode($bytes, $i - hex($bytes->[$i+1]), hex($bytes->[$i+2]), 1, $cache);
			$i += 2;
		} else {
			$add++;
		}
	}

	$cache->{$start, $len} = $add;
	return $add;
}

my $fh;
open $fh, "<", "../inputs/11.txt";
my $data = <$fh>;
close $fh;
chomp($data);

my $bytes = [split/ /, $data];
printf("%d\n%d\n", decode($bytes), decodeFE($bytes));
