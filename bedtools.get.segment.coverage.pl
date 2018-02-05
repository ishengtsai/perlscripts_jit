#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';




if (@ARGV != 1) {
    print "$0 file \n" ;
	exit ;
}

my $filenameA = $ARGV[0];



my %genes = () ; 
my %gene_synteny_count = () ; 

open (IN, "$filenameA") or die "oops!\n" ;


my $cov = 0 ; 
my $start = 0 ;
my $ref = 0 ;
my $end = 0 ;

my $previous_offset  = 0 ; 
my $previous_start = 0 ; 

while (<IN>) {

    chomp; 
    next if /^\#/ ; 
    
    my @r = split /\s+/, $_ ;



    
    if ( $ref ne $r[0] || $r[3] == 1 ) {

	if ( $cov != 0 ) {
	    $end = $start + $previous_offset -1 ;
	    print "$ref\t$start\t$end\t$cov\t"  . ($end - $start + 1)  .  "\t$r[3]\n" ;
	}

	$ref = $r[0] ;
	$cov = $r[4] ;
	$start = $r[1] ;
    }

    
    
    if ( $cov != $r[4] ) {
	#print "diff!\n" ;
	$end = $r[1] + $r[3] -1 ; 
	print "$ref\t$start\t$end\t$cov\t"  . ($end - $start + 1)  .  "\t$r[3]\n" ; 

	$cov = $r[4] ;
	$start = $r[1] + $r[3];
	
    }
    
    $previous_start = $r[1] ; 
    $previous_offset = $r[3] ;     

}



