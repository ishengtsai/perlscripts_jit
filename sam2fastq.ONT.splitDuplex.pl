#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV != 1) {
	print "$0 bam\n\n" ;
	exit ;
}

my $filenameA = $ARGV[0];

open SIMPLEX, ">", "$filenameA.simplex.fq" or die "daosdapo\n" ;
open DUPLEX, ">", "$filenameA.duplex.fq" or die "daosdapo\n" ;


open (IN, "samtools view $filenameA |") or die "oops!\n" ;



while (<IN>) {
    
    #next if /^\@/ ;

    my @r = split /\s+/, $_ ;

    if ( /dx:i:1/ ) {
	print DUPLEX "\@$r[0]\n$r[9]\n\+\n$r[10]\n" ;
    }
    elsif ( /dx:i:0/ ){
	print SIMPLEX "\@$r[0]\n$r[9]\n\+\n$r[10]\n" ;
    }
	

    


    #last ; 
}
close(IN) ; 
