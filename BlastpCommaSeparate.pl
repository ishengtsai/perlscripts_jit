#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';




if (@ARGV != 1) {
    print "$0 blastpoutput\n" ; 
    print "has to be singleline..\n" ; 
	exit ;
}

my $filenameA = $ARGV[0];




open (IN, "$filenameA") or die "oops!\n" ;



while (<IN>) {
    chomp; 
    my @r = split /\,/, $_ ; 
    print "@r\n" ; 


}
