#!/usr/bin/perl
use strict;
use warnings;



my $file = $ARGV[0];

open (IN, $file) or die "ooops\n" ; 

my $first = <IN> ; 
print "$first" ; 

my $count = 1 ; 
while (<IN>) {

    if ( /(\S+)\s+([A-Za-z\-]+)/ ) {
	my $seq = $2 ; 
	my $countformatted = sprintf("%05d", $count) ; 


	print "$countformatted $seq\n" ; 

    }

    $count++ ; 
}


