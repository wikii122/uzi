#!/usr/bin/env perl
#
# Wiktor Ślęczka <wikii122@gmail.com>
# Anno Domini 2015
#
# Refer to README file for project description.
#
# TODO:
# + console mode
# - interactive mode

use warnings;
use strict;
use v5.10;

sub launch {
	say "GUI"
}

my $help = "None yet";

my $command = shift(@ARGV) or launch() and exit 0;

if ($command eq "-h" or $command eq "--help") {
	say $help;
} else {
	my $args = join(' ', @ARGV);
	my $response = `useradd $args 2>&1`;
	$response =~ s/useradd/uzi.pl/g;
	say $response;
}
