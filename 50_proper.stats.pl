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


if (@ARGV != 2 ) {
    print "$0 bam number.reads\n" ; 

	exit;
}



my $bam = shift;
my $numproper = shift ; 



open (IN, "samtools view -f 66 $bam |") or die "ooops\n" ;

my $total_reads = 0 ;
open OUT, ">", "$bam.proprt.insert.txt" or die "ooops\n" ; 





#open OUT3, ">", "$bam.Schisto_mansoni.Chr_1.Schisto_mansoni.Chr_ZW.count" or die "oooops\n" ; 

while (<IN>) {
    chomp; 

    my @r = split /\s+/, $_ ; 

 #   print "$_\n" ; 

    my $ins = abs($r[8]) ; 
    print OUT "$ins\n" ; 

    $total_reads++ ; 
    
    last if $total_reads == $numproper ; 

}
close(IN) ; 

