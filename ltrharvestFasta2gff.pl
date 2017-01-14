#!/usr/bin/perl -w
use strict;






if (@ARGV != 1) {
	print "$0 fasta\n\n" ;
	exit ;
}

my $filenameA = $ARGV[0];

open (IN, "$filenameA") or die "oops!\n" ;

while (<IN>) {

    if (/^>(\S+).+\[(\d+),(\d+)\]$/) {
	print "$1\tLTRharvest\tLTR\t$2\t$3\t1000\t+\t.\tLen:" . ($3-$2+1)."\n" ; 
    }
}
close(IN) ;



