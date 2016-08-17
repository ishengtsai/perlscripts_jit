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

	    if ( /\0/ ) {
                print "escape char found!\n" ;
            }

            s/\0//gi ;




	    if (/Trichomonas vaginalis G3 (\d+) genomic scaffold/) {
		my $seqname = "G3_$1" ; 


		#print "" . length($seqname) . "\n" ; 

		if ( length($seqname) > 40 ) {
		    print "$seqname ----> seq.$count.changed\n" ; 
		    $seqname = "seq.$count.changed" ; 
		    $count++ ; 
		}

		    print OUT ">$seqname\n" ;
	    }
	    else {
		chomp; 
		if ( $_ eq '' ) {
		
		}
		else {
		    print OUT "$_\n" ;
		}
	    }

	}

close(IN) ;




