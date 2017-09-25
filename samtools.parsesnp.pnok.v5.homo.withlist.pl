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


if (@ARGV != 3 ) {
    print "$0 list varsraw.vcf mincov\n" ; 
    exit;
}

my $listfile = shift ; 
my $vcf = shift ; 
my $mincov = shift ; 

my %list = () ; 

open (IN, "$listfile") or die "Dasodapdoadopaod\n" ; 

while (<IN>) {
    chomp ;
    my $line = $_ ; 
    
    if ( /(^\S+)\s+(\S+)/ ) {
	$list{$1} = $2 ;
    }
    else{
    	$list{$line} = $line ;
    }
}


open (IN, "$vcf") or die "odapdopadoa\n" ; 

open OUT, ">", "$vcf.parsed.with$listfile.mincov$mincov.fasta" or die "doapsodoa\n" ; 
open VCF, ">", "$vcf.parsed.with$listfile.mincov$mincov.vcf" or die "doaspdaosd\n" ; 

#open OUTGFF, ">", "$vcf.forsnpEff.vcf" or die "daksdoaisda\n" ; 
#print OUTGFF "\#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO\n" ; 

my $hetero = 0 ; 
my $nc = 0 ; 
my $total = 0 ; 
my $mincovsnp = 0 ; 
my $maxcovsnp = 0 ;

my @sampleNAME = () ; 
my %sampleSeq = () ; 


while (<IN>) {

 
    if ( /^\#\#/ ) {
	print VCF "$_" ; 
	next ; 
    }

    if ( /^\#CHROM/ ) {
	print VCF "$_" ;
	@sampleNAME = split /\s+/, $_ ; 
	print "Found! Sample name line: @sampleNAME\n" ; 
	next ; 
    }
 
    chomp ; 
    my @r = split /\s+/, $_ ; 

#    print "$r[0]\t$r[1]\t$r[3]\t$r[4]\n" ; 



    my @alleles = () ; 
    my $isIndel = 0 ; 

    push(@alleles, $r[3]) ; 
    my @altalleles = split /\,/, $r[4] ; 
    push(@alleles, @altalleles) ; 
    
    for (my $i = 0 ; $i< @alleles ; $i++ ) {
	if ( length($alleles[$i]) > 1 ) {
	    $isIndel++ ; 
	}
    }
    
    next if $isIndel ; 

    my $numvalidbase = 0 ; 
    for (my $i = 9 ; $i < @r ; $i++ ) {
	if ( $r[$i] =~ /^(\d+)\:/ ) {
            #print "$sampleNAME[$i]\t$alleles[$1]\n" ;
	    $numvalidbase++ ; 
	}
    }

    #print "$numvalidbase\n" ; 
    if ( $mincov > $numvalidbase ) {
	$mincovsnp++ ; 
	next ; 
    }

    for (my $i = 9 ; $i < @r ; $i++ ) {
	
	if ( $r[$i] =~ /^(\d+)\:/ ) {
	    #print "$sampleNAME[$i]\t$alleles[$1]\n" ;  
	    $sampleSeq{ $sampleNAME[$i] } .= $alleles[$1] ;
	}
	else {
	    #print "$sampleNAME[$i]\tN\n" ;
	    $sampleSeq{ $sampleNAME[$i] } .= "N" ;

	}

    }



    $total++ ; 

    print VCF "$_\n" ; 
    print "stored $total snps\n" if $total % 1000 == 0 ; 
    #last if $total % 5000 == 0 ;
}
close(IN) ; 

print "printint snp alignment...\n" ; 

for my $name ( sort keys %sampleSeq ) {
    next unless $list{$name} ; 
    print OUT  ">$list{$name}\n" ; 
    print OUT  "$sampleSeq{$name}\n" ; 
}




print "$total total snps called\n" ; 
print "$mincovsnp snps with coverage less than $mincov excluded\n" ; 


