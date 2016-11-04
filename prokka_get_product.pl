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
    print "$0 Prokka_CY.tbl\n" ; 


	exit;
}

my $file = shift ; 


open (IN, "$file") or die "odapdopadoa\n" ; 
open OUT, ">", "$file.products" or die "daosdpaosd\n" ; 


while (<IN>) {
    next if /^\#/ ; 



    if ( /locus_tag\s+(\S+)/ ) {
	my $gene = $1 ;

	while (<IN>) {
	    chomp; 

	    my $product ;
	    if (  /product\s+(.+)/ ) {
		$product = $1 ; 
	    }
	
	    if ( $product ) {
		print OUT "$gene\t$product\n" ;
		last ;
	    }
	}
    }


}
close(IN) ;

print "$file.products produced!\n" ; 
