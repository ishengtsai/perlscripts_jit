#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV != 2) {
    print "$0 fasta proportion_to_exclude\n" ; 
	exit ;
}

my $filenameA = $ARGV[0];
my $frac = $ARGV[1] ; 

open (IN, "$filenameA") or die "oops!\n" ;

	my $read_name = '' ;
	my $read_seq = '' ;

	while (<IN>) {
	    if (/^>(\S+)/) {
		$read_name = $1 ;
		$read_seq = "" ;
		
		while (<IN>) {

			if (/^>(\S+)/) {
			    my $tmp = $1 ; 

			    my $gap = () = $read_seq =~ /-/g;
			    if ( $frac > ( $gap / length($read_seq) ) ) {
				print ">$read_name\n$read_seq\n" ;
			    }

			    $read_name = $tmp ;
			    $read_seq = "" ;



			}
			else {
			    chomp ;
			    s/\s+//gi ; 
			    $read_seq .= $_ ;
			}


		}

	    }
	}

close(IN) ;

my $gap = () = $read_seq =~ /-/g;
if ( $frac > ( $gap / length($read_seq) ) ) {
    print ">$read_name\n$read_seq\n" ;
}

