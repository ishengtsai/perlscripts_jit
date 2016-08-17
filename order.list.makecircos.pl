#!/usr/bin/perl -w
use strict;



if (@ARGV != 1) {
    print "$0 coords \n\n" ;

    exit ;
}

my $file = shift @ARGV;


# Tmuris
open (IN, $file) or die "oooopss\n" ;

my %scaff_num = () ;

while (<IN>) {

    chomp;

    if ( /(^\S+)/ ) {
	print "$1\;" ;
    }
}
close(IN);

print "\n\n" ; 
