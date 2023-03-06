#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV != 1) {
    print "$0 wig\n" ;
    print "note only works for span=1 !!!! XD\n" ; 

	exit ;
}



my $filenameA = $ARGV[0];



open (IN, "$filenameA") or die "oops!\n" ;
open OUT, ">",  "$filenameA.bed" or die "can't create output file!\n" ; 


my $ref ;
while (<IN>) {
    chomp ;
    if (/variableStep chrom=(\S+)/ ) {
	$ref = $1 ; 
    }

    next unless /^\d+/ ; 
    my @r = split /\s+/, $_ ;

    #print "@r\n" ; 
    print OUT "$ref\t" . ($r[0]-1) . "\t$r[0]\t$r[1]\n" ; 
    
}
close(IN) ;

print "$filenameA.bed done!\n" ; 
