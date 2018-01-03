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

    if ( $present{$r[0]} ) {
	$kb += 50000 ; 
    }
    else {
	$kb = 1 ;
	$present{$r[0]}++ ; 
    }

    
    if ( $r[4] =~ /(\S+)\|(\S+)/ ) {
	my $gene1 = $1 ;
	my $gene2 = $2 ; 

	print "$gene1\t$r[0]\t$kb\txxxx\t" . ($kb +20000) .  "\txxxxx\n" ;
	print "$gene2\t$r[0]\t" . ($kb+10000) . "\txxxx\t" . ($kb+30000) . "\txxxxx\n" ; 
    }
    else {
	print "$r[4]\t$r[0]\t$kb\txxxx\t" . ($kb +20000) .  "\txxxxx\n" ;

    }
    



	
}
