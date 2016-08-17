#!/usr/bin/perl -w
use strict;



my $PI = `echo $$` ; chomp($PI) ;


if (@ARGV != 1) {
    print "$0 scipio_gff \n" ;

	exit ;
}

my $file = shift @ARGV;


open (IN, "$file") or die "oops!\n" ;


my %gene_exons = () ;
my %gene_strand = () ;
my %gene_loc = () ;

my %gene_start = () ;
my %gene_end = () ;

## read in the cufflink annotations
while (<IN>) {
    my $allvariable = '' ; 
    my $transcript = '' ; 

    if (/ID=\S+Query=(\S+)\s+\d+\s+\d+/ ) {
	$transcript = $1 ; 

	if ( /(ID=\S+Query=\S+\s+\d+\s+\d+)/ ) {
	    $allvariable = $1 ; 
	}

	s/$allvariable/transcript \"$transcript\"/ ; 
	s/protein_match/CDS/ ; 

	print "$_" ; 

    }
    else {
	print "$_" ;
    }


}
