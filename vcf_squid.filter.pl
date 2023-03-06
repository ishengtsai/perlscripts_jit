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
    print "$0 parsed.vcf.file cov.list \n" ; 


	exit;
}

my $vcf = shift ; 

my $contigFile = shift ; 

my $total = 0 ; 
my $filtered = 0 ;

my %contig = () ; 

open OUT, ">", "$vcf.filtered.SNP.list" or die "dasdaosdoa\n" ; 

open (IN, "$vcf") or die "odapdopadoa\n" ; 


while (<IN>) {
    next if /^\#/ ; 
    next if /INDEL/ ; 

    my $wrong = 0 ; 

    chomp ; 
    my @r = split /\s/, $_ ; 

    #print "$_\n" ; 

    my @female = split /\:/, $r[9] ;
    my @male = split /\:/, $r[10] ;

    if ( $female[2] > 5 && $female[2] < 15 ) {
	#print "F3_RT.final.bam:$r[9]\tM4.final.bam:$r[10]\n" ; 
	#print "Cov Female: $female[2] Male: $male[2]\n\n" ;

	if ( $male[2] == 0 && $r[5] >= 30 ) {
	    #print "F3_RT.final.bam:$r[9]\tM4.final.bam:$r[10]\n" ;
	    #print "Cov Female: $female[2] Male: $male[2]\n\n" ;
	    #print "$_\n" ;

	    if ( $female[0] eq '0/1' ) {
		$contig{$r[0]}++ ; 
	    }
	    else {
		next ; 
	    }
	    
	}
	else {
	    next ; 
	}
	
    }
    else {
	next ;
    }

	
    

    $total++ ;

    if ( $total < 10 ) {
	print "F3_RT.final.bam:$r[9]\tM4.final.bam:$r[10]\n" ;
	print "Cov Female: $female[2] Male: $male[2]\n\n" ;
	#print "$_\n" ;
    }
    print OUT "$_\n" ; 
    
    


}
close(IN) ;
close(OUT) ; 


open (IN, "$contigFile") or die "odapdopadoa\n" ;
open OUT, ">", "$contigFile.hetSNPexcluded.list" or die "dakdkladlkas\n" ; 

while (<IN>) {

    chomp ;
    my @r = split /\s/, $_ ;


    if ( $contig{$r[0]} ) {
	$filtered++ ; 
    }
    else {
	print OUT "$_\n" ; 
    }
    

}






print "done! $vcf.filtered.SNP.list printed! a total of $total SNPs!\n" ; 
print "done! $contigFile.hetSNPexcluded.list done!\n" ; 
print "number of excluded contigs: $filtered\n" ; 
