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


if (@ARGV != 4 ) {
    print "$0 [F]irstor[S]econdRead list out.sorted.markdup.bam.raw.sorted out.sorted.markdup.bam.correspondingreadsfound.sam.sorted  \n" ;
    exit;
}


my $strand = shift ; 
my $list = shift ; 
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


open ( IN, "$list") or die "doapdsoa\n" ; 
while (<IN>) {
    chomp; 
    $reads{$_}++ ; 
}
close(IN) ; 


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

    next unless $reads{$virus1[0]} ; 

    my $needreverse = 0 ; 
    my $virusCigar ; 
    my $wormsCigar ;
    my $seq ;

    if ( $strand eq 'F' ) {
	$virusCigar = $virus1[5]  ;
        $wormsCigar = $worms1[5]  ;

	#print "@virus1\n@worms1\n" ; 

	if ( $virus1[9] ne $worms1[9] ) {
	    $wormsCigar = reversecigar($worms1[5]) ; 
	}
	$seq = $virus1[9] ; 

    }
    else {

        $virusCigar = $virus2[5]  ;
        $wormsCigar = $worms2[5]  ;

        #print "@virus1\n@worms1\n" ;

        if ( $virus2[9] ne $worms2[9] ) {
            $wormsCigar = reversecigar($worms2[5]) ;
        }
        $seq = $virus2[9] ;



    }


    print "$virus1[0]\t$virusCigar\t$wormsCigar\t" ; 


    # find sequence! need to identify the actual motif
    # always get sequence from virus because the cigar in schisto is sometimes reversed
    if ( $virusCigar =~ /^(\d+)M\d+S$/ && $wormsCigar =~ /^(\d+)S\d+M$/ ) {
	my $virusmap = '' ; 
	my $wormsmap = '' ; 
	$virusmap = $1 if  $virusCigar =~/^(\d+)M\d+S$/ ;
	$wormsmap = $1 if $wormsCigar =~ /^(\d+)S\d+M$/ ; 
	
	print  "$virusmap\t$wormsmap\t" ; 

	if ( $virusmap > $wormsmap ) {
	    my $overlap = $virusmap - $wormsmap ; 
	    my $overlapseq = substr($seq, $virusmap-$overlap, $overlap ) ; 
	    print "$overlap\t$overlapseq\n" ; 
	}
	else {
	    print "huh!!!??\n"; 
	}


    }
    elsif ( $virusCigar =~/^\d+S\d+M$/ && $wormsCigar =~ /^\d+M\d+S$/) {
	my $virusmap = '' ;
	my $wormsmap = '' ;
	$virusmap = $1 if  $virusCigar =~/^(\d+)S\d+M$/;
	$wormsmap = $1 if $wormsCigar =~ /^(\d+)M\d+S$/;

	print  "$virusmap\t$wormsmap\t" ;

	if ( $virusmap < $wormsmap ) {
            my $overlap = $wormsmap - $virusmap ;
            my $overlapseq = substr($seq, $virusmap-$overlap, $overlap ) ;
            print "$overlap\t$overlapseq\n" ;
        }
        else {
            print "huh!!!??\n";
        }


    }
    else {
	print "Need curation!!!\n" ; 
    }

#    print "\n\n" ; 




    $total++ ; 

}
close(VIRUS) ; 
close(WORMS) ; 



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
