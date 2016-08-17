#!/usr/bin/perl -w
use strict;



my $PI = `echo $$` ; chomp($PI) ;


if (@ARGV != 1) {
    print "$0 gb \n" ;

	exit ;
}

my $file = shift @ARGV;


open (IN, "$file") or die "oops!\n" ;

my $count = 1 ; 

## read in the cufflink annotations
while (<IN>) {

    if (/LOCUS(\s+)(\S+)/ ) {
	my $gene = $2 ; 
	s/$gene/LOCUS$count/ ; 
	print "$_" ; 
	$count++ ; 
    }
    else {
	print "$_" ; 
    }

}
close(IN) ; 
