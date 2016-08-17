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
    print "$0 vcf.file\n" ; 


	exit;
}

my $vcf = shift ; 

open (IN, "$vcf") or die "odapdopadoa\n" ; 

my $validhomo = 0 ; 

my $DBsnp = 0 ; 

my $total = 0 ; 
my $lowqual = 0 ; 
my $lowdepth = 0 ; 
my $nocov = 0 ; 
my $ambiguous = 0 ; 
my $bothhetero = 0 ; 
my $bothdifferentconcensus = 0 ; 
my $putativesomatic = 0 ; 
my $nosnpindiseaseparent = 0 ;
my $homoindiseaseheteroincontrol = 0 ; 
my $heteroindisease_with_newmutation_incontrol = 0 ; 
my $nomandelianinchild = 0 ; 
my $lowGQ = 0 ; 
my $filteredSNP = 0 ; 
my $niecenotconsistent = 0 ; 

while (<IN>) {
    next if /^\#/ ; 
    
    $total++ ; 


    chomp ; 
    my @r = split /\s+/, $_ ; 
    
 
    if ( $r[7] =~ /NC=(\d+)/ ) {
	if ( $1 > 0 ) {
	    $nocov++ ;
	    next ; 
	}
    }

    unless ( $r[16] ) {
	$ambiguous++ ;
	#print "wierd! $_\n" ;
	next ; 

    }


    my $isnocov = 0 ; 
    $isnocov = 1 if $r[12] =~ /^\.\/\./ ; 
    $isnocov = 1 if $r[13] =~ /^\.\/\./ ;
    $isnocov = 1 if $r[14] =~ /^\.\/\./ ;
    $isnocov = 1 if $r[15] =~ /^\.\/\./ ;
    $isnocov = 1 if $r[16] =~ /^\.\/\./ ;
    if ( $isnocov == 1 ) {
        $nocov++ ; 
        next ; 
    }


    unless ( $r[8] =~ /^GT:GQ:/ ) {
	$ambiguous++ ; 
	print "wierd! $_\n" ; 
	next ; 
    }


    my $checkhomo = 0; 

#    print "$r[9]\t$r[10]\t$r[11]\t$r[12]\t$r[16]\n" ; 


    # need to modify here !!!!
    my $parent1 = $r[12] ; 
    my $parent2 = $r[13] ; 

    $r[12] = $parent1 ; 
    $r[13] = $parent2 ; 

    $r[0] =~ s/chr// ;
    my $numchar = length( $r[3] ) - 1;


    # need to modify here
    my @member1 = split /\:/, $r[12] ;
    my @member2 = split /\:/, $r[13];
    my @member3 = split /\:/, $r[14] ;
    my @member4 = split /\:/, $r[15] ; 
    my @member8 = split /\:/, $r[16] ; 

    #print "$r[0] $r[1] $member1[2] $member2[2] $member3[2] $member4[2] $member8[2] \n" ;
    #next ; 
    
    

    my $islowdepth = 0 ;




    $islowdepth = 1 if $member1[3] eq '.' ;
    $islowdepth = 1 if $member2[3] eq '.';
    $islowdepth = 1 if $member3[3] eq '.';
    $islowdepth = 1 if $member4[3] eq '.';
    $islowdepth = 1 if $member8[3] eq '.' ; 
    if ( $islowdepth ==1 ) {
	$lowdepth++ ;
	next ;
    }

    $islowdepth= 1 if $member1[3] < 10;
    $islowdepth = 1 if $member2[3] < 10;
    $islowdepth = 1 if $member3[3] < 10 ;
    $islowdepth = 1 if $member4[3] < 10 ;
    $islowdepth = 1 if $member8[3] < 10 ;
    if ( $islowdepth == 1 ) {
	$lowdepth++ ;
	next ;
    }

    if ( $parent1 =~ /(^0[\|\/]0)/ ) {
	$nosnpindiseaseparent++ ;
	next ;
    }


    
    if ( $parent1 =~ /(^0[\|\/]1)/ || $parent1 =~ /(^1[\|\/]0)/ ) {
	if ( $parent2 =~ /(^0[\|\/]1)/ || $parent2 =~ /(^1[\|\/]0)/ ) {
	    $bothhetero++ ; 
	    next ; 
	}
    }
    if ( $member1[0] eq $member2[0] ) {
	$bothhetero++ ;
	next ;
    }


    if ( $parent1 =~ /(^1[\|\/]1)/ && $parent2 =~ /(^1[\|\/]1)/ ) {
	   $bothdifferentconcensus++ ; 
           next ;
    }

    if ( $parent1 =~ /(^0[\|\/]0)/ && $$parent2 =~ /(^0[\|\/]0)/ ) {
	$putativesomatic++ ; 
	next ; 
    }


    if ( $parent1 =~ /(^1[\|\/]1)/ ) { 
	if ( $parent2 =~ /(^1[\|\/]0)/ || $parent2 =~ /(^0[\|\/]1)/ ) {
	    $homoindiseaseheteroincontrol++ ; 
	    next ;
	}
    }

    if ( $parent1 =~ /(^1[\|\/]0)/ || $parent1 =~ /(^0[\|\/]1)/ ) {
	if ( $parent2 =~ /(^1[\|\/]1)/ ) {
	    $heteroindisease_with_newmutation_incontrol++ ; 
	    next ; 
	}
    }

    if ( $r[14] =~ /(^0[\|\/]1)/ || $r[14] =~ /(^1[\|\/]0)/ ) {
	if ( $r[15] =~ /(^0[\|\/]1)/ || $r[15] =~ /(^1[\|\/]0)/ ) {

	}
	else {
	    $nomandelianinchild++ ;
	    next ;
	}

    }
    else {
	$nomandelianinchild++ ; 
	next ; 
    }


    if ( $r[2] =~ /rs/ ) {
	$DBsnp++ ; 
	next ; 
    }

    #if ( $r[5] < 20 ) {
    #	$lowGQ++ ; 
    #	next ; 
    #}


    # a filter here
    if ( $member3[0] eq $member8[0] || $member4[0] eq $member8[0] ) {

    }
    else {
	$niecenotconsistent++ ; 
	next ; 
    }

    #wierd filter here!                                                                                                                                                                                                                                                          
    #if ( $member1[0] eq '1/0' || $member1[0] eq '0/1' ) {
    #my @cov = split /\,/, $member1[1] ; 
#	if ( $cov[1] < 2 ) {
#	    print "wierd! $_\n" ; 
#	    exit ; 
#	}
 #   }


    $member1[0] =~ s/[\/\|]//gi ; 
    $member2[0] =~ s/[\/\|]//gi ;
    $member3[0] =~ s/[\/\|]//gi ;
    $member4[0] =~ s/[\/\|]//gi ;
    $member8[0] =~ s/[\/\|]//gi ;


    #$member1[1] =~ s/,/ / ; 
    #$member2[1]=~ s/,/ / ;
    #$member3[1]=~ s/,/ / ;
    #$member4[1]=~ s/,/ / ;
    #$member8[1]=~ s/,/ / ;


    print "$r[0]\t$r[1]\t" . ($r[1]+$numchar)  . "\t$r[3]\t$r[4]\tcomments: Affected.Father $member1[0] $member1[4] $member1[5] Normal.Mother $member2[0] $member2[4] $member2[5] Affected.son $member3[0] $member3[4] $member3[5] Affected.daughter $member4[0] $member4[4] $member4[5] Affected.niece $member8[0] $member8[4] $member8[5] $r[2] $r[5]\n" ; 
    $filteredSNP++ ; 

}
close(IN) ; 


print "\# Sequential filters:\n" ; 
print "\#$total total snps\n" ; 
#print "\#$lowqual low qual (by GATK)\n" ; 
print "\#$lowdepth (less than 10X) \n" ; 
print "\#$nocov (no coverage)\n" ; 
#print "\#$ambiguous ambiguous\n" ; 
print "\#$bothhetero bothhetero\n" ; 
#print "\#$bothdifferentconcensus bothdifferentconcensus\n" ; 
#print "\#$putativesomatic putativesomatic\n" ; 
print "\#$nosnpindiseaseparent nosnpindiseaseparent\n" ; 
print "\#$homoindiseaseheteroincontrol homoindiseaseheteroincontrol\n" ; 
print "\#$heteroindisease_with_newmutation_incontrol heteroindisease_with_newmutation_incontrol\n" ; 
print "\#$nomandelianinchild nomandelianinchild\n" ; 
#print "\#$lowGQ lowGQ\n" ; 
print "\#offsprings not consistent with niece: $niecenotconsistent\n" ; 
print "\#$filteredSNP final num of filtered SNP\n" ; 
print "\#\#\n" ; 

