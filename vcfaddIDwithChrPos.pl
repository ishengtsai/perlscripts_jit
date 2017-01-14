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
open OUT, ">", "$vcf.ID.vcf" or die "doapsdoapdoaopdoa\n" ; 


while (<IN>) {
    

    if (/^\#/ ) {
	print OUT "$_" ; 
	next; 
    }

    s/(^\S+)\s+(\S+)\s+(\S+)/$1\t$2\t$1.$2/ ; 

    print OUT "$_" ; 


}
close(IN) ; 


print " all done! $vcf.ID.vcf produced \n" ; 
