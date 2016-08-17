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


if (@ARGV != 1 ) {
    print "$0 bam\n" ; 

	exit;
}



my $bam = shift;
open OUT, ">", "$bam.diffchr.sam" or die "oodoapdpasd\n" ; 
open (IN, "samtools view -F 14 $bam |") or die "ooops\n" ;

my $total_reads = 0 ;
my $diffchr = 0;
my %diffchr_location = () ; 




my %pairs = () ;

while (<IN>) {
    chomp; 
    $total_reads++ ;

    my @r = split /\s+/, $_ ; 
    if ( $r[6] ne '=' ) {
	$diffchr++ ; 

	if ( $pairs{$r[0]} ) {
	    $pairs{$r[0]}{$r[1]} = "$_" ;

	    for my $bit ( sort {$a <=> $b} keys %{ $pairs{$r[0]} } ) {
		print OUT "$pairs{$pair}{$bit}\n" ;
	    }

	    delete $pairs{$r[0]} ; 
	    next ; 
	}

	$pairs{$r[0]}{$r[1]} = "$_" ; 	      
    }



}
close(IN) ; 

for my $pair ( keys %pairs ) {
    for my $bit ( sort {$a <=> $b} keys %{ $pairs{$pair} } ) {

	print OUT "$pairs{$pair}{$bit}\n" ; 
    }
}




print "$total_reads first read that is not proper paired, with $diffchr mapped to different chromosomes\n" ; 

