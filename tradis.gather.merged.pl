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

open OUTFA2, ">", "$bamraw.5endOverhang.fa" or die "doadpaopd\n" ;

my $count = 0 ; 

while (<VIRUS>) {

    $count++ ; 
    
    chomp ;
    my $read1 = $_ ; 
    my @virus1 = split /\s+/, $read1 ;

    $read1 = <WORMS> ; chomp($read1) ; 
    my @worms1 = split /\s+/, $read1 ;

    my $readlen = length($virus1[9]) ; 

    # remove PCR duplicate
    next if $worms1[1] >= 1000 ; 

    if ( $virus1[5] =~ /^\d+S\d+M/ ) {
	$fiveendOverhang++ ; 
	next ; 
    }
    if ( $worms1[0] ne $virus1[0] ) {
	print "weird!!!! virus and worm pair not the same!\n"  ; 
	print "HIV1: @virus1\nWorm1: @worms1\n" ;

	exit ;
    }

    my $map1worm = cigarmap($worms1[5]) ; 
    my $map1virus = cigarmap($virus1[5]) ;



    # not enought evidence
    if ( $map1worm <= 30  ) {
	$notenoughevidence++ ; 
	next ; 
    }
    if ( $virus1[5] =~ /^\d+M$/ ) {
        $notenoughevidence++ ;
        next ;
    }
    #if ( $worms1[5] =~ /^\d+M$/ ) {
    #    $notenoughevidence++ ;
    #    next ;
    #}
    if ( ( $readlen - $map1virus ) < 30 ) {
	$notenoughevidence++ ;
        next ;
    }
    
    #mapping quality!!!
    if ( $worms1[4] < 30 ) {
        next ;
    }






    # modify cigar strings to get a bit clearer mapping
    my $wormModifycigar = modifycigar($worms1[5]) ;
    my $virusModifycigar = modifycigar($virus1[5]) ;

    #reverse
    my $cigarReversed = 0 ; 
    my $strand = '+' ; 
    if ( $worms1[9] ne $virus1[9] ) {
	$wormModifycigar = reversecigar($wormModifycigar) ; 
	$strand = '-' ; 
	$cigarReversed++ ; 
    }


    # here for completely overlap
    if ( $virus1[1] == 4 ) {

	if ( $wormModifycigar =~ /^\d+M/ ) {
	    print OUT "EXACT2\t" ; 
	}
	else {
	    print OUT "NEW\t" ; 

	    if (  $wormModifycigar =~ /^(\d+)S/ ) {
		my $tmplen = $1 ; 
		if ( $tmplen > 20 ) {
		    my $tmpseq = substr($virus1[9], 0, $tmplen ) ; 
		    print OUTFA2 ">$count\n$tmpseq\n" ; 
		}
	    }

	}

	print OUT "$virus1[0]\t$virusModifycigar\t$wormModifycigar\tNA\tNA\t" ;
	print OUT "$virus1[1]\t$virus1[3]\t$virus1[5]\t" ;
	print OUT "$worms1[1]\t$worms1[2]\t$worms1[3]\t$worms1[5]\t$strand\t" ;
	print OUT "$cigarReversed\t$virus1[9]\t" ;
	print OUT "\n" ;

	next ; 
    }


    # another filter for overlapping mappings
    my $virusMapPortion = 0 ; 
    my $wormOverhangPortion = 0 ; 
    my $wormOverhangAndMapPortion = 0 ; 
    if ( $virusModifycigar =~ /^(\d+)M/ ) {
	$virusMapPortion = $1 ; 
    }
    
    if ( $wormModifycigar =~ /^(\d+)S(\d+)M/ ) {
	$wormOverhangPortion = $1 ; 
	$wormOverhangAndMapPortion = $1 + $2 ; 
    }
    else {
	print "wierd!!! \n" ; 
	exit ; 
    }

    if ( ( $wormOverhangAndMapPortion - $virusMapPortion ) < 30 ) {
	$crappymapping++ ; 
	#print "CRAPPY:\t" ; 
	next ; 
    }
    

    # following should be excluded
    next if $virus1[3] == 8040 ;
    next if $virus1[3] == 9383 ; 
    next if $virus1[3] == 2520 ;
    next if $virus1[3] == 3021 ;

    # which scenario is it?
    my $mapIsOverlap = 0 ; 

    if ( $virusMapPortion > $wormOverhangPortion ) {
	$mapIsOverlap++ ; 
	print OUT "OVERLAP\t" ; 
    }
    elsif ( $virusMapPortion == $wormOverhangPortion ) {
	print OUT "EXACT\t" ; 
    }
    else {
	print OUT "NEW\t" ;
    }



    print OUT "$virus1[0]\t$virusModifycigar\t$wormModifycigar\t$virusMapPortion\t$wormOverhangPortion\t" ; 
    print OUT "$virus1[1]\t$virus1[3]\t$virus1[5]\t" ;
    print OUT "$worms1[1]\t$worms1[2]\t$worms1[3]\t$worms1[5]\t$strand\t" ;
    print OUT "$cigarReversed\t$virus1[9]\t" ; 	
    print OUT "\n" ; 







    # get overhang sequence
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
