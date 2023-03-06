#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';




if (@ARGV != 2) {
    print "$0 /[1]or/[2] fastq.gz|fastq \n" ; 
    exit ;
}

my $pair = $ARGV[0] ;
my $filenameA = $ARGV[1];





if ( $filenameA=~ /.gz$/ ) {
    open (IN, "zcat $filenameA |") or die "oops!\n" ;
}
else {
    open (IN, "$filenameA") or die "oops!\n" ;
}


my $count = 1 ; 
while (<IN>) {

    chomp ; 
    my @name = split /\s+/  ;




    
    my $seq = <IN> ;
    my $tmp = <IN> ;
    my $qual = <IN> ;

    print "\@$name[1]/$pair\n$seq+\n$qual" ; 
    $count++ ; 
}

close(IN) ; 
