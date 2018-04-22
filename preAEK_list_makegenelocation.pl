#!/usr/bin/perl -w
use strict;



if (@ARGV != 1) {
	print "$0 gff \n\n" ;
	print "Example usage:\n $0  gff \n\n" ;

	exit ;
}

my $file = shift @ARGV;
my $fastafile = shift @ARGV ;
my $contig_name = '' ;







open (IN, "$file") or die "oops!\n" ;

# gff

my $intron_start = '' ; 
my $count = 1; 




my %present = () ; 
my $kb = 1 ; 

# read in gff annotations
while (<IN>) {
	

    my @r = split /\s+/, $_ ;

    
    if ( $r[3] > 0 ) {
	print "$r[5]\t$r[2]\t$r[3]\txxxx\t" . ($r[3] +20000) .  "\txxxxx\n" ;
    }

    



	
}
