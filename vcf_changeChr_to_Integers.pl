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
open OUT, ">", "$vcf.scaffIntegers.vcf" or die "doapsdoapdoaopdoa\n" ; 


my %scaffolds = () ; 

while (<IN>) {
    

    if (/^\#/ ) {
	print OUT "$_" ; 
	next; 
    }


    my @r = split /\s+/, $_ ; 

    if ( $scaffolds{$r[0]} ) {
	s/^\S+/$scaffolds{$r[0]}/ ; 
    }
    else {
	my $size = keys %scaffolds;

	$scaffolds{$r[0]} = ($size + 1 ) ; 
	s/^\S+/$scaffolds{$r[0]}/ ;
    }

    #print "$_" ; 
    print OUT "$_" ; 


}
close(IN) ; 


print " all done! $vcf.scaffIntegers.vcf produced \n" ; 
