#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';




if (@ARGV != 1) {
    print "$0 fasta \n" ;
	exit ;
}

my $filenameA = $ARGV[0];



open OUT, ">", "$filenameA.changed.fa" ;

open (IN, "$filenameA") or die "oops!\n" ;

my $count = 1 ; 

	while (<IN>) {


	    if (/^>/) {
		print OUT "$_" ; 
	    }
	    else {
		chomp;
		s/ //gi ; 

		print OUT "$_\n" ;

	    }

	}

close(IN) ;




