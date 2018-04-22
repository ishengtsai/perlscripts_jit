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

    if ( $present{$r[12]} ) {
	$kb += 50000 ; 
    }
    else {
	$kb = 1 ;
	$present{$r[12]}++ ; 
    }

    
    if ( $r[8] =~ /Name=(\S+)\;/) {
	print "$1\t$r[12]\t$kb\txxxx\t" . ($kb +20000) .  "\txxxxx\n" ;
    }

    



	
}
