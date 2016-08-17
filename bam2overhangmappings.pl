#! /usr/bin/perl -w
#
#
# Copyright (C) 2009 by Pathogene Group, Sanger Center
#
# Author: JIT
# Description:
#               a script that map the Solexa reads back to the reference/contigs
#               and parition them based on either ends of the contigs
#
#
#




use strict;
use warnings;

# to print
local $" = "\t";


my $PI = `echo $$` ; chomp($PI) ;


#"


if (@ARGV != 1 ) {
    print "$0  bam\n" ;
    exit;
}



my $bam = shift;

print '------------------------------------------------' ;
print "\nauthor: JIT\n" ;
print "\nsam/bam to stats\n" ;
print "bam file is: $bam\n" ;
print '------------------------------------------------' . "\n\n";

open( IN, "samtools view $bam |" ) or die "Cannot open $bam\n";
print "Parsing out reads now...\n" ;

my $overhang = 20 ;



my $total_reads = 0 ;

open OUT, ">", "$bam.overhangatleast$overhang.sam" or die "ooops\n" ;
open OUTFASTA, ">", "$bam.overhang.atleast$overhang.fa" or die "opooops\n" ;

while (<IN>) {

    chomp ;
    my @r = split /\s+/, $_ ;

#    print "$_\n" ;

    if ( $r[5] =~ /^(\d+)S(\d+M)/ ) {
        if ( $1 >= $overhang ) {
            print OUT "$_\n" ;

            my $fasta = substr($r[9], 0, $1) ;
            print OUTFASTA ">$r[0]\n$fasta\n" ;

        }
    }
    elsif ( $r[5] =~ /(\d+)M(\d+)S$/ ) {

        if ( $2 >= $overhang ) {
            print OUT "$_\n" ;

            my $fasta =substr($r[9], $1) ;
            print OUTFASTA ">$r[0]\n$fasta\n" ;


        }
    }
    else {

    }


    $total_reads++ ;
    #last if $total_reads == 1000 ;
}
close(IN) ;

