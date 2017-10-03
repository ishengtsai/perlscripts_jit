#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';




if (@ARGV != 2) {
    print "$0 readnamefile fastq.gz|fastq \n" ; 
    exit ;
}


my $readfile = $ARGV[0] ; 
my $filenameA = $ARGV[1];

my %reads = () ; 

open (IN, "$readfile") or die "oops!\n" ;
while (<IN>) {
    chomp;
    $reads{$_}++ ; 

}



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

    
    my $name = $_ ;
    my $seqname = '' ; 
    
    if ( $name =~ /^\@(\S+)/ ) {
	$seqname = $1 ; 
    }
    
    my $seq = <IN> ;
    my $tmp = <IN> ;
    my $qual = <IN> ;

    if ( $reads{$seqname} ) {

    }
    else {
    
	print OUT "$name$seq$tmp$qual" ; 
    
    }


    
    
}




