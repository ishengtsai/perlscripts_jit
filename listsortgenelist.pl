#!/usr/bin/env perl

use strict;
use warnings;
use File::Spec;



my $PI = `echo $$` ;    chomp($PI) ;

#debug 
my $debug = 0 ; 

if (@ARGV != 2) {
    print STDERR "usage: $0 list gff \n" ; 
    print STDERR "gff should be sorted!\n" ; 
    exit(1);
}



my $listfile = shift ; 
my $gff = shift ; 

my @list = () ; 
my %isList = () ; 
my %genes = () ; 


open (IN, "$listfile") or die "dasodpadoap\n" ; 
while (<IN>) {
    chomp; 
    $isList{$_}++ ; 
    push(@list, $_) ; 
}
close(IN) ; 

open (IN, "$gff") or die "dadpoaodaospd\n" ; 
while (<IN>) {
    chomp; 
    my @r = split /\s+/, $_ ; 
    

    
    if ( $isList{$r[0]} ) {
	

	if ( $r[8] =~ /ID=(\S+):mRNA\;Name/ ) {
	    my $gene = $1 ; 

	    #print "$gene\n" ; 

	    if ( $genes{$r[0]} ) {
		$genes{$r[0]} .= " $gene" ; 
	    }
	    else {
		$genes{$r[0]} = "$gene" ; 
	    }
	    
	}
    }

}



foreach my $scaff ( @list ) {

    if ( $genes{$scaff} ) {
	my @genelist = split /\s+/, $genes{$scaff} ; 
	foreach ( @genelist ) {
	    print "$_\n" ; 
	}

	print "separate\n" ;
    }


}
