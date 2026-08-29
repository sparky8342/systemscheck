#!/usr/bin/perl
use strict;
use warnings;

my $fh;
open $fh, "<", "../inputs/4.txt";
my @data = <$fh>;
close $fh;
chomp($_) foreach @data;

my $sum = 0;
foreach my $line (@data) {
	$line =~ /^(.*?)(\d+)$/;
	my ($message, $checksum) = ($1, $2);
	my $cksum = 0;
	for my $ch (split//, $message) {
		$cksum ^= ord($ch);
	}
	if ($cksum != $checksum) {
		$sum += $checksum;
	}
}	
printf("%d\n", $sum);
