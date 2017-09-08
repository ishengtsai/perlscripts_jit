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
    print "$0 samplenames.order.list.txt  varscan.vcf.file \n" ; 
    print "listfile and cov file all needs to be ordered\n" ; 

	exit;
}


my $covfile = shift ; 
my $vcf = shift ; 

my $total = 0 ; 
my $unconventional = 0 ;
my $noncalled = 0 ;  
my $sample = 0 ; 
my @sampleName = () ; 
my $nc = 0 ;



open (IN, $covfile) or die "doadpasodopa\n" ;


my %sampleCov = () ;
my $covline = 0 ; 
while(<IN>) {
    chomp ;
    #print "$_\n" ;
    my @r = split /\s+/, $_ ;
    push(@sampleName, $r[0]) ;

    $sampleCov{$r[0]}{'lower'} = 5 ;
    $sampleCov{$r[0]}{'upper'} = $r[1] * 2 ;


}
close(IN) ;


print "sameple length from $covfile: " . scalar @sampleName . "\n" ; 

open (IN, "$vcf") or die "odapdopadoa\n" ; 
open OUT, ">", "$vcf.mafonly" or die "doapsdoapdoaopdoa\n" ; 


my $vcffileSampleLen = 0 ; 
my $covtooHighorLow = 0 ; 

while (<IN>) {

    if ( /^\#CHROM/ ) {
	chomp ; 
        my @r = split /\s/, $_ ; 
	for (my $i = 9 ; $i < @r ; $i++ ) {
	    $sample++ ; 
	}


	print "Number of samples: $sample \n" ; 

	if ( scalar @sampleName != $sample ) {
	    print "not equal!\n" ; 
	    exit ; 
	}
	else {
	    print "equal...carrying on\n" ; 
	}
	next ; 
    }

    next if /^\#/ ; 
    chomp ;
    my @r = split /\s+/, $_ ;





    $total++ ; 


    # skip if indel or special cases
    if ( $r[4] eq 'A' || $r[4] eq 'T' ) {

    }
    elsif ( $r[4] eq 'C' || $r[4] eq 'G' ) {

    }
    else {
	$unconventional++ ; 
	next ; 
    }

    #print "$_\n" ; 

    for (my $i = 0 ; $i < $sample ; $i++ ) {
	my $column = $i + 9 ; 
	#print "$r[$column]\n" ; 


	my @sampleSplit = split /\:/, $r[$column] ; 

	#print "$_\n" ;

	# a catch for low cov in one of the samples
	unless ( $sampleSplit[6] ) {
	    #print "weird!$_\n" ; 
	    $noncalled++ ; 
	    next ; 
	}

	#print "$_\n" ; 

	# do not print out homozygous
	next unless $sampleSplit[0] eq '0/1' ; 
	#next if $sampleSplit[0] eq '1/1' ; 
	#next if $sampleSplit[0] eq '0/0' ;

	# coverage over
	#if ( $sampleSplit[3] < $sampleCov{$sampleName[$i]}{'lower'} || $sampleSplit[3] > $sampleCov{$sampleName[$i]}{'upper'} ) {
	#    $covtooHighorLow++ ; 
	#    next ; 
	#}


	$sampleSplit[6] =~ s/\%// ;
	if ( $sampleSplit[6] > 50 ) {
	    $sampleSplit[6] = 100 - $sampleSplit[6] ; 
	}

	# print only allele frequency and sample
	print OUT "$sampleSplit[6]\t$sampleName[$i]\t$sampleSplit[3]\t$sampleSplit[1]\n" ; 

	#print OUT "$sampleSplit[6]\t$sampleSplit[0]\t$sampleName[$i]\t$r[0]\t$r[1]\n" ;

    }

    #last if $total == 10000 ; 

}

print "Total sites: $total\n" ; 
print "Cov too high or low: $covtooHighorLow\n" ; 
print "all done! $vcf.mafonly done!\n" ; 

