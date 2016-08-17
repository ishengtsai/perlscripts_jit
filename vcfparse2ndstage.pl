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
    print "$0 parsed.vcf.file [filterHomoOrNot]\n" ; 


	exit;
}

my $vcf = shift ; 
my $homofilter = shift ; 

my $total = 0 ; 
my $filtered = 0 ; 

open (IN, "$vcf") or die "odapdopadoa\n" ; 
open OUT, ">", "$vcf.$homofilter.filtered" or die "doapsdoapdoaopdoa\n" ; 
open HOMO, ">", "$vcf.filtered.00.frequency" or die "dasdpaodpaopd\n" ; 
open HETERO, ">", "$vcf.filtered.01.frequency" or die "dasdpaodpaopd\n" ;

while (<IN>) {
    next if /^\#/ ; 
    $total++ ; 

    my $wrong = 0 ; 

    chomp ; 
    my @r = split /\s/, $_ ; 

    print "$_\n" ; 

    for (my $i = 7 ; $i < @r-2 ; $i+=4 ) {
	print "$r[$i]\t" ; 
	#print "\n" ; 

	#if ( $r[$i] eq '01' ) {
	    

	    if ( $r[$i+2] =~ /,/ ) {
		my @derived_allles = split /,/ , $r[$i+2] ; 
		$r[$i+2] = $derived_allles[0] ; 
	    }

	    
	    my $total = $r[$i+1] + $r[$i+2] ; 
	    my $alleles_frequency = sprintf("%.3f", $r[$i+2]/ $total) ; 

	    print "$alleles_frequency" ; 

	print HOMO "$alleles_frequency\n" if $r[$i] eq '00' ;
	print HETERO "$alleles_frequency\n" if $r[$i] eq '01' ;

	if ( $r[$i] eq '01' && $alleles_frequency < 0.1 ) {
	    print "\ttoo low!\n" ; 
	    $wrong = 1 ; 
	}
	elsif ( $r[$i] eq '00' && $alleles_frequency > 0.3 ) {
	    print "\ttoo high???\n" ;
            $wrong = 1 if $homofilter== 1;
	}
	else {
	    print "\n" ; 
	}

	# modift
	if ( $r[$i] eq '01' ) {
	    $r[$i] = '0/1' ; 
	}
	elsif ( $r[$i] eq '00' ) {
	    $r[$i] = '0/0' ; 
	}
	elsif ($r[$i] eq '11' ) {
            $r[$i] = '1/1' ;
        }
	
	
    }
    print "\n" ; 

    if ( $wrong != 1 ) {
	
	print OUT "$r[0]" ; 
	for (my $i = 1 ; $i < @r ; $i++ ) {
	    print OUT "\t$r[$i]" ; 
	}
	print OUT "\n" ; 
    }
    else {
	$filtered++ ;  
    }



}
close(IN) ; 


print "Total: $total, homofilter: $homofilter, filtered: $filtered\n" ; 
