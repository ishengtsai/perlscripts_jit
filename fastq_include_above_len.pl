#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';




if (@ARGV != 2) {
    print "$0 fastq.gz|fastq minlen\n" ; 
    exit ;
}

my $filenameA = $ARGV[0];
my $minlen = $ARGV[1]; 


open OUT, ">", "$filenameA.min$minlen.fastq" or die "doadpsaodap\n" ; 
print "Start reading $filenameA...\n" ; 

if ( $filenameA=~ /.gz$/ ) {
    open (IN, "zcat $filenameA |") or die "oops!\n" ;
}
else {
    open (IN, "$filenameA") or die "oops!\n" ;
}

my $totalbp = 0; 

while (<IN>) {

    my $name = $_ ;
    my $seq = <IN> ;
    my $tmp = <IN> ;
    my $qual = <IN> ;
    my $seqlen = length($seq)  ; 

    if ( $seqlen >= $minlen ) {
	print OUT "$name$seq$tmp$qual" ; 
	$totalbp += $seqlen ; 
    }

}

close(IN) ; 
close(OUT) ; 

print "subset fastq len: $totalbp\n" ;  


