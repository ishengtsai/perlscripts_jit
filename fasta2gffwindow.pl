#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV != 2) {
    print "$0 fasta.len.txt window_size \n" ; 
	exit ;
}

my $filenameA = $ARGV[0];
my $window = $ARGV[1] ;

open (IN, "$filenameA") or die "oops!\n" ;



my $count =1 ; 

while (<IN>) {
    chomp; 
    my @r = split /\s+/, $_ ; 

    for (my $i = 1 ; $i < $r[1] ; $i += $window ) {

	my $left = $i ; 
	my $right = $i + $window - 1 ; 

	if ( $right > $r[1] ) {
	    $right = $r[1] ; 
	}
	
	

	print "$r[0]\twindow\twindow\t$left\t$right\t.\t+\t.\t$count\n" ; 

	$count++ ; 


    }





}

close(IN) ; 



































