#!/usr/bin/env perl
#
# Wiktor Ślęczka <wikii122@gmail.com>
# Anno Domini 2015
#
# Refer to README file for project description.
#
# TODO:
# - console mode
#   - create user
#   - choose free uid
#   + generate random password
#   - copy home dir from template
#   - store user data in root's catalogue
#   - check if uid is taken
#   - change user group
#   - delete user
# - interactive mode
#   - create user
#   - choose free uid
#   - generate random password
#   - copy home dir from template
#   - store user data in root's catalogue
#   - check if uid is taken
#   - change user group
#   - delete user

use warnings;
use strict;
use v5.10;
use Crypt::RandPasswd;

sub launch {
	say "GUI";
	exit 0;
}

my $help = <<END;
	Usage:
		uzi.pl - start in interactive mode.
		uzi.pl [option] - execute barch option.

	Help:
		create - creates user
		modify - modifies user
		delete - deletes user
		check - checks uid or creates new password.
		interactive - start GUI
END

my $command = shift or die $help;

if ($command eq "-h" or $command eq "--help") {
	say $help;
} elsif ($command eq "check") {
	my $command = shift(@ARGV) or die $help;
	if ($command eq "password") {
		say Crypt::RandPasswd->chars(8, 20);
	}
} elsif ($command eq "interactive") {
	launch;
}
