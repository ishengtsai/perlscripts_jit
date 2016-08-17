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
    print "$0 Bok.assigned.list BOKJ.annot.gff.gene.location diffexp.in.males.compared.to.adults.and.mixed.list.fpkm.table.parsed\n" ; 
    exit;
}

my $groupfile = shift ; 
my $gff = shift ; 
my $listfile = shift ; 

open OUT, ">", "$listfile.group" or die "daosdoap\n" ; 
open OUT2, ">", "$listfile.scaffolds" or die"daosdoap\n" ;

open (IN, "$groupfile") or die "odapdopadoa\n" ; 

my %groups = () ; 

while (<IN>) {
    next if /^\#/ ; 
    chomp ; 
    my @r = split /\s+/, $_ ; 
    $groups{$r[0]} = "$r[1]" ; 

}
close(IN) ; 


open (IN, "$gff") or die "daodpaoda\n" ; 

my %genes = () ;
my %genesInScaff = () ; 

while (<IN>) {
    next if /^\#/ ;
    chomp ;
    my @r = split /\s+/, $_ ;

    $r[0] =~ s/\.\d+//gi ; 

    $genesInScaff{$r[0]} = "$r[1]" ; 
    

    if ( $groups{$r[1]} ) {
	$genes{$r[0]} = $groups{$r[1]} ; 
    }
    else {
	$genes{$r[0]} = "NOTassigned" ; 
    }

}
close(IN) ; 


open (IN, "$listfile") or die "dasdapo\n" ; 

my %assigned = () ; 
my %assigned_scaff = () ; 

while (<IN>) {

    chomp ;
    my @r = split /\s+/, $_ ;
    
    my $group = $genes{$r[0]} ; 
    my $scaff = $genesInScaff{$r[0]} ; 
    $assigned{$group}++ ; 
    $assigned_scaff{$scaff} ++ ; 

}
close(IN) ; 


for my $chr (sort keys %assigned) {
    print OUT "$chr\t$assigned{$chr}\n" ; 

}


for my $scaff ( sort keys %assigned_scaff ) {

    print OUT2 "$scaff\t$assigned_scaff{$scaff}\n" ; 

}

print "all done ! all done!\n" ; 

