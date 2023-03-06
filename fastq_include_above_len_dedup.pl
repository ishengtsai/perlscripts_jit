#!/usr/bin/perl -w
use strict;


use IO::Compress::Gzip;



my $largest = 0;
my $contig = '';




if (@ARGV != 2) {
    print "$0 fastq.gz|fastq minlen\n" ; 
    exit ;
}

my $filenameA = $ARGV[0];
my $minlen = $ARGV[1]; 


#open OUT, ">", "$filenameA.min$minlen.dedup.fastq" or die "doadpsaodap\n" ; 
print "Start reading $filenameA...\n" ;

my $filename = "$filenameA.min$minlen.dedup.fq.gz" ; 
#open my $fh, '>:gzip' $filename or die "Could not write to $filename: $!";
my $fh_out = IO::Compress::Gzip->new("$filename");



if ( $filenameA=~ /.gz$/ ) {
    open (IN, "zcat $filenameA |") or die "oops!\n" ;
}
else {
    open (IN, "$filenameA") or die "oops!\n" ;
}

my $totalbp = 0 ;

my %readname = () ; 

while (<IN>) {

    my $name = $_ ;
    my $seq = <IN> ;
    chomp($seq) ; 
    my $tmp = <IN> ;
    my $qual = <IN> ;
    my $seqlen = length($seq)  ; 

    if ( $seqlen >= $minlen ) {
	if ( $readname { $name } ) {
	    print "Duplicate! $name" ; 
	}
	else {
	    $readname { $name }++ ; 
	    print $fh_out  "$name$seq\n$tmp$qual" ; 
	    #$totalbp += $seqlen ;
	}
    }

}

close(IN) ; 
close($fh_out) ; 

print "subset fastq len: $totalbp\n" ;  


