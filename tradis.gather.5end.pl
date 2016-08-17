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
    print "$0 HIV.noheader.sam schisto.noheader.sam\n" ; 
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

open( VIRUS, "$bamraw") or die "doapdopsa\n" ; 
open( WORMS, "$bam") or die "doapdooa\n" ; 

open OUTINDEPENDENT, ">", "$bamraw.independentMapping" or die "daiidaodi\n" ; 


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
    next if $worms1[1] >= 1000 ; 
    next if $worms2[1] >= 1000 ; 

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
	print "HIV1: @virus1\nHIV2: @virus2\nWorm1: @worms1\nWorm2: @worms2\n" ;

	exit ;
    }


    my $virus1cigar = modifycigar($virus1[5]) ;
    my $virus2cigar = modifycigar($virus2[5]) ;
    my $worm1cigar = modifycigar($worms1[5]) ;
    my $worm2cigar = modifycigar($worms2[5]) ;
    my $map1worm = cigarmap($worms1[5]) ;
    my $map2worm = cigarmap($worms2[5]) ;
    my $map1virus = cigarmap($virus1[5]) ;
    my $map2virus = cigarmap($virus2[5]) ;

    
    #mapping quality!!!
    if ( $worms2[4] < 30 ) {
        next ;
    }


    # Sanity check
    # Exclude schisto totally unmapped in both reads
    if ( $worms1[1] == 77 ) {
	    next ; 
    } 
    # Second read has to map schisto at last more than 30bp
    if ( $map2worm < 30  ) {
	    $notenoughevidence++ ;
	    next ; 
    }

    # Since the reads are clipped , it's okay to have both reads are wholly schisto
    if ( $worms1[1] == 99 || $worms1[1] == 83 ) {

	if ( $virus1[2] eq '*' ) {
	    #print "here!\n" ; 
	    #print "HIV1: @virus1\nHIV2: @virus2\nWorm1: @worms1\nWorm2: @worms2\n\n\n" ;
	    
	    
	    my $strand = '+' ;
	    if ( $worms1[1] & 16 ) {
		$strand = '-' ;
	    }
	    
	    if ( $worm2cigar =~ /\d+M(\d+)S$/ ) {
		next if $1 >= 10 ; 
	    }

	    if ( $worm1cigar =~ /^\d+M$/ ) {
		print "EXACT\t" ;
		print "TOTALSCHISTO\t$virus1[0]\t$virus1cigar\t$virus2cigar\t$worm1cigar\t$worm2cigar\t" ;
		print "$virus1[1]\t$virus1[3]\t$virus1[5]\t$virus2[1]\t$virus2[3]\t$virus2[5]\t" ;
		print "$worms1[1]\t$worms1[2]\t$worms1[3]\t$worms1[5]\t" ;
		print "$worms2[1]\t$worms2[2]\t$worms2[3]\t$worms2[5]\t$strand\n" ;
		next ; 
	    }
	    elsif ( $worm1cigar =~ /^\d+M\d+S/ ) {
                print "NEW\t" ;
		print "TOTALSCHISTO\t$virus1[0]\t$virus1cigar\t$virus2cigar\t$worm1cigar\t$worm2cigar\t" ;
                print "$virus1[1]\t$virus1[3]\t$virus1[5]\t$virus2[1]\t$virus2[3]\t$virus2[5]\t" ;
		print "$worms1[1]\t$worms1[2]\t$worms1[3]\t$worms1[5]\t" ;
                print "$worms2[1]\t$worms2[2]\t$worms2[3]\t$worms2[5]\t$strand\n" ;
		next ; 
	    }
	    else {
		#print "hmmmmmmm!\n" ; 
		next ; 
	    }

	}
    }


   
    # only first read mapped to virus ; so second read should be solely schisto or schisto with overhangs...
    if ( $virus1[1] == 89 ) {

	# reverse the cigar
	if ( $virus1[9] ne $worms1[9] ) {
	    $worm1cigar = reversecigar($worm1cigar) ;
	    $worm2cigar = reversecigar($worm2cigar) ;
	}

	my $strand = '+' ; 
	if ( $worms2[1] & 16 ) {
	    $strand = '-' ; 
	}

	# one filter... ignore overhangs with schisto
	if ( $virus1cigar =~ /^\d+S\d+M$/ && $worm1cigar =~ /\d+M/ ) {

	    # overhang in second read??
	    if ( $worm2cigar =~ /\d+M\d+S/ ) {
                #print "$virus1cigar\t$virus2cigar\t$worm1cigar\t$worm2cigar\n" ;
		#print "HIV1: @virus1\nHIV2: @virus2\nWorm1: @worms1\nWorm2: @worms2\n\n\n" ;
		next ; 
	    }
	    else {
		# filter passed!
	    }

	}

	if ( $virus1cigar =~ /(\d+)M(\d+)S$/ ) {
	    if ( $2 < 10 ) {
		my $tmp = "$1M" ; 
		$virus1cigar = $tmp ; 
	    }
	    else {
		next ; 
	    }
	}


	# Read 1 has both schisto and virus ; need to determine the nature
	#
	if ( $virus1cigar =~ /^\d+S\d+M$/ && $worm1cigar =~ /\d+M/ ) {


	    #print "$virus1cigar\t$virus2cigar\t$worm1cigar\t$worm2cigar\n" ;
	    #print "HIV1: @virus1\nHIV2: @virus2\nWorm1: @worms1\nWorm2: @worms2\n\n\n" ;

	    
            # another filter for overlapping mappings
	    my $virusMapPortion = 0 ;
	    my $wormOverhangPortion = 0 ;
	    my $wormOverhangAndMapPortion = 0 ;

	    # need to check here!!!!
	    if ( $virus1cigar =~ /(\d+)M/ ) {
		$virusMapPortion = $1 ;
	    }

	    if ( $worm1cigar =~ /^(\d+)M(\d+)S/ ) {
		$wormOverhangPortion = $2 ;
		$wormOverhangAndMapPortion = $1 + $2 ;

		#print "HIV1: @virus1\nHIV2: @virus2\nWorm1: @worms1\nWorm2: @worms2\n\n" ;
                #print "HERE1\t$virus1[0]\t$virus1cigar\t$virus2cigar\t$worm1cigar\t$worm2cigar\n\n\n" ;

		# still integration but less evidence
		if ( $worm2cigar =~ /\d+M\d+S$/ ) {

		    print OUTINDEPENDENT "INDEPENDENT_TRUE2\t$virus1[0]\t$virus1cigar\t$worm2cigar\t" ;
		    print OUTINDEPENDENT "$virus1[1]\t$virus1[3]\t$virus1[5]\t$worms2[1]\t$worms2[2]\t$worms2[3]\t$worms2[5]\t$strand\n" ;

		}
		elsif ( $virusMapPortion > $wormOverhangPortion ) {
		    print "OVERLAP\t" ;
		    print "1stVIRALPART1\t$virus1[0]\t$virus1cigar\t$virus2cigar\t$worm1cigar\t$worm2cigar\t" ;
		    print "$virus1[1]\t$virus1[3]\t$virus1[5]\t$virus2[1]\t$virus2[3]\t$virus2[5]\t" ;
		    print "$worms1[1]\t$worms1[2]\t$worms1[3]\t$worms1[5]\t" ;
		    print "$worms2[1]\t$worms2[2]\t$worms2[3]\t$worms2[5]\t$strand\n" ;


		    next ;
		}
		elsif ( $virusMapPortion == $wormOverhangPortion ) {
		    print "EXACT\t" ;
		    print "1stVIRALPART1\t$virus1[0]\t$virus1cigar\t$virus2cigar\t$worm1cigar\t$worm2cigar\t" ;
		    print "$virus1[1]\t$virus1[3]\t$virus1[5]\t$virus2[1]\t$virus2[3]\t$virus2[5]\t" ;
		    print "$worms1[1]\t$worms1[2]\t$worms1[3]\t$worms1[5]\t" ;
		    print "$worms2[1]\t$worms2[2]\t$worms2[3]\t$worms2[5]\t$strand\n" ;
		    next ;
		}
		else {
		    print "NEW\t" ;
		    print "1stVIRALPART1\t$virus1[0]\t$virus1cigar\t$virus2cigar\t$worm1cigar\t$worm2cigar\t" ;
		    print "$virus1[1]\t$virus1[3]\t$virus1[5]\t$virus2[1]\t$virus2[3]\t$virus2[5]\t" ;
		    print "$worms1[1]\t$worms1[2]\t$worms1[3]\t$worms1[5]\t" ;
		    print "$worms2[1]\t$worms2[2]\t$worms2[3]\t$worms2[5]\t$strand\n" ;
		    next  ;
		}


	    }
	    elsif ( $worm1cigar =~ /^(\d+)M$/ ) {
		# should be overlap instead ; but nothing here
		print " oh yeah!\n" ; 
		exit ; 
	    }
	    else {
		# looks like there is always evidence in second read...
		# Since first read combination is weird, we will regard them as independent true
		print OUTINDEPENDENT "INDEPENDENT_TRUE4\t$virus1[0]\t$virus1cigar\t$worm2cigar\t" ;
		print OUTINDEPENDENT "$virus1[1]\t$virus1[3]\t$virus1[5]\t$worms2[1]\t$worms2[2]\t$worms2[3]\t$worms2[5]\t$strand\n" ;

		next ;
	    }






	}
	# partial mapping in first viral read but still no mapping in schisto first read ; regard as independent
	# checked for 5end
	elsif ( $virus1cigar =~ /^\d+S\d+M$/ && $worm1cigar eq '*'  ) {


	    if ( $strand eq '+' && $worm2cigar =~ /\d+S/ ) {
		print OUTINDEPENDENT "INDEPENDENT_EVID1\t$virus1[0]\t$virus1cigar\t$worm2cigar\t" ;
		print OUTINDEPENDENT "$virus1[1]\t$virus1[3]\t$virus1[5]\t$worms2[1]\t$worms2[2]\t$worms2[3]\t$worms2[5]\t$strand\n" ;
	    }
	    elsif ( $strand eq '-' && $worm2cigar =~/^\d+S/) {
                print OUTINDEPENDENT "INDEPENDENT_EVID1\t$virus1[0]\t$virus1cigar\t$worm2cigar\t" ;
                print OUTINDEPENDENT "$virus1[1]\t$virus1[3]\t$virus1[5]\t$worms2[1]\t$worms2[2]\t$worms2[3]\t$worms2[5]\t$strand\n" ;
            }
	    else {
                print OUTINDEPENDENT "INDEPENDENT_TRUE1\t$virus1[0]\t$virus1cigar\t$worm2cigar\t" ;
                print OUTINDEPENDENT "$virus1[1]\t$virus1[3]\t$virus1[5]\t$worms2[1]\t$worms2[2]\t$worms2[3]\t$worms2[5]\t$strand\n" ;
	    }


	}
	# checked for 5 end
	elsif ( $virus1cigar =~ /^\d+M$/ ) {

	    if ( $strand eq '+' && $worm2cigar =~/\d+S$/) {
                print OUTINDEPENDENT "INDEPENDENT_EVID2\t$virus1[0]\t$virus1cigar\t$worm2cigar\t" ;
                print OUTINDEPENDENT "$virus1[1]\t$virus1[3]\t$virus1[5]\t$worms2[1]\t$worms2[2]\t$worms2[3]\t$worms2[5]\t$strand\n" ;
            }
	    elsif ( $strand eq '-' && $worm2cigar =~/^\d+S/) {
                print OUTINDEPENDENT "INDEPENDENT_EVID2\t$virus1[0]\t$virus1cigar\t$worm2cigar\t" ;
                print OUTINDEPENDENT "$virus1[1]\t$virus1[3]\t$virus1[5]\t$worms2[1]\t$worms2[2]\t$worms2[3]\t$worms2[5]\t$strand\n" ;
            }
	    elsif ( $worm2cigar =~ /^\d+M$/ ) {
		print OUTINDEPENDENT "INDEPENDENT_TRUE10\t$virus1[0]\t$virus1cigar\t$worm2cigar\t" ;
                print OUTINDEPENDENT "$virus1[1]\t$virus1[3]\t$virus1[5]\t$worms2[1]\t$worms2[2]\t$worms2[3]\t$worms2[5]\t$strand\n" ;
	    }
            else {
                print OUTINDEPENDENT "INDEPENDENT_TRUE9\t$virus1[0]\t$virus1cigar\t$worm2cigar\t" ;
		print OUTINDEPENDENT "$virus1[1]\t$virus1[3]\t$virus1[5]\t$worms2[1]\t$worms2[2]\t$worms2[3]\t$worms2[5]\t$strand\n" ;
            }
	}
	else {
	    print "weird!!! exit...\n" ; 
	    print "HIV1: @virus1\nHIV2: @virus2\nWorm1: @worms1\nWorm2: @worms2\n\n\n" ;
	    exit ; 

	}

	#$total++ ; 
	next ; 
    }



    # filter here ; the read has to be continuous
    if ( $virus1cigar =~ /^\d+S\d+M/ ) {
	next ; 
    }
    if ( $virus1cigar =~ /^\d+M$/ && $virus2cigar =~ /^\d+M$/ ) {
	next ; 
    }

    unless ( $virus2cigar =~ /\d+M$/ ) {
	next ; 
    }
    
    if ( $virus2cigar =~ /(\d+)S\d+M$/ ) {
	next if $1 < 30 ; 
    }



    
    # first read mapped and second read partially mapped to virus too

    my $strand = '+' ;
    if ( $virus2[9] ne $worms2[9] ) {
	$worm2cigar = reversecigar($worm2cigar) ; 
	$strand = '-' ; 
    }
    

    # another filter for overlapping mappings
    my $virusMapPortion = 0 ;
    my $wormOverhangPortion = 0 ;
    my $wormOverhangAndMapPortion = 0 ;

    if ( $virus2cigar =~ /(\d+)M$/ ) {
	$virusMapPortion = $1 ;
    }


    if ( $worm2cigar =~ /(\d+)M(\d+)S$/ ) {
	$wormOverhangPortion = $2 ;
	$wormOverhangAndMapPortion = $1 + $2 ;
    }
    elsif ( $worm2cigar =~ /^(\d+)M$/ ) {
	# it's wrong here
	print "actually independent!!\n" ; 
	next ; 
    }
    else {

	print "HIV1: @virus1\nHIV2: @virus2\nWorm1: @worms1\nWorm2: @worms2\n\n" ;
	print "HERE2\t$virus1[0]\t$virus1cigar\t$virus2cigar\t$worm1cigar\t$worm2cigar\n\n\n" ;
	print "wierd at 2ndVIRALPART1!!! \n" ;
	exit ;
    }


    # filter!
    if ( ( $wormOverhangAndMapPortion - $virusMapPortion ) < 30 ) {
	next ;
    }
    
    
    if ( $virusMapPortion > $wormOverhangPortion ) {
	#$mapIsOverlap++ ;
	print "OVERLAP\t" ;
	print "2ndVIRALPART1\t$virus1[0]\t$virus1cigar\t$virus2cigar\t$worm1cigar\t$worm2cigar\t" ;
	print "$virus1[1]\t$virus1[3]\t$virus1[5]\t$virus2[1]\t$virus2[3]\t$virus2[5]\t" ;
	print "$worms1[1]\t$worms1[2]\t$worms1[3]\t$worms1[5]\t" ;
	print "$worms2[1]\t$worms2[2]\t$worms2[3]\t$worms2[5]\t$strand\n" ;


	next ; 
    }
    elsif ( $virusMapPortion == $wormOverhangPortion ) {
	print "EXACT\t" ;
	print "2ndVIRALPART1\t$virus1[0]\t$virus1cigar\t$virus2cigar\t$worm1cigar\t$worm2cigar\t" ;
	print "$virus1[1]\t$virus1[3]\t$virus1[5]\t$virus2[1]\t$virus2[3]\t$virus2[5]\t" ;
        print "$worms1[1]\t$worms1[2]\t$worms1[3]\t$worms1[5]\t" ;
	print "$worms2[1]\t$worms2[2]\t$worms2[3]\t$worms2[5]\t$strand\n" ; 
	next ; 
    }
    else {
	print "NEW\t" ;
	print "2ndVIRALPART1\t$virus1[0]\t$virus1cigar\t$virus2cigar\t$worm1cigar\t$worm2cigar\t" ;
	print "$virus1[1]\t$virus1[3]\t$virus1[5]\t$virus2[1]\t$virus2[3]\t$virus2[5]\t" ;
        print "$worms1[1]\t$worms1[2]\t$worms1[3]\t$worms1[5]\t" ;
	print "$worms2[1]\t$worms2[2]\t$worms2[3]\t$worms2[5]\t$strand\n" ;
	next  ;
    }
    
    
    

    print "\n\nWEIRD here!\n" ;
    print "HIV1: @virus1\nHIV2: @virus2\nWorm1: @worms1\nWorm2: @worms2\n\n" ;
    print "HMMM2\t$virus1[0]\t$virus1cigar\t$virus2cigar\t$worm1cigar\t$worm2cigar\n\n\n" ;
    exit ; 


    #print "COMPLEX\t$virus2[0]\t$virus1cigar\t$virus2cigar\t$worm1cigar\t$worm2cigar\n" ;
    #print "$virus1[1]\t$virus1[3]\t$virus1[5]\n" ;
    #print "$virus2[1]\t$virus2[3]\t$virus2[5]\n" ;
    #print "$worms1[1]\t$worms1[2]\t$worms1[3]\t$worms1[5]\n" ;
    #print "$worms2[1]\t$worms2[2]\t$worms2[3]\t$worms2[5]\n" ;
    #print "$virus1[9]\n" ; 
    #print "$virus2[9]\n" ;
    #print "$worms1[9]\n" ; 
    #print "$worms2[9]\n" ; 
    #print "\n\n" ; 

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

