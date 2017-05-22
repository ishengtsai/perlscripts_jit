#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';




if (@ARGV != 1) {
    print "$0 fastq.gz|fastq \n" ; 
    exit ;
}

my $filenameA = $ARGV[0];


open OUT, ">", "$filenameA.merged.fake.fastq" or die "doadpsaodap\n" ; 
print "Start reading $filenameA...\n" ; 

if ( $filenameA=~ /.gz$/ ) {
    open (IN, "zcat $filenameA |") or die "oops!\n" ;
}
else {
    open (IN, "$filenameA") or die "oops!\n" ;
}

my $totalreads = 0; 

my $sample = 1 ;
my $count = 1  ; 


while (<IN>) {

    my $name = $_ ;
    my $seq = <IN> ;
    my $tmp = <IN> ;
    my $qual = <IN> ;

    

    print OUT '@' . "Sample$sample.$count\n" ; 
    print OUT "$seq$tmp$qual" ; 

    if ( $sample == 1 ) {
	print OUT '@' . "Sample10.$count\n" ;
	print OUT "$seq$tmp$qual" ;
    }
    
    $count++ ;
    $sample++ if $count == 1001 ; 
    $count = 1 if $count == 1001 ;
    last if $sample == 4 ; 

}

close(IN) ; 
close(OUT) ; 




