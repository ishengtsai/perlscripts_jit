#!/usr/bin/perl -w
use strict;



if (@ARGV != 3) {
    print "$0 schisto.sam MLV.sam phiX.sam \n" ; 


	exit ;
}
my $schistofile = shift @ARGV;
my $mlvfile = shift @ARGV ; 
my $phiXfile = shift @ARGV ; 


open (SCHISTO, "$schistofile") or die "oops!\n" ;
open (VIRUS, "$mlvfile") or die "Daosdapda\n" ; 
open (PHIX, "$phiXfile") or die "odapodapod\n" ; 

my $phiXmapped = 0 ; 
my $totalunmapped = 0 ; 
my $solelyvirus = 0 ; 
my $virusPrimerDontknowReverse = 0 ; 
my $hostnotmapped = 0 ; 
my $virusnotmapped = 0 ; 

open OUT, ">", "$schistofile.vs.$mlvfile.exception" or die "daidiadoas\n" ; 
open GOOD, ">", "$schistofile.vs.$mlvfile.good" or die "doapdao\n" ; 
open SAM, ">", "$schistofile.vs.$mlvfile.sam" or die "doadpaod\n" ; 
open GOODFA, ">", "$schistofile.vs.$mlvfile.good.568.fasta" or die "daosdpadp\n" ; 
open GOODFA2, ">", "$schistofile.vs.$mlvfile.good.568.67M.fasta" or die "daosdpadp\n" ;

open UNMAPF, ">", "$schistofile.vs.$mlvfile.unmapped_F.fasta" or die "daosdpapdaodpsa\n" ; 
open UNMAPR, ">", "$schistofile.vs.$mlvfile.unmapped_R.fasta" or die "daosdpapdaodpsa\n" ;
open UNMAPI, ">", "$schistofile.vs.$mlvfile.unmapped_I.fasta" or die "daosdpapdaodpsa\n" ;

while (<SCHISTO>) {
    next if /\#/ ; 

    my @SCHISTO_F = split /\s+/, $_ ; 
    my @SCHISTO_R = split /\s+/, <SCHISTO> ;
    my @VIRUS_F = split /\s+/, <VIRUS> ; 
    my @VIRUS_R = split /\s+/, <VIRUS> ;
    my @PHIX_F = split /\s+/, <PHIX> ;
    my @PHIX_R = split /\s+/, <PHIX> ;


    # do check 
    if ( $SCHISTO_F[0] ne $SCHISTO_R[0] ) {
	print "not same pair!\n" ; exit ; 
    }
    if ( $VIRUS_F[0] ne $VIRUS_R[0] ) {
	print "not same pair!\n" ; exit;
    }
    if ( $SCHISTO_F[0] ne $VIRUS_R[0] ) {
	print "not same pair!\n" ; exit;
    }
    
    # phix
    if ( $PHIX_F[1] == 77 && $PHIX_R[1] == 141 ) {
    }
    else {
	$phiXmapped++ ; 
	next ; 
    }

    if ( $SCHISTO_F[1] == 77 && $SCHISTO_R[1] == 141 ) {
	if ( $VIRUS_F[1] == 77 && $VIRUS_R[1] == 141 ) {
	    $totalunmapped++ ; 

	    print UNMAPF ">$SCHISTO_F[0]\n$VIRUS_F[9]\n" ;
            print UNMAPR ">$SCHISTO_R[0]\n$VIRUS_R[9]\n" ;
            print UNMAPI ">$SCHISTO_R[0]\n$VIRUS_F[9]$VIRUS_R[9]\n" ;

	    next ; 
	} 
	elsif ( $VIRUS_F[1] == 99 && $VIRUS_R[1] == 147 ) {
            $solelyvirus++ ;
            next ;
        }
	elsif ( $VIRUS_F[1] == 73 && $VIRUS_R[1] == 133 ) {
	    $virusPrimerDontknowReverse++ ; 
            next ;
	}
	else {
	    $hostnotmapped++ ; 
	    next ; 
	}
    }

    if ( $VIRUS_F[1] == 77 && $VIRUS_R[1] == 141 ) {
	$virusnotmapped++ ;
	next ;
    }

    # The pattern should now be always forward read in MLV and reverse read in schisto 
    if ( $SCHISTO_F[5] eq '*' && $VIRUS_R[5] eq '*' ) {
	#print "$SCHISTO_F[0]\t$SCHISTO_F[1]\t$SCHISTO_R[1]\t$SCHISTO_F[2]\t$SCHISTO_F[3]\t$SCHISTO_F[5]\t$SCHISTO_R[2]\t$SCHISTO_R[3]\t$SCHISTO_R[5]\t" ; 
	#print "$VIRUS_F[1]\t$VIRUS_R[1]\t$VIRUS_F[2]\t$VIRUS_F[3]\t$VIRUS_F[5]\t$VIRUS_R[2]\t$VIRUS_R[3]\t$VIRUS_R[5]\n" ; 

	print GOOD "$SCHISTO_F[0]\t$SCHISTO_F[1]\t$SCHISTO_R[1]\t$VIRUS_F[1]\t$VIRUS_R[1]\t$SCHISTO_R[2]\t$SCHISTO_R[3]\t$SCHISTO_R[5]\t$VIRUS_F[2]\t$VIRUS_F[3]\t$VIRUS_F[5]\n" ; 
	local $" = "\t";
	print SAM "@VIRUS_F\n" ; 
	
	if ( $VIRUS_F[3] eq '568' && $VIRUS_F[5] eq '70M5S' ) {
	    print GOODFA ">$SCHISTO_F[0]\n$VIRUS_F[9]\n" ; 
	}
	elsif ($VIRUS_F[3] eq '568' && $VIRUS_F[5] eq '67M8S' ) {
            print GOODFA2 ">$SCHISTO_F[0]\n$VIRUS_F[9]\n" ;
        }

    }
    else {
	print OUT "$SCHISTO_F[0]\t$SCHISTO_F[1]\t$SCHISTO_R[1]\t$SCHISTO_F[2]\t$SCHISTO_F[3]\t$SCHISTO_F[5]\t$SCHISTO_R[2]\t$SCHISTO_R[3]\t$SCHISTO_R[5]\t" ;
        print OUT "$VIRUS_F[1]\t$VIRUS_R[1]\t$VIRUS_F[2]\t$VIRUS_F[3]\t$VIRUS_F[5]\t$VIRUS_R[2]\t$VIRUS_R[3]\t$VIRUS_R[5]\n" ;
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
