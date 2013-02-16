#!/usr/bin/env perl
# Opens up text files in the users' home directory under ~/notes/<subj>/<topic>
# uses sensible-editor to do the editing

use warnings;
use strict;
use version; our $VERSION = version->declare('v0.1');
use Env qw(HOME);
use File::Basename;
use File::Path qw(make_path);
use File::Spec::Functions;

my $editor = $ENV{EDITOR} || 'sensible-editor';
my $notes = catfile($HOME, 'notes');
my @topics = ();
my $subject = undef;

sub usage {
	print "usage: ". basename($0) ." [-l]  [-h] [-s <subject>] [--short-list] <topic>\n";
	exit shift;
}

sub complete {
	my @flags = qw(-h --help -s --subject -l --list --short-list);
	my @potentials = ();
	my $to_complete = pop;
	my $previous = pop;
	my $subject = pop;

	if (defined($previous) and $previous =~ /^--?s(ubject)?$/) {
		# We're completing a subject
		# Print anything that matches the subject and/or is contained
		# in a matching subject
		@potentials = map({ basename $_ } grep(-d, glob(catfile($notes, "$to_complete*")))),
			map({ basename $_ } grep(-f, glob(catfile($notes, $to_complete, '*'))));
	}  else {
		# Search backwards through the list for the current subject
		# Populate the list with the list of potential files
		while (defined($subject)) {
			if ($subject =~ /^--?s(ubject)?$/) {
				$subject = $previous;
				last;
			}
			$previous = $subject;
			$subject = pop;
		}
		@potentials = map({ basename $_ } grep(-f, glob(catfile($notes, $subject, "$to_complete*"))));
	}
	print join("\n", grep(/^$to_complete/, @flags), @potentials);
	exit 0;
}

if (scalar(@ARGV) and $ARGV[0] eq '--complete') {
	complete(@ARGV);
}

while (@ARGV) {
	my $arg = shift;
	if ($arg =~ /^--?s(ubject)?$/) {
		$subject = shift or die "Expect a subject after -s";
	} elsif ($arg =~ /^--?h(elp)?$/) {
		usage(0);
	} elsif ($arg =~ /^--short-list$/) {
		print join(' ', map({ basename $_ } glob(catfile($notes, $subject, '*'))));
		exit 0;
	} elsif ($arg =~ /^--?l(ist)?$/) {
		print join("\n", map({ basename $_ } glob(catfile($notes, $subject, '*'))), '');
		exit 0;
	} else {
		push @topics, catfile($notes, $arg) unless $subject;
		push @topics, catfile($notes, $subject, $arg) if $subject;
	}
}
make_path(dirname($_)) for (@topics);

exec $editor, @topics if (@topics);
usage(0);

