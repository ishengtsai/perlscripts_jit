#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV != 1) {
	print "samtools view readsorted.bam | bam2fastqPEexcludeProperPairs.pl outprefix \n\n" ;
	exit ;
}

my $outfile = shift ; 

open OUT1 , ">", "$outfile\_1.fq" or die "daosdpaoda\n" ;
open OUT2 , ">", "$outfile\_2.fq" or die "daosdpaoda\n";

my $count =  0 ; 

while (<>) {
    my $read1line = $_ ;
    my $read2line = <> ;

    my @read1 = split /\s+/, $read1line ;
    my @read2 = split /\s+/, $read2line ; 

    if ( $read1[1] == 99 || $read1[1] == 83 ) {
	next ; 
    }

    my $read1map = cigarmap($read1[5]) ;
    my $read2map = cigarmap($read2[5]) ;
    
    if ( $read1map < 100 && $read2map < 100 ) {
	print OUT1 '@'. "$read1[0]\n" . "$read1[9]\n" . '+' . "\n$read1[10]\n" ;
	print OUT2 '@'. "$read2[0]\n" . "$read2[9]\n" . '+'. "\n$read2[10]\n" ;
	$count++ ; 
    }
}

print "total of $count read pairs parsed!\n" ; 





sub cigarmap {
    my $cigar = shift ;
    my $map = 0 ;


    while ( $cigar =~ /(\d+)M/ ) {
	my $mapcigar = "$1" . "M" ;
	$map += $1 ;
	$cigar =~ s/$mapcigar// ;
    }

    return $map ;
}
