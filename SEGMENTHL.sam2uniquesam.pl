#!/usr/bin/env perl

use strict;
use warnings;
use File::Spec;



my $PI = `echo $$` ;    chomp($PI) ;

#debug 
my $debug = 0 ; 

if (@ARGV != 2) {
    print STDERR "usage: $0 input outputprefix \n" ; 


    exit(1);
}


my $input = shift ; 
my $output = shift ; 

open (IN, "$input") or die "doaodpada\n" ; 
open OUT, ">", "$output" or die "doapdoapdpopadop\n" ; 

while (<IN>) {

    if ( /NH:i:(\d+)/ ) {
	print OUT "$_" if $1 == 1 ; 
    }
    else {
	print OUT "$_" ; 
    }

}
close(IN) ; 
