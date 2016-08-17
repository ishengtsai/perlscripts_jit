#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';




if (@ARGV != 1) {
    print "$0 fasta\n" ;
	exit ;
}

my $filenameA = $ARGV[0];




open (IN, "$filenameA") or die "oops!\n" ;



while (<IN>) {

    next if /\#/ ; 
    chomp; 




    if ( /^a.+mult=(\d+)/ )  {
	my $speciesnum = $1 ; 
	print "species: $speciesnum\n" ; 

	print "$_\n" ; 

	for (my $i = 0 ; $i < $speciesnum ; $i ++ ) {
	    my @r = split /\s+/, <IN> ;
	   
	    print "$r[0] $r[1] $r[2] $r[3] $r[4] $r[5]\n" ;
	    
	    my $alnlen = length($r[6]) ; 

	    print "$alnlen\n" ; 

	}

    }



}
