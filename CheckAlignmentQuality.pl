#!/usr/bin/perl
use strict;
use warnings;


if ( @ARGV != 2 ) {
    print "$0 folder max_gapness\n" ; 
    exit ; 
}


my $folder= shift ; 
my $max_gapness = shift;

my @files = glob("$folder/*.aln");
foreach my $f (@files) { 
	#print $f."\n";
	my $seq = "";
	open(INF,"<$f") or die("cannot read $f\n");
	while (<INF>) { 
		chomp;
		if (! m/^>/) { 
			$seq .= $_;
		}
	}
	my $count = $seq =~ tr/\-//;

	

	if (length $seq != 0) { 
	if ( ($count / (length $seq)) < $max_gapness) { 
		print $f."\t".($count / length $seq)."\n";
	}
	}
	close INF;
}
