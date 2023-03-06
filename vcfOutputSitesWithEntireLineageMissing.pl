#! /usr/bin/perl -w
#
# Time-stamp: <19-Feb-2009 14:43:44 jit>
# $Id: $
#
# Copyright (C) 2008 by Pathogene Group, Sanger Center
#
# Author: JIT
# Description: a parallelised script to split the Illumina reads to subsets
# 
# Modified by Taisei 17aug2013 for DDBJ qsub
#

use strict;


my $PI = `echo $$` ; chomp($PI); 


if (@ARGV != 2 ) {
    print "$0 vcf clustFile\n" ; 


	exit;
}


my $vcf = shift ; 
my $clustfile = shift ;

my $total = 0 ; 
my $filtered = 0 ; 

my %populationList = () ; 
my %populations = () ; 

open (IN, "$clustfile") or die "odapdopadoa\n" ;


while (<IN>) {
    chomp ;
    my @r = split /\s+/, $_ ;

    $populations{$r[1]} = $r[2] ; 
    $populationList{$r[2]}++ ; 

}
close(IN) ; 



open (IN, "$vcf") or die "odapdopadoa\n" ; 
open OUT, ">", "$clustfile.lineageNoEntireMissing.vcf" or die "doapsdoapdoaopdoa\n" ; 


my @samples = () ; 

my $count = 0 ; 

while (<IN>) {
    

    if (/^\#\#/ ) {
	print OUT "$_" ; 
	next; 
    }
    elsif ( /^\#CHROM/ ) {
	print OUT "$_" ; 
	chomp ; 
	@samples = split /\s+/, $_ ; 
	
    }
    else {
	my $vcfline = $_ ; 
	chomp ;
	my @r = split /\s+/, $_ ;
	my %popNoMissing = () ; 

	for (my $i = 9 ; $i < @samples ; $i++ ) {
	    next unless $populations{$samples[$i]} ; 

	    my @info = split  /\:/, $r[$i] ;
	    
	    
	    #print "$r[1]\t$samples[$i]\t$info[0]\t$populations{$samples[$i]}\n" ;

	    if ( $info[0] ne './.' ) {
		my $pop = $populations{$samples[$i]} ;
		#print "$pop yeah\n" ; 
		$popNoMissing{$pop}++ ; 
	    }

	}

	my $popHasMissing = 0 ;
	my %missingPop = () ; 
	for my $population ( keys %populationList ) {
	    if ( $popNoMissing{$population} ) {
		
	    }
	    else {
		$popHasMissing = 1 ;
		$missingPop{$population}++ ; 
	    }
	} 


	if ( $popHasMissing == 1 ) {
	    print "$r[0]\t$r[1]\t" ;
	    for my $population ( keys %missingPop ) {
		print "\t$population" ; 
	    }
	    print "\n" ; 
	}
	else {
	    print OUT "$vcfline" ; 
	    #print "$r[0]\t$r[1]\tyeah no missing!\n" ; 
	}
	

    }    


    

}
close(IN) ; 


print " all done! $clustfile.lineageNoEntireMissing.vcf produced \n" ; 
