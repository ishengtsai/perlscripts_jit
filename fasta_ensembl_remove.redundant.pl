#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV != 1) {
    print "$0 fasta\n\n" ;
    print "Will select gene based on gene\n" ; 
	exit ;
}

my $filenameA = $ARGV[0];

my %genes = () ; 

open (IN, "$filenameA") or die "oops!\n" ;

	my $read_name = '' ;
	my $read_seq = '' ;

	while (<IN>) {
	    if (/\s+gene:(\S+)/) {
		$read_name = $1 ;
		$read_seq = "" ;
		
		while (<IN>) {

			if (/\s+gene:(\S+)/) {
			    my $new_name = $1 ; 

			    if ( $genes{$read_name}  ) {
				
			    }
			    else {
				print ">$read_name\n$read_seq\n" ;
				$genes{$read_name}++ ; 
			    }
			    
			    $read_name = $new_name ;
			    $read_seq = "" ;



			}
			else {
			    chomp ;
			    $read_seq .= $_ ;
			}


		}

	    }
	}

close(IN) ;

if ( $genes{$read_name}  ) {

}
else {
    print ">$read_name\n$read_seq\n" ;
    $genes{$read_name}++ ;
}
