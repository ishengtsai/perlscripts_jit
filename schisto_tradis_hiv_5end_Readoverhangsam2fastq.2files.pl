#!/usr/bin/perl -w
use strict;



if (@ARGV != 1) {
    print "$0 hiv.sam \n" ; 


	exit ;
}
my $schistofile = shift @ARGV ; 



open (SCHISTO, "$schistofile") or die "Daosdapda\n" ; 
open OVERHANGFA, ">", "$schistofile.overhang.5end.fa" or die "daodpaodops\n" ; 
open OVERHANGFA2, ">", "$schistofile.overhang.3end.fa" or die "daodpaodops\n" ;
open DIST, ">", "$schistofile.overhang.dist" or die "daodaspodop\n" ; 

my $overhang = 0 ; 
my $total = 0 ; 
my $overhangthreeEnd = 0 ; 
my $good = 0 ; 
my $others = 0 ; 
my $filtered = 0 ; 

while (<SCHISTO>) {

    my @READ = split /\s+/, $_ ; 
    $total++ ; 


    if ( $READ[3] < 13000 ) {
	next ; 
    }

    local $" = "\t";
    $READ[5] = modifycigar($READ[5]) ; 

    #print "$READ[5]\n" ; 
    #print "@READ\n" ; 
    my $map = $1 ; 
    
    if ( $READ[5] =~ /(\d+)M(\d+)S$/ ) {
	$overhangthreeEnd++ ; 

	if ( $2 > 30 ) {
	    my $overhanglen = $1 ;
	    my $subfa = substr( $READ[9], $overhanglen) ;
	    print OVERHANGFA2 ">$READ[0]\n$subfa\n" ;
	    print DIST "$1\t$2\n" ;
	}
    }


    if ( $READ[5] =~ /^(\d+)S(\d+)M/ ) {
	$map = $2 ; 
	next if $map < 30 ; 

	if ( $1 < 10 ) {
	    $good++ ; 
	    print DIST "$1\t$2\n" ;
	}
	else {
	    print DIST "$1\t$2\n" ; 
	    $overhang++ ; 

	    if ( $1 > 30 ) {
		my $overhanglen = $1 ; 
		#print "@READ\n" ;
		my $subfa = substr( $READ[9], 0, $overhanglen) ; 
		print OVERHANGFA ">$READ[0]\n$subfa\n" ; 
	    }

	}
    }
    elsif ( $READ[5] =~ /^(\d+)M/ ) {
	$map = $1 ;
	next if $map < 30 ; 

	$good++ ; 
    }
    else {
	$others++ ; 
    }


    



}



print "Total: $total\n" ; 
print "Good: $good\n" ; 
print "Overhang: $overhang\n" ; 
print "Final filtered $filtered\n" ; 
print "Others: $others\n" ; 



sub modifycigar {

    my $cigar = shift ; 
    $cigar =~ s/\d+D//gi ; 
    $cigar =~ s/I/M/gi ; 

    if ( $cigar =~ /^\d+M\d+S$/ ) {
	return $cigar ; 
    }

    while ( $cigar =~ /(\d+)M(\d+)M/ ) {
	my $total = $1 + $2 ; 
	my $replace = $total . "M" ; 
	$cigar =~ s/\d+M\d+M/$replace/ ; 
    }
    while ( $cigar =~ /(\d+)S(\d+)M/ ) {
	my $total = $1 + $2 ; 
	my $replace = $total . "M" ; 
	$cigar =~ s/\d+S\d+M/$replace/ ; 
    }

    if ( $cigar =~ /^\d+M\d+S/ || $cigar=~ /^\d+M$/ ) {

    }
    else {
	print "erm!!! $cigar\n" ; 
	exit ; 
    }

    return $cigar ; 
}



