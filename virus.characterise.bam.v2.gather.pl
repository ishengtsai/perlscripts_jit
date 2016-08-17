#! /usr/bin/perl -w
#
#
# Copyright (C) 2009 by Pathogene Group, Sanger Center
#
# Author: JIT
# Description:
#               a script that map the Solexa reads back to the reference/contigs
#               and parition them based on either ends of the contigs
#
#
#




use strict;
use warnings;

# to print
local $" = "\t";


my $PI = `echo $$` ; chomp($PI) ;


#"


if (@ARGV != 2 ) {
    print "$0 out.sorted.markdup.bam.raw.sorted out.sorted.markdup.bam.correspondingreadsfound.sam.sorted  \n" ;
    exit;
}



my $bamraw = shift;
my $bam = shift ; 

print '------------------------------------------------' ;
print "\nauthor: JIT\n" ;
print "bam raw is: $bamraw\n" ; 
print "bam file is: $bam\n" ;
print '------------------------------------------------' . "\n\n";

my %reads = (); 

my %bothgood = () ; 
my %mapped = () ; 

my $wormonly = 0 ; 
my $total = 0 ; 
my $virusonly = 0 ; 
my $notenoughevidence = 0 ;
my $falsepositivearound5kb = 0 ; 
my $independent = 0 ; 

open( VIRUS, "$bamraw") or die "doapdopsa\n" ; 
open( WORMS, "$bam") or die "doapdooa\n" ; 

while (<VIRUS>) {
    chomp ;
    my $read1 = $_ ; 
    my @virus1 = split /\s+/, $read1 ;

    my $read2 = <VIRUS> ;
    chomp($read2) ; 
    my @virus2 = split /\s+/, $read2 ; 
    
    $read1 = <WORMS> ; chomp($read1) ; 
    my @worms1 = split /\s+/, $read1 ;

    $read2 = <WORMS> ; chomp($read2) ;
    my @worms2 = split /\s+/, $read2 ;

    # remove PCR duplicate
    next if $virus1[1] >= 1000 ; 
    next if $virus2[1] >= 1000 ; 

    # sanity check
    if ( $virus1[0] ne $virus2[0] ) {
	print "weird!!!! $virus1[0] and $virus2[0]\n" ; 
	exit ; 
    }
    if ( $worms1[0] ne $worms2[0] ) {
        print "weird!!!! $worms1[0] and $worms2[0]\n" ;
        exit ;
    }
    if ( $worms1[0] ne $virus1[0] ) {
	print "weird!!!! virus and worm pair not the same!\n"  ; 
	exit ;
    }

    my $map1worm = cigarmap($worms1[5]) ; 
    my $map2worm = cigarmap($worms2[5]) ;
    my $map1virus = cigarmap($virus1[5]) ;
    my $map2virus = cigarmap($virus2[5]) ;

    # worm only
    if ( $map1worm >= 80 && $map2worm >= 80 ) {
	#print "WORM_DNA\t" ; 
	$wormonly++ ; 
	next ; 
    }

    # virus only
    if ( $map1virus >= 80 && $map2virus >= 80 ) {
	print "VIRUS_DNA\t" ;
	$virusonly++ ;

	print "$virus2[0]\t" ;
	print "$virus1[1]\t$virus1[3]\t$virus1[5]\t" ;
	print "$virus2[1]\t$virus2[3]\t$virus2[5]\t" ;

	print "$worms1[1]\t$worms1[2]\t$worms1[3]\t$worms1[5]\t" ;
	print "$worms2[1]\t$worms2[2]\t$worms2[3]\t$worms2[5]\n" ;
	next ; 

    }

    
    if ( $map1worm < 30 && $map2worm < 30 ) {
	    $notenoughevidence++ ;
	    next ; 
    }
    elsif ( $map1virus < 30 && $map2virus < 30 ) {
	$notenoughevidence++ ;
	next ; 
    }
    

    #
    if ( $map1virus >= 80 && $map2worm >= 80 ) {
	$independent++ ; 
	$total-- ; 
	print "INDEPENDENT\t" ;
    }
    elsif ( $map2virus >= 80 && $map1worm >= 80 ) {
        $independent++ ;
	$total-- ;
	print "INDEPENDENT\t" ;
    }


    # false positive filter here
    if ( $virus1[3] >= 5610 && $virus1[3] <= 5640 ) {
	$falsepositivearound5kb++ ; 
        next ;

    }

    print "$virus2[0]\t" ; 
    print "$virus1[1]\t$virus1[3]\t$virus1[5]\t" ;
    print "$virus2[1]\t$virus2[3]\t$virus2[5]\t" ;

    print "$worms1[1]\t$worms1[2]\t$worms1[3]\t$worms1[5]\t" ;
    print "$worms2[1]\t$worms2[2]\t$worms2[3]\t$worms2[5]\n" ;

    

    $total++ ; 

}
close(VIRUS) ; 
close(WORMS) ; 

print "\#\# Still uncategorised pairs: $total pairs\n" ; 
print "\#\# worm only (false positive type 1): $wormonly\n" ; 
print "\#\# virus only: $virusonly\n" ; 
print "\#\# not enough evidence on both species (false positive type 2): $notenoughevidence\n" ; 
print "\#\# false mappings around 5kb (false positive type 3): $falsepositivearound5kb\n" ; 

sub cigarmap {
    my $cigar = shift ;
    my $map = 0 ; 


    while ( $cigar =~ /(\d+)M/ ) {
	my $mapcigar = "$1" . "M" ; 
        $map += $1 ;
        $cigar =~ s/$mapcigar// ;
    }

    return $map ;
}

