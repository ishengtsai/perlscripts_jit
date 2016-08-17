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


if (@ARGV != 2 ) {
    print "$0  bam.raw bam\n" ;
    exit;
}



my $bamraw = shift;
my $bam = shift ; 

print '------------------------------------------------' ;
print "\nauthor: JIT\n" ;
print "bam raw is: $bamraw\n" ; 
print "bam file is: $bam\n" ;
print '------------------------------------------------' . "\n\n";

my %reads = (); 

open( IN, "$bamraw") or die "doapdopsa\n" ; 
while (<IN>) {
    chomp ;
    my @r = split /\s+/, $_ ;
    $reads{$r[0]}++ ; 
}
close(IN) ; 



open( IN, "samtools view $bam |" ) or die "Cannot open $bam\n";
print "Parsing out reads now...\n" ;





my $total_reads = 0 ;

open OUT, ">", "$bam.correspondingreadsfound.sam" or die "ooops\n" ;


while (<IN>) {

    chomp ;
    my @r = split /\s+/, $_ ;

    if ( $reads{$r[0]} ) {
	print OUT "$_\n" ;
    }

}
close(IN) ;



