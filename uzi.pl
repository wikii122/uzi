#!/usr/bin/env perl
#
# Wiktor Ślęczka <wikii122@gmail.com>
# Anno Domini 2015
#
# Refer to README file for project description.

use warnings;
use strict;
use v5.14;
use Tk;
use Tk::BrowseEntry;
use Tk::NoteBook;
use Crypt::RandPasswd;

if ($> != 0) {
    die "You need  to be root to run this program.";
}
sub launch {
	my $window = new MainWindow;
	my $nb = $window -> NoteBook( )-> pack();
	my $tab1 = $nb->add('create', -label => 'Create');
	my $tab2 = $nb->add('groups', -label => 'Groups');
	my $tab3 = $nb->add('delete', -label => 'Delete');

	my (@users, @groups);

	while (my ($name, $pass, $uid, $gid, $quota, $comment, $gcos, $dir, $shell, $expire) = getpwent()) {
		push @users, $name;
	}

	open my $FILE, "/etc/group";
	for my $line (<$FILE>) {
		my @elements = split ':', $line;
		push @groups, $elements[0];
	}

	## USER GROUP MODIFICATION
	# Tab 2 init - list of users and list of groups.
	our $user = $users[1];
	my $user_select = $tab2 ->BrowseEntry(-label => "User", -variable => \$user, -command => \&refresh_groups) -> pack();
	my $user_rest = $user_select -> Subwidget('slistbox');
	$user_rest -> insert('end', @users);

	our %group_radio;
	our %group_checked;
	for my $group (@groups) {
		$group_radio{$group} = $tab2 -> Checkbutton(-text=> $group, -command => set_group($group)) -> pack();
	}

	sub refresh_groups {
		my @user_groups = split ':', `groups $user`;
		@user_groups = split ' ', $user_groups[1];
		for my $key (keys %group_radio) {
			$group_radio{$key} -> deselect();
			$group_checked{$key} = 0;
		}

		for my $key (@user_groups) {
			$group_radio{$key} -> select();
			$group_checked{$key} = 1;
		}
	}

	sub set_group {
		my $group = shift;
		return sub {
			if ($group_checked{$group}) {
				`gpasswd -d $user $group`;
				$group_checked{$group} = 0;
			} else {
				`gpasswd -a $user $group`;
				$group_checked{$group} = 1;
			}
		}
	}

	## USER DELETION
	our $user2 = $users[1];
	my $user_select2 = $tab3 -> BrowseEntry(-label => "User", -variable => \$user2) -> pack();
	my $user_delete_trigger = $tab3 -> Button(-text => "Delete", -command => \&delete_user) -> pack();
	my $user_rest2 = $user_select2 -> Subwidget('slistbox');
	$user_rest2 -> insert('end', @users);

	sub delete_user {
		`userdel $user2`;
	}

	refresh_groups();

	MainLoop;

	exit 0;
}

my $help = <<END;
	Usage:
		uzi.pl - start in interactive mode.
		uzi.pl [option] - execute barch option.

	Help:
		create - creates user
		group - modifies users groups
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
		my $pass = Crypt::RandPasswd->chars(8, 20);
        my $crypt = `openssl passwd -crypt "\Q$pass\E"`;
        my $sha1 = `sha1pass "\Q$pass\E"`;
        say "Password: " . $pass;
        print "Crypt: $crypt";
        print "SHA-1: $sha1";
        my $salt = Crypt::RandPasswd->chars(2, 6);
        say "SHA-512: " . crypt($pass, "\$6\$$salt\$")
         
	} elsif ($command eq "uid") {
		my $uid = shift || free_uid();
		if (check_uid($uid) != 0) {
			say $uid . " is taken";
		} else {
			say $uid . " is free";
		}
	}
} elsif ($command eq "interactive") {
	launch;
} elsif ($command eq "create") {
	my ($parameters, $result);
	$parameters = join(" ", @ARGV);
	$result = `useradd $parameters 2>&1`;
	$result =~ s/useradd/uzi.pl create/g;
	say $result;
} elsif ($command eq "delete") {
	my ($parameters, $result);
	$parameters = join(" ", @ARGV);
	$result = `userdel $parameters 2>&1`;
	$result =~ s/userdel/uzi.pl delete/g;
	say $result;
} elsif ($command eq "group") {
	my ($parameters, $result);
	$parameters = join(" ", @ARGV);
	$result = `gpasswd $parameters 2>&1`;
	$result =~ s/gpasswd/uzi.pl group/g;
	say $result;
}

sub free_uid {
	my $checked = 1;
	while (check_uid($checked)) {
		$checked += 1;
	}

	return $checked;
}

sub check_uid {
	my $checked = shift;
	while (my ($name, $pass, $uid, $gid, $quota, $comment, $gcos, $dir, $shell, $expire) = getpwent()) {
		if ($uid == $checked) {
			return 1;
		}
	}
	return 0;
}
