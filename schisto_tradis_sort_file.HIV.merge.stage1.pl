#!/usr/bin/perl -w
use strict;



if (@ARGV != 1) {
    print "$0 hiv.merge.sam \n" ; 


	exit ;
}
my $mlvfile = shift @ARGV ; 

my $total = 0 ; 
my $unmapped = 0 ; 
my $good = 0 ; 

open (VIRUS, "$mlvfile") or die "Daosdapda\n" ; 

open OUTFA, ">", "$mlvfile.HIVfoundAndCut.fastq" or die "diadoaiod\n" ; 

while (<VIRUS>) {
    next if /\#/ ; 
    next if /\@/ ; 

    chomp ; 
    my @READ = split /\s+/, $_ ; 
    $total++ ; 

    # do check 
    if ( $READ[2] eq '*' ) {
	$unmapped++ ; 
	next ; 
    }

    local $" = "\t";
    #print "@READ\n" ; 

    my $cigar = modifycigar($READ[5]) ; 
    #print "$cigar\t" . length($READ[9]) . "\n" ; 

    if ( $cigar =~ /(\d+)M(\d+)S/ ) {
	my $cut = $1 ; 
	my $cutseq =  substr($READ[9], $cut) ;
	my $cutqual = substr($READ[10], $cut) ; 

	if ( length($cutseq) >= 30 ) {
	    print OUTFA '@' . "$READ[0]\n$cutseq\n+\n$cutqual\n" ;  
	    $good++ ; 
	}

    }
    


}
close(VIRUS) ; 

print "total: $total\n" ; 
print "unmapped: $unmapped\n" ; 
print "good: $good\n" ; 


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



