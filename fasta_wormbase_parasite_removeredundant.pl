#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';




if (@ARGV != 1) {
    print "$0 wormbaseParasite.fasta \n" ; 
	exit ;
}

my $filenameA = $ARGV[0];


my %gene_present = () ; 

open (IN, "$filenameA") or die "oops!\n" ;

my $gene_name = '' ;
my $isoform = 0 ;

open OUT, ">", "$filenameA.nr.fa" or die "odpsodsss\n" ; 


my %id = () ; 
my $proteinNO = 0 ; 

my %proteinfound = () ; 
my $proteinfoundNO = 0 ; 

while (<IN>) {

    if (/gene=(\S+)/) {
	$gene_name = $1 ; 
	$proteinNO++ ;
	
	if ( $gene_present{$gene_name} ) {
	    print "$gene_name redundant isoform! \n" ;
	    $isoform = 0 ; 
	}
	else {
	    $gene_present{$gene_name}++ ; 
	    print OUT ">$gene_name\n" ;
	    $isoform = 1 ; 
	}
    }
    elsif ( $isoform == 1 ) {
	print OUT "$_" ; 

    }

}

close(IN) ;

