#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';




if (@ARGV != 2) {
    print "$0 index fastq.gz|fastq \n" ; 
    exit ;
}


my $index = $ARGV[0] ; 
my $filenameA = $ARGV[1];





if ( $filenameA=~ /.gz$/ ) {
    open (IN, "zcat $filenameA |") or die "oops!\n" ;
}
else {
    open (IN, "$filenameA") or die "oops!\n" ;
}

my $line = 0; 
my $count = 1 ; 

open OUT, ">", "$filenameA.subseq.fq" or die "odapdoapsd\n" ; 

while (<IN>) {
    $line++ ; 

    

    chomp; 
    my $name = $_ ;
    my $seq = <IN> ;
    my $tmp = <IN> ;
    my $qual = <IN> ;

    if ( /$index$/  ) {
    
	print OUT "$name\n$seq$tmp$qual" ; 
    
    }


    
    
}




