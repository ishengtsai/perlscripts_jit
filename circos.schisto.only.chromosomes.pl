#! /usr/bin/perl -w
#
#
# Copyright (C) 2009 by Pathogene Group, Sanger Center
#
# Author: JIT
# Description: 
#		a script that map the Solexa reads back to the reference/contigs
#		and parition them based on either ends of the contigs
#
#
#




use strict;
use warnings;

# to print
local $" = "\t";


my $PI = `echo $$` ; chomp($PI) ;


if (@ARGV != 3 ) {
    print "$0 file small large\n" ; 

	exit;
}



my $bam = shift;
my $small = shift ; 
my $large = shift ; 


my %chrs = () ; 
$chrs{"smaSchisto_mansoni.Chr_1"}++ ; 
$chrs{"smaSchisto_mansoni.Chr_2"}++ ;
$chrs{"smaSchisto_mansoni.Chr_3"}++ ;
$chrs{"smaSchisto_mansoni.Chr_4"}++ ;
$chrs{"smaSchisto_mansoni.Chr_5"}++ ;
$chrs{"smaSchisto_mansoni.Chr_6"}++ ;
$chrs{"smaSchisto_mansoni.Chr_7"}++ ;
$chrs{"smaSchisto_mansoni.Chr_ZW"}++ ;

open (IN, $bam) or die "daopdpaosda\n" ; 

my $passinsfilter = 0 ; 

while (<IN>) {

    my $pair1 = $_ ; 
    my @r = split /\s+/, $pair1 ; 
    my $pair2 = <IN> ; 
    my @rr = split /\s+/, $pair2 ; 

    my $ins1 = $r[3] - $r[2] + 1; 
    my $ins2 = $rr[3] - $rr[2] + 1;

    next if $ins1 < $small ; 
    next if $ins2 < $small ;

    next if $ins1 > $large ;
    next if $ins2 > $large ;

    $passinsfilter++ ; 

    if ( $chrs{$r[1]} && $chrs{$rr[1]} ) {
	if ( $r[1] ne $rr[1] ) {
	    print "$pair1$pair2" ; 
	}
    }



}
close(IN) ; 



print "\#pass insert filter: $passinsfilter\n" ; 

