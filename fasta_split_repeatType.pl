#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV != 1) {
    print "$0 fasta  \n" ;
    print "Takes repeatlib.fa and split repeat and unknown\n" ; 
    exit ;
}



my $filenameA = $ARGV[0] ; 
#my $prefix = $ARGV[1] ;

open OUT, ">", "$filenameA.repeatknown.fa" or die "ooops\n" ;
open OUT2, ">", "$filenameA.repeatunknown.fa" or die "ooops\n" ;

my $count = 1 ; 


my $repeatisknown = 1 ;


open (IN, "$filenameA") or die "oops!\n" ;

	my $read_name = '' ;
	my $read_seq = '' ;

	while (<IN>) {
	    if (/^>(\S+)/) {
		$repeatisknown = 1 ; 
		$read_name = $1 ;
		$read_seq = "" ;
		
		$repeatisknown = 0 if $read_name =~ /\#Unknown/ ;   
		
		while (<IN>) {
		    
		    if (/^>(\S+)/) {
			if ( $repeatisknown == 1 ) {
			    print OUT ">$read_name\n$read_seq\n" ;
			}
			else {
			    print OUT2 ">$read_name\n$read_seq\n" ;
			}

			$read_name = $1 ;
			$read_seq = "" ;
			$repeatisknown = 1 ;
			$repeatisknown = 0 if $read_name =~ /\#Unknown/;
			$count++ ; 
		    }
			else {
			    chomp ;
			    $read_seq .= $_ ;
			}


		}

	    }
	}




if ( $repeatisknown == 1 ) {
    print OUT ">$read_name\n$read_seq\n" ;
}
else {
    print OUT2 ">$read_name\n$read_seq\n" ;
}


close(IN) ;
close(OUT) ;


print "all done! $filenameA.repeatknown.fa and $filenameA.repeatunknown.fa generated!\n" ;
