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


if (@ARGV != 1 ) {
    print "$0 parsed.vcf.file \n" ; 


	exit;
}

my $vcf = shift ; 


my $total = 0 ; 
my $filtered = 0 ; 

open (IN, "$vcf") or die "odapdopadoa\n" ; 
open OUT, ">", "$vcf.hetero.maf" or die "doapsdoapdoaopdoa\n" ; 


while (<IN>) {
    next if /^\#/ ; 
    $total++ ; 

    next if /INDEL\;/ ; 

    chomp ; 
    my @r = split /\s/, $_ ; 

    if ( /DP4=(\d+)\,(\d+)\,(\d+)\,(\d+)\;/ ) {
	my $ref = $1 + $2 ; 
	my $alt = $3 + $4 ; 
	my $rounded = 0 ; 
	my $cov = $ref + $alt ; 

	if ( $ref > $alt ) {
	    $rounded = sprintf("%.3f", $alt / $cov ) ; 
	}
	else {
	    $rounded = sprintf("%.3f", $ref / $cov ) ;
	}

	if ( $ref != 0 ) {
	    print OUT "$r[0]\t$r[1]\t$rounded\t$cov\n" ; 
	}
    }

 #   print "$_\n" ; 

}

print "all done! $vcf.hetero.maf done!\n" ; 

