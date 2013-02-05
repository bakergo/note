#!/usr/bin/env perl
# Opens up text files in the users' home directory under ~/notes/<subj>/<topic>
# uses sensible-editor to do the editing

use warnings;
use strict;
use version; our $VERSION = version->declare('v0.0');
use Env qw(HOME);
use File::Basename;
use File::Path qw(make_path);
use File::Spec::Functions;

sub usage {
	print "usage: ". basename($0) ." [-l]  [-h] [-s <subject>] <topic>\n";
	exit shift;
} 

my $notes = catfile($HOME, 'notes');
my @topics = ();
my $subject = undef;
while (@ARGV) {
	my $arg = shift;
	if ($arg =~ /^--?s(ubject)?$/) {
		$subject = shift or die "Expect a subject after -s";
	} elsif ($arg =~ /^--?h(elp)?$/) {
		usage(0);
	} elsif ($arg =~ /^--?l(ist)?$/) {
		print "$_\n" foreach glob(catfile($notes, $subject, '*'));
	} else {
		push @topics, catfile($notes, $arg) unless $subject;
		push @topics, catfile($notes, $subject, $arg) if $subject;
	}
}
make_path(dirname($_)) for (@topics);

exec 'sensible-editor', @topics if (@topics);
usage(0);

