#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV != 1) {
	print "$0 fasta\n\n" ;
	exit ;
}

my $filenameA = $ARGV[0];

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

			    my $tmp = $1 ; 

			    if ( $read_name =~ /Schisto_mansoni.Chr_/ ) {
				print "$count\t$read_name\t" . length($read_seq) . "\n" ;
				$count++ ; 
			    }


			    $read_name = $tmp ;
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



if ( $read_name =~ /Schisto_mansoni.Chr_/ ) {
    print "$count\t$read_name\t" . length($read_seq) . "\n" ;
    $count++ ;
}
