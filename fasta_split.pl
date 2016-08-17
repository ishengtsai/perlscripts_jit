#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';




if (@ARGV != 3) {
    print "$0 fasta folder count\n" ;
	exit ;
}

my $filenameA = $ARGV[0];
my $folder = $ARGV[1] ;
my $bin = $ARGV[2] ; 

mkdir "$folder" ;

my $count = 0 ; 
my $tmp_count = 0 ; 

open (IN, "$filenameA") or die "oops!\n" ;



	while (<IN>) {

	    if ( $tmp_count == 0 ) {
		$count++ ; 
		open OUT, ">", "$folder/$filenameA.$count.fa" or die "ooops\n" ;
	    }


	    if (/^>(\S+)/) {
		my $name = $1 ;
		my $seq = <IN> ; 
		
		$name =~ s/\#/\./gi ;
		$name =~ s/\//\./gi ;


		print OUT ">$name\n" ;
		print OUT "$seq" ; 

		$tmp_count++ ; 

		if ( $tmp_count == $bin ) {
		    $tmp_count = 0 ; 
		    close(OUT) ; 

		}


	    }


	}

close(IN) ;


print "all done!\n" ;

