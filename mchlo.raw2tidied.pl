#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV != 1) {
	print "$0 fasta \n\n" ;
	exit ;
}

my $filenameA = $ARGV[0];



open (IN, "$filenameA") or die "oops!\n" ;
open OUT, ">", "$filenameA.tidied.fa" or die "daodpoad\n" ; 

my $read_name = '' ;
my $read_seq = '' ;

my %proteins = () ; 
my $present = 0 ; 

while (<IN>) {
    if (/^>.+(MCHLO_\d+)/) {
	my $name = $1 ; 

	if ( $proteins{$name} ) {
	    $present = 1 ;
	    print "$name duplicate! skip!\n" ; 
	    next ; 
	}
	else {
	    $proteins{$name}++ ;
	    $present = 0 ; 
	}

	print OUT ">$name\n" ; 
    }
    elsif (/^\S+/ && $present == 0 ) {
	print OUT "$_" ; 
    }



}

print "all done!" ;
my $size = scalar keys %proteins ;
print "$size\n" ; 
