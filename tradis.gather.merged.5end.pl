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





if (@ARGV != 2 ) {
    print "$0 HIV.merged.noheader.sam schisto.merged.noheader.sam\n" ; 
    exit;
}



my $bamraw = shift;
my $bam = shift ; 


my %reads = (); 
my %bothgood = () ; 
my %mapped = () ; 

my $wormonly = 0 ; 
my $total = 0 ; 
my $virusonly = 0 ; 
my $notenoughevidence = 0 ;
my $falsepositivearound5kb = 0 ; 
my $independent = 0 ; 

my $fiveendOverhang = 0 ; 
my $crappymapping = 0 ; 

open( VIRUS, "$bamraw") or die "doapdopsa\n" ; 
open( WORMS, "$bam") or die "doapdooa\n" ; 

open OUT, ">", "$bamraw.goodmappings.txt" or die "daodpoapod\n" ; 
open OUTFA, ">", "$bamraw.3endOverhang.fa" or die "doadpaopd\n" ; 



while (<VIRUS>) {

    chomp ;
    my $read1 = $_ ; 
    my @virus1 = split /\s+/, $read1 ;

    $read1 = <WORMS> ; chomp($read1) ; 
    my @worms1 = split /\s+/, $read1 ;

    my $readlen = length($virus1[9]) ; 

    # remove PCR duplicate
    next if $worms1[1] >= 1000 ; 

    # if completely mapped to virus
    if ( $virus1[5] =~ /^\d+M$/ ) {
	next ; 
    }

    # sanity check
    if ( $worms1[0] ne $virus1[0] ) {
	print "weird!!!! virus and worm pair not the same!\n"  ; 
	print "HIV1: @virus1\nWorm1: @worms1\n" ;
	exit ;
    }


    my $map1worm = cigarmap($worms1[5]) ; 
    my $map1virus = cigarmap($virus1[5]) ;


    # not enough evidence
    if ( $map1worm < 30 ) {
	next ; 
    }

    #HAS to be vector mappings or viral mapped
    if ( $virus1[2] eq '*' || $virus1[5] =~ /\d+S\d+M$/  ) {
    }
    else { next ; }



    
    # modify cigar strings to get a bit clearer mapping
    my $wormModifycigar = modifycigar($worms1[5]) ;
    my $virusModifycigar = modifycigar($virus1[5]) ;

    
    #mapping quality!!!
    if ( $worms1[4] < 30 ) {
        next ;
    }


    #reverse
    my $cigarReversed = 0 ; 
    my $strand = '+' ; 
 
    # Read has to be unmapped or reverse mapped ; nothing else
    if ( $virus1[1] == 4 || $virus1[1] == 16 ) {
	
    }
    else {
	#print "Virus:@virus1\n" ;
	next ; 
    }


    if ( $worms1[1] == 0 ) {
	$strand = '+' ; 
	$wormModifycigar = reversecigar($wormModifycigar) ; 
    }
    else {
	$strand = '-' ;
    }


    my $virusMapPortion = 0 ;
    my $wormOverhangPortion = 0 ;
    my $wormOverhangAndMapPortion = 0 ;

    # EXACT OVERLAP NEW
    #
    # viral unmapped ; and schisto totally mapped
    if ( $virus1[1] == 4 && $wormModifycigar =~ /(^\d+)M$/ ) {
	print OUT "EXACT\t" ; 
	$wormOverhangAndMapPortion = $1 ; 
    }
    # viral unmapped ; and schisto map with overhangs
    elsif ( $virus1[1] == 4 && $wormModifycigar =~/(\d+)M(\d+)S$/ ) {
	print OUT "NEW\t";
	$wormOverhangPortion = $2 ; 
	$wormOverhangAndMapPortion = $1 + $2 ;
    }
    else {
    # for the viral with vector ; need to do something to check if the mapped region overlaps

	
	if ( $virusModifycigar =~ /(\d+)M$/ ) {
	    $virusMapPortion = $1 ;
	}
	if ( $wormModifycigar =~ /(\d+)M(\d+)S$/ ) {
                $wormOverhangPortion = $2 ;
                $wormOverhangAndMapPortion = $1 + $2 ;
	}

	#print "$virusMapPortion\t$wormOverhangPortion\n" ; 
	if ( $virusMapPortion < $wormOverhangPortion ) {
	    print OUT "NEW2\t" ; 
	}
	elsif ( ( $wormOverhangAndMapPortion - $virusMapPortion ) >= 30 ) {
	    print OUT "OVERLAP2\t" ; 
	}
	else {
	    # exclude these reads!!
	    #print "ELSE2\t" ; 
	    next ; 
	}

    }




    print OUT "$virus1[0]\t$virusModifycigar\t$wormModifycigar\t$virusMapPortion\t$wormOverhangPortion\t" ;
    print OUT "$virus1[1]\t$virus1[3]\t$virus1[5]\t" ;
    print OUT "$worms1[1]\t$worms1[2]\t$worms1[3]\t$worms1[5]\t$strand\t" ;
    print OUT "$cigarReversed\t$virus1[9]\t" ;
    print OUT "\n" ;


    # which scenario is it?
    my $mapIsOverlap = 0 ; 




    # get overhang sequence in the middle
    if ( $wormModifycigar =~ /(\d+)S$/ ) {
	my $overhanglen = $1 * -1 ; 
	my $fa = substr($virus1[9], $overhanglen ) ; 

	if ( length($fa) >= 10 ) {
	    print OUTFA ">$total\n$fa\n" ; 
	}
    }

    $total++ ; 

}
close(VIRUS) ; 
close(WORMS) ; 

print "\#\# Potentially interesting pairs: $total pairs\n" ; 
print "\#\# not enough evidence on both species (false positive type 2): $notenoughevidence\n" ; 
print "\#\# Five end viral overhang: $fiveendOverhang\n " ; 
print "\#\# Crappy schisto mapping: $crappymapping\n" ; 

print "$bamraw.goodmappings.txt produced\n" ; 
print "$bamraw.3endOverhang.fa produced\n" ; 







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

sub reversecigar {
    my $cigar = shift ;
    my $cigarR = '' ;

    if ( $cigar eq '*' ) {
        return $cigar ;
    }

    while ( $cigar =~ /(\d+\D$)/ ) {
        my $block = $1 ;
        $cigarR .= $block ;
        $cigar =~ s/$block$// ;
    }

    return $cigarR ;
}


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
    #while ( $cigar =~ /(\d+)S(\d+)M/ ) {
    #    my $total = $1 + $2 ;
    #    my $replace = $total . "M" ;
    #    $cigar =~ s/\d+S\d+M/$replace/ ;
    #}

    # sanity checks
    if ( $cigar =~ /^\d+S\d+M\d+S/ || $cigar=~ /^\d+M$/ ) {

    }
    elsif ( $cigar =~ /\d+M\d+S$/ || $cigar =~ /^\d+S\d+M/ ) {
	
    }
    elsif ( $cigar eq '*' ) {

    }
    else {
        print "erm!!! $cigar\n" ;
        exit ;
    }

    return $cigar ;
}
