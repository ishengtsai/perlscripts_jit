#!/usr/bin/perl -w
use strict;



if (@ARGV != 2) {
    print "$0 schisto.sam MLV.sam \n" ; 


	exit ;
}
my $schistofile = shift @ARGV;
my $mlvfile = shift @ARGV ; 
my $phiXfile = shift @ARGV ; 


open (SCHISTO, "$schistofile") or die "oops!\n" ;
open (VIRUS, "$mlvfile") or die "Daosdapda\n" ; 


my $phiXmapped = 0 ; 
my $totalunmapped = 0 ; 
my $solelyvirus = 0 ; 
my $virusPrimerDontknowReverse = 0 ; 
my $hostnotmapped = 0 ; 
my $virusnotmapped = 0 ; 

open OUT, ">", "$schistofile.vs.$mlvfile.exception" or die "daidiadoas\n" ; 
open GOOD, ">", "$schistofile.vs.$mlvfile.good" or die "doapdao\n" ; 
#open SAM, ">", "$schistofile.vs.$mlvfile.sam" or die "doadpaod\n" ; 
#open GOODFA, ">", "$schistofile.vs.$mlvfile.good.144.fasta" or die "daosdpadp\n" ; 

#open GOODFA2, ">", "$schistofile.vs.$mlvfile.good.1158.50S64M36S.F.fasta" or die "daosdpadp\n" ;
#open GOODFA3, ">", "$schistofile.vs.$mlvfile.good.1158.50S64M36S.R.fasta" or die "daosdpadp\n" ;


#open UNMAPF, ">", "$schistofile.vs.$mlvfile.unmapped_F.fasta" or die "daosdpapdaodpsa\n" ; 
#open UNMAPR, ">", "$schistofile.vs.$mlvfile.unmapped_R.fasta" or die "daosdpapdaodpsa\n" ;
#open UNMAPI, ">", "$schistofile.vs.$mlvfile.unmapped_I.fasta" or die "daosdpapdaodpsa\n" ;

while (<SCHISTO>) {
    next if /\#/ ; 

    my @SCHISTO_F = split /\s+/, $_ ; 
    my @VIRUS_F = split /\s+/, <VIRUS> ; 

 


    # do check 
    if ( $SCHISTO_F[0] ne $VIRUS_F[0] ) {
	print "not same pair!\n" ; exit;
    }
    
    if ( $VIRUS_F[1] == 4 && $SCHISTO_F[1] == 4 )  {
	$totalunmapped++ ; 
	next ; 
    }
    if ( $VIRUS_F[1] == 4 ) {
	$virusnotmapped++ ; 
	next ; 
    }
    if ( $SCHISTO_F[1] == 4 ) {
	$solelyvirus++ ; 
	next ; 
    }
    if ( $VIRUS_F[5] =~ /^\d+M$/ ) {
	$solelyvirus++ ;
	next ;
    }


    #print "@SCHISTO_F\n@VIRUS_F\n" ; 

    if ( $VIRUS_F[3] == 144 ) {
	print GOOD "$SCHISTO_F[0]\t" ; 
	print GOOD "$VIRUS_F[1]\t$VIRUS_F[2]\t$VIRUS_F[3]\t$VIRUS_F[4]\t$VIRUS_F[5]\t" ;

	if ( $SCHISTO_F[1] == 16 ) {
	    my $cigar = reversecigar($SCHISTO_F[5]) ; 
	    print GOOD "$SCHISTO_F[1]\t$SCHISTO_F[2]\t$SCHISTO_F[3]\t$SCHISTO_F[4]\t$cigar\n" ; 
	}
	else {
	    print GOOD "$SCHISTO_F[1]\t$SCHISTO_F[2]\t$SCHISTO_F[3]\t$SCHISTO_F[4]\t$SCHISTO_F[5]\n" ; 
	}

   }
    else {
	# qual > 30 to make it high quality mapping ; 
	if ( $SCHISTO_F[3] >= 30 ) {
	    print OUT "$SCHISTO_F[0]\t" ;
	    print OUT "$VIRUS_F[1]\t$VIRUS_F[2]\t$VIRUS_F[3]\t$VIRUS_F[4]\t$VIRUS_F[5]\t" ;
	    print OUT "$SCHISTO_F[1]\t$SCHISTO_F[2]\t$SCHISTO_F[3]\t$SCHISTO_F[4]\t$SCHISTO_F[5]\n" ;
	}
    }


}
close(SCHISTO) ; 

print "phiX mapped pairs: $phiXmapped\n" ; 
print "total unmapped pairs: $totalunmapped\n" ; 
print "total virus pairs: $solelyvirus\n" ; 
print "forward map to virus, reverse map to none: $virusPrimerDontknowReverse\n" ; 
print "host not mapped: $hostnotmapped\n" ; 
print "virus not mapped: $virusnotmapped\n" ; 
print "all done!\n" ; 



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
