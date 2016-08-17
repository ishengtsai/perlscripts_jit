#!/usr/bin/perl -w
use strict;



my $PI = `echo $$` ; chomp($PI) ;


if (@ARGV != 1) {
    print "$0 scipio_gff \n" ;

	exit ;
}

my $file = shift @ARGV;


open (IN, "$file") or die "oops!\n" ;

my %content = () ; 
my %gene_status = () ; 

my $gene = '' ; 
my $status = '' ; 

while (<IN>) {

    if ( /^\#/ ) {
	print "$_" ; 
	next ; 
    }
    if ( /---/ ) {
	print "$_" ;
        next ;
    }

    if ( /downstream_gap/ ) {
	if ( $gene_status{$gene} eq 'auto' ) {
            print "$content{$gene}" ;
	    print "$_" ;
        }
    }

    
    if (/(^\S+):/ ) {
	$gene = $1 ; 
	$content{$gene} .= $_ ; 
    }
    elsif ( /status: (\S+)/ ) {
	$status = $1 ; 
	$gene_status{$gene} = $status ; 
	$content{$gene} .= $_ ;
    }
    else {
	$content{$gene} .= $_ ;
    }


}
close(IN) ; 


