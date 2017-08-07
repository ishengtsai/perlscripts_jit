#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';




if (@ARGV != 2) {
    print "$0 fastq.gz|fastq genomesizeInMb \n" ; 
    exit ;
}

my $filenameA = $ARGV[0];
my $genomesize = $ARGV[1] ; 




if ( $filenameA=~ /.gz$/ ) {
    open (IN, "zcat $filenameA |") or die "oops!\n" ;
}
else {
    open (IN, "$filenameA") or die "oops!\n" ;
}

open OUT, ">", "$filenameA.len" or die "daodpsaodap\n" ; 

my $totallen = 0 ; 
my $seqcount = 0 ; 

my $max = 0 ; 
my $maxreadname ;

while (<IN>) {

    chomp ; 
    my $name = $_ ;
    my $readname ;
    if ($name =~ /^\@(\S+)/ ) {
	$readname = $1 ; 
    }
    
    my $seq = <IN> ;
    my $tmp = <IN> ;
    my $qual = <IN> ;
    my $seqlen = length($seq) ; 
    
    $totallen += $seqlen ;
    if ($max < $seqlen) {
	$max = $seqlen ;
	$maxreadname = $readname ; 
    } 
    $seqcount++ ;

    print OUT "$readname\t$seqlen\n" ; 

}

close(IN) ; 

my $totalMb = sprintf ("%.0f", $totallen / 1000000 ) ; 
my $cov = sprintf("%.3f", ($totalMb /$genomesize ) ) ; 

print "Fastq total of $seqcount sequences with $totallen bases or $totalMb Mbs\n" ;
print "Longest length: $maxreadname , $max bp \n" ; 
print "With a estimated genome size of $genomesize Mb, we would have $cov X in this lane\n" ; 
print "$filenameA.len output! for subsequent plot and analysis\n" ; 


