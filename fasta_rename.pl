#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV != 2) {
    print "$0 fasta prefix \n" ;
    print "Takes fasta and prefix, and will rename as prefix.1 prefix.2 ... etc\n" ; 
    exit ;
}



my $filenameA = $ARGV[0] ; 
my $prefix = $ARGV[1] ;

open OUT, ">", "$prefix.fa" or die "ooops\n" ;

my $count = 1 ; 

open (IN, "$filenameA") or die "oops!\n" ;

	my $read_name = '' ;
	my $read_seq = '' ;

	while (<IN>) {
	    if (/^>(\S+)/) {
		$read_name = $1 ;
		$read_seq = "" ;
		
		while (<IN>) {
		    
		    if (/^>(\S+)/) {
			    
			print OUT ">$prefix.$count\n$read_seq\n" ; 
			$read_name = $1 ;
			$read_seq = "" ;
			$count++ ; 
		    }
			else {
			    chomp ;
			    $read_seq .= $_ ;
			}


		}

	    }
	}

close(IN) ;
close(OUT) ;


print "all done! $prefix.fa generated!\n" ;
