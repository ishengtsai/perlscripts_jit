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


if (@ARGV != 4 ) {
    print "$0 varsraw.strandfilter1.txt scaffold.name mincov maxcov\n" ; 
    exit;
}

my $vcf = shift ; 
my $scaffold = shift ; 
my $mincov = shift ; 
my $maxcov = shift ; 

open (IN, "$vcf") or die "odapdopadoa\n" ; 

open OUT, ">", "$vcf.stats" or die "doapsodoa\n" ; 
open OUTGFF2, ">", "$scaffold.bed" or die "daksdoaisda\n" ;

open OUTGFF, ">", "$vcf.forsnpEff.vcf" or die "daksdoaisda\n" ; 
print OUTGFF "\#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO\n" ; 

my $hetero = 0 ; 
my $nc = 0 ; 
my $total = 0 ; 
my $mincovsnp = 0 ; 
my $maxcovsnp = 0 ;

my $header = <IN> ; 


while (<IN>) {
    next if /^\#/ ; 
    chomp ; 
    my @r = split /\s+/, $_ ; 

#    print "$r[6]\t$r[7]\t$r[8]\t$r[9]\n" ; 

    if ( $r[7] > 0  ) {
	$hetero++ ; 
	next ; 
    }
    if ( $r[9] > 0 ) {
	$nc++ ; 
	next ; 
    }

    #print "$r[6]\t$r[7]\t$r[8]\t$r[9]\n" ;      
    #print "$r[10]\t$r[11]\n" ; 

    if ( $r[10] && $r[11] ) {
	my @snp1 = split (/\:/, $r[10]) ; 
	my @snp2 = split (/\:/, $r[11]) ;	

	#remove if common diff
	next if $snp1[0] eq $snp2[0] ; 
	
	# remove if smaller than this cov
	if ( $snp1[1] < $mincov || $snp2[1] < $mincov ) {
	    $mincovsnp++ ;
	    next ; 
	}

	# remove if bigger than this cov
	if ( $snp1[1] > $maxcov || $snp2[1] > $maxcov ) {
	    $maxcovsnp++ ;
            next ;

        }

	print OUT "$r[0]\t$r[1]\t$snp1[0]\t$snp1[1]\t$snp2[0]\t$snp2[1]\t\n" ; 
	#print OUTGFF "$r[0]\t$r[2]\t$r[3]\n" ;
	#if ( $r[0] eq $scaffold ) {
	
	if ( $r[3] =~ /[\,\+\-]/ ) {
	    print OUTGFF "\#$r[0]\t$r[1]\t.\t$r[2]\t$r[3]\t30\tPASS\tCOMMENT=$snp1[0].$snp1[1].$snp2[0].$snp2[1]\;\n" ; 
	}
	else {
	    print OUTGFF "$r[0]\t$r[1]\t.\t$r[2]\t$r[3]\t30\tPASS\tCOMMENT=$snp1[0].$snp1[1].$snp2[0].$snp2[1]\;\n" ;
	}
	#}

	if ( $r[0] eq $scaffold ) {
	    print OUTGFF2 "$r[0]\t$r[1]\t$r[1]\n" ; 
	}

	$total++ ; 

    }
    else {
	#print "wierd! $_\n" ; 
	$nc++ ; 
    }





}
close(IN) ; 



print "$hetero hetero\n" ; 
print "$nc non called\n" ; 
print "$mincovsnp mincovsnp\n" ; 
print "$maxcovsnp maxcovsnp\n" ; 
print "$total total snps\n" ; 



