#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV != 1) {
	print "$0 sam\n\n" ;
	exit ;
}

my $filenameA = $ARGV[0];




open (IN, "$filenameA") or die "oops!\n" ;



while (<IN>) {
    
    next if /^\@/ ;

    my @r = split /\s+/, $_ ;

    print ">$r[0]\n$r[9]\n" ; 


}
close(IN) ; 
