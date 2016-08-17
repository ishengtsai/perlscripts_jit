#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV != 2) {
	print "$0 fasta len\n\n" ;
	exit ;
}

my $filenameA = $ARGV[0];
my $len = $ARGV[1] ; 


open (IN, "$filenameA") or die "oops!\n" ;
open OUT, ">", "$filenameA.above$len.fa" or die "daodpoad\n" ; 

	my $read_name = '' ;
	my $read_seq = '' ;

	while (<IN>) {
	    if (/^>(\S+)/) {
		$read_name = $1 ;
		$read_seq = "" ;
		$read_name =~ s/\#/\./gi ; 
		
		while (<IN>) {

			if (/^>(\S+)/) {
			    
			    if ( length($read_seq) >= $len ) {
				print OUT ">$read_name\n$read_seq\n" ; 
			    }

			    $read_name = $1 ;
			    $read_seq = "" ;
			    $read_name =~ s/\#/\./gi ;


			}
			else {
			    chomp ;
			    $read_seq .= $_ ;
			}


		}

	    }
	}

close(IN) ;

if ( length($read_seq) >= $len ) {
    print OUT ">$read_name\n$read_seq\n" ;
}

print "all done! $filenameA.above$len.fa produced\n" ; 
