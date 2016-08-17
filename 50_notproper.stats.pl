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




open (IN, "samtools view -F 14 -f 64 $bam |") or die "ooops\n" ;




my $total_reads = 0 ;
my $diffchr = 0;

my %diffchr_location = () ; 

open OUT, ">", "$bam.insert.txt" or die "ooops\n" ; 
print OUT "chrname\tins.size\tmapped.pos\tmate.pos\n" ; 

open OUT2, ">", "$bam.diffchr.count.txt" or die "oooops\n" ; 


#open OUT3, ">", "$bam.Schisto_mansoni.Chr_1.Schisto_mansoni.Chr_ZW.count" or die "oooops\n" ; 

while (<IN>) {
    chomp; 

    my @r = split /\s+/, $_ ; 

 #   print "$_\n" ; 



    if ( $r[6] ne '=' ) {
	$diffchr++ ; 
	$total_reads++ ;

	my %twopieces = () ; 
	$twopieces{$r[2]}++ ; 
	$twopieces{$r[6]}++ ;
	
	my @chrs = sort keys %twopieces ; 


	$diffchr_location{"@chrs"}++ ; 

	#print "$_\n" ; 

	# for specific scenario:
	#if ( $r[2] eq 'Schisto_mansoni.Chr_1' && $r[6] eq 'Schisto_mansoni.Chr_ZW' ) {
	#    print OUT3 "$r[3]\t$r[7]\n" ; 
	#}
	#elsif ( $r[2] eq 'Schisto_mansoni.Chr_ZW' && $r[6] eq 'Schisto_mansoni.Chr_1' ) {
	#    print OUT3 "$r[7]\t$r[3]\n" ; 
	#}
	
	next ; 
    }

    # chrname ins.size mapped.pos mate.pos
    print OUT "$r[2]\t".  (abs($r[8])) ."\t$r[3]\t$r[7]\n" ; 

    $total_reads++ ; 

}
close(IN) ; 

for my $pair ( keys %diffchr_location ) {
    print OUT2 "$diffchr_location{$pair}\t$pair\n" ; 
}




print "$total_reads first read that is not proper paired, with $diffchr mapped to different chromosomes\n" ; 
print " $bam.insert.txt and $bam.diffchr.count.txt produced!\n" ; 
