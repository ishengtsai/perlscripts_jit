#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';




if (@ARGV != 1) {
    print "$0 fasta \n" ;
	exit ;
}

my $filenameA = $ARGV[0];





open (IN, "$filenameA") or die "oops!\n" ;

my $count = 1 ; 

while (<IN>) {


    if ( /gene:(\S+)/ ) {
	print ">$1\n" ; 
	
    }
    else {
	print "$_" ; 
    }



}
