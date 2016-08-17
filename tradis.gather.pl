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
    print "$0 HIV.noheader.sam schisto.noheader.sam\n" ; 
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

    #print "HIV1: @virus1\nHIV2: @virus2\nWorm1: @worms1\nWorm2: @worms2\n" ; 



    

    if ( $map2worm < 30  ) {
	    $notenoughevidence++ ;
	    next ; 
    }

    #mapping quality!!!
    if ( $worms2[4] < 30 ) {
	next ; 
    }

    
    # Since the reads are clipped , it's okay to have both reads are wholly schisto
    if ( $worms1[1] == 99 || $worms1[1] == 83 ) {


	if ( $virus1[2] eq '*' ) {


            my $strand = '+' ;
            if ( $worms1[1] & 16 ) {
		$strand = '-' ;
            }

            if ( $worm2cigar =~ /^(\d+)S(\d+)M/ ) {
                next if $1 >= 10 ;
            }

	#    print "here!\n" ;
        #    print "HIV1: @virus1\nHIV2: @virus2\nWorm1: @worms1\nWorm2: @worms2\n\n\n" ;


            if ( $worm1cigar =~ /^\d+M$/ ) {
                print "EXACT\t" ;
                print "TOTALSCHISTO\t$virus1[0]\t$virus1cigar\t$virus2cigar\t$worm1cigar\t$worm2cigar\t" ;
                print "$virus1[1]\t$virus1[3]\t$virus1[5]\t$virus2[1]\t$virus2[3]\t$virus2[5]\t" ;
                print "$worms1[1]\t$worms1[2]\t$worms1[3]\t$worms1[5]\t" ;
                print "$worms2[1]\t$worms2[2]\t$worms2[3]\t$worms2[5]\t$strand\n" ;
                next ;
            }
            elsif ( $worm1cigar =~ /^\d+S\d+M/ ) {

		if (  $virus2cigar ne '*' ) {
		    print "TRUE\t" ;
		    print "TRUE\t$virus1[0]\t$virus1cigar\t$virus2cigar\t$worm1cigar\t$worm2cigar\t" ;
		    print "$virus1[1]\t$virus1[3]\t$virus1[5]\t$virus2[1]\t$virus2[3]\t$virus2[5]\t" ;
		    print "$worms1[1]\t$worms1[2]\t$worms1[3]\t$worms1[5]\t" ;
		    print "$worms2[1]\t$worms2[2]\t$worms2[3]\t$worms2[5]\t$strand\n" ;

		}
		else {
		    print "NEW\t" ;
		    print "TOTALSCHISTO\t$virus1[0]\t$virus1cigar\t$virus2cigar\t$worm1cigar\t$worm2cigar\t" ;
		    print "$virus1[1]\t$virus1[3]\t$virus1[5]\t$virus2[1]\t$virus2[3]\t$virus2[5]\t" ;
		    print "$worms1[1]\t$worms1[2]\t$worms1[3]\t$worms1[5]\t" ;
		    print "$worms2[1]\t$worms2[2]\t$worms2[3]\t$worms2[5]\t$strand\n" ;
		    next ;
		}
            }
            else {
                #print "hmmmmmmm!\n" ;
                next ;
            }

        }

    }




    # filter of first read mapping
    if ( $virus1[3] > 535 && $virus1[3] < 735 ) {

    }
    elsif ( $virus1[3] > 9610 && $virus1[3] < 9810 ) {

    }
    else {
        next ;
    }

    # Sanity check
    unless ( $virus1cigar =~ /^\d+M/ ) {
        next ;
    }

    if ( $virus1cigar =~ /^\d+M\d+S/ ) {
        unless ( $virus2cigar eq '*' ) {
            next ;
	}
    }
    if ( $virus1cigar =~ /^\d+M$/ && $virus2cigar =~ /^\d+S\d+M/ ) {
        next ;
    }
    if ( $virus1cigar =~ /^\d+M$/ && $virus2cigar =~ /^\d+M$/ ) {
        next ;
    }

   
    # only first read mapped
    if ( $virus1[1] == 73 ) {

	my $strand = '+' ; 
	if ( $worms2[1] & 16 ) {
	    $strand = '-' ; 
	}


	if ( $virus1cigar =~ /^\d+M\d+S$/ && $worm1cigar =~ /\d+M/ ) {

	    # reverse the cigar
	    if ( $virus1[9] ne $worms1[9] ) {
		$worm1cigar = reversecigar($worm1cigar) ; 
	    }

	    # a filter..
	    if ( $worm1cigar =~ /^\d+S\d+M/ && $worm2cigar =~ /^\d+S/ ) {
		next ; 
	    }
	    
            # another filter for overlapping mappings
	    my $virusMapPortion = 0 ;
	    my $wormOverhangPortion = 0 ;
	    my $wormOverhangAndMapPortion = 0 ;
	    if ( $virus2cigar =~ /^(\d+)M/ ) {
		$virusMapPortion = $1 ;
	    }

	    if ( $worm2cigar =~ /^(\d+)S(\d+)M/ ) {
		# actually no reads were found here ; so we skip this part and comment out the code below
		$wormOverhangPortion = $1 ;
		$wormOverhangAndMapPortion = $1 + $2 ;
	    }
	    elsif ( $worm2cigar =~ /^(\d+)M/ ) {
		# should be independent instead

                print OUTINDEPENDENT "INDEPENDENT_TRUE\t$virus1[0]\t$virus1cigar\t$worm2cigar\t" ;
                print OUTINDEPENDENT "$virus1[1]\t$virus1[3]\t$virus1[5]\t$worms2[1]\t$worms2[2]\t$worms2[3]\t$worms2[5]\t$strand\n" ;		
	    }
	    else {
		print "wierd at 1stVIRALPART !!! \n" ;
		exit ;
	    }

	    # filter!
	    if ( ( $wormOverhangAndMapPortion - $virusMapPortion ) < 30 ) {
		next ;
	    }

	    
#	    if ( $virusMapPortion > $wormOverhangPortion ) {
#		print "OVERLAP\t" ;
#	    }
#	    elsif ( $virusMapPortion == $wormOverhangPortion ) {
#		print "EXACT\t" ;
#	    }
#	    else {
#		print "NEW\t" ;
#	    }
#	    print "1stVIRALPART\t$virus1[0]\t$virus1cigar\t$worm1cigar\t$worm2cigar\t" ;
#	    print "$virus1[1]\t$virus1[3]\t$virus1[5]\t$virus2[1]\t$virus2[3]\t$virus2[5]\t$worms1[1]\t$worms1[2]\t$worms1[3]\t$worms1[5]\t$worms2[1]\t$worms2[2]\t$worms2[3]\t$worms2[5]\n" ;


	  # these turn out to be false positives 
	  # Only 
	  #NEW 1stVIRALPART MS7_14076:1:1101:17722:2479824M89S77M36S19S131M7363524M89S1330*65Schisto_mansoni.Chr_5127288177M36S129Schisto_mansoni.Chr_ZW2232515919S131M



	}
	# partial mapping in first viral read but still no mapping in schisto first read ; regard as independent
	elsif ( $virus1cigar =~ /^\d+M\d+S$/ && $worm1cigar eq '*'  ) {


	    if ( $worm2cigar =~ /^\d+S/ ) {
		print OUTINDEPENDENT "INDEPENDENT_EVID\t$virus1[0]\t$virus1cigar\t$worm2cigar\t" ;
		print OUTINDEPENDENT "$virus1[1]\t$virus1[3]\t$virus1[5]\t$worms2[1]\t$worms2[2]\t$worms2[3]\t$worms2[5]\t$strand\n" ;
	    }
	    else {
                print OUTINDEPENDENT "INDEPENDENT_TRUE\t$virus1[0]\t$virus1cigar\t$worm2cigar\t" ;
                print OUTINDEPENDENT "$virus1[1]\t$virus1[3]\t$virus1[5]\t$worms2[1]\t$worms2[2]\t$worms2[3]\t$worms2[5]\t$strand\n" ;
	    }

	    next ; 
	}
	elsif ( $virus1cigar =~ /^\d+M$/ ) {

	    if ( $worm2cigar =~/^\d+S/) {
                print OUTINDEPENDENT "INDEPENDENT_EVID\t$virus1[0]\t$virus1cigar\t$worm2cigar\t" ;
                print OUTINDEPENDENT "$virus1[1]\t$virus1[3]\t$virus1[5]\t$worms2[1]\t$worms2[2]\t$worms2[3]\t$worms2[5]\t$strand\n" ;
            }
            else {
                print OUTINDEPENDENT "INDEPENDENT_TRUE\t$virus1[0]\t$virus1cigar\t$worm2cigar\t" ;
		print OUTINDEPENDENT "$virus1[1]\t$virus1[3]\t$virus1[5]\t$worms2[1]\t$worms2[2]\t$worms2[3]\t$worms2[5]\t$strand\n" ;
            }

	    next ; 
	}
	else {
	    print "weird!!! exit...\n" ; 
	    exit ; 

	}

	# 10 cases here ; both reads map to virus and overhang in the middle
	#print "heh?\t$virus1[0]\t$virus1cigar\t$worm2cigar\t" ;
	#print "$virus1[1]\t$virus1[3]\t$virus1[5]\t$worms2[1]\t$worms2[2]\t$worms2[3]\t$worms2[5]\t$strand\n" ;
	#print "something not caught!!!\n" ; 
	#exit ; 
	next ; 
    }
    
    # first read mapped and second read partially mapped to virus too
    if ( $virus1[1] == 99 && $virus1[5] =~ /^\d+M$/ ) {

	my $strand = '+' ;
	if ( $virus2[9] ne $worms2[9] ) {
	    $worm2cigar = reversecigar($worm2cigar) ; 
	    $strand = '-' ; 
	}

	# another filter for overlapping mappings
	my $virusMapPortion = 0 ;
	my $wormOverhangPortion = 0 ;
	my $wormOverhangAndMapPortion = 0 ;
	if ( $virus2cigar =~ /^(\d+)M/ ) {
	    $virusMapPortion = $1 ;
	}
	if ( $worm2cigar =~ /^(\d+)S(\d+)M/ ) {
	    $wormOverhangPortion = $1 ;
	    $wormOverhangAndMapPortion = $1 + $2 ;
	}
	elsif ( $worm2cigar =~ /^(\d+)M/ ) {
	    # it's wrong here
	    next ; 
	}
	else {
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
	}
	elsif ( $virusMapPortion == $wormOverhangPortion ) {
	    print "EXACT\t" ;
	}
	else {
	    print "NEW\t" ;
	}


	print "2ndVIRALPART1\t$virus1[0]\t$virus1cigar\t$virus2cigar\t$worm2cigar\t" ; 
	print "$virus1[1]\t$virus1[3]\t$virus1[5]\t$virus2[1]\t$virus2[3]\t$virus2[5]\t$worms2[1]\t$worms2[2]\t$worms2[3]\t$worms2[5]\t$strand\n" ; 

	#$total++ ; 
	next ; 
    }


    if ( $virus1cigar =~ /^\d+M$/ && $virus2cigar =~ /^\d+M(\d+)S/ ) {
	next if $1 < 30;
    }

    if ( $virus1[1] == 97 && $virus2[1] == 145 ) {

	#filter
	unless ( $virus1cigar =~ /^\d+M$/ ) {
	    next ; 
	}

	my $strand = '+' ;
	if ( $virus2[9] ne $worms2[9] ) {
	    $worm2cigar = reversecigar($worm2cigar) ; 
	    $strand = '-' ; 
	}
	

        # another filter for overlapping mappings
        my $virusMapPortion = 0 ;
        my $wormOverhangPortion = 0 ;
        my $wormOverhangAndMapPortion = 0 ;
        if ( $virus2cigar =~ /^(\d+)M/ ) {
            $virusMapPortion = $1 ;
        }
        if ( $worm2cigar =~ /^(\d+)S(\d+)M/ ) {
            $wormOverhangPortion = $1 ;
            $wormOverhangAndMapPortion = $1 + $2 ;
        }
        elsif ( $worm2cigar =~ /^(\d+)M/ ) {
            # it's wrong here
            next ;
        }
        else {
            print "wierd at 2ndVIRALPART2!!! \n" ;
            exit ;
        }

        # filter!
        if ( ( $wormOverhangAndMapPortion - $virusMapPortion ) < 30 ) {
            next ;
        }


        if ( $virusMapPortion > $wormOverhangPortion ) {
            #$mapIsOverlap++ ;
            print "OVERLAP\t" ;
        }
        elsif ( $virusMapPortion == $wormOverhangPortion ) {
            print "EXACT\t" ;
        }
        else {
            print "NEW\t" ;
        }


        print "2ndVIRALPART2\t$virus1[0]\t$virus1cigar\t$virus2cigar\t$worm2cigar\t" ;
        print "$virus1[1]\t$virus1[3]\t$virus1[5]\t$virus2[1]\t$virus2[3]\t$virus2[5]\t$worms2[1]\t$worms2[2]\t$worms2[3]\t$worms2[5]\t$strand\n" ;
	next ; 
	    

    }



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

print "\#\# Still uncategorised pairs: $total pairs\n" ; 
print "\#\# not enough evidence on both species (false positive type 2): $notenoughevidence\n" ; 


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

