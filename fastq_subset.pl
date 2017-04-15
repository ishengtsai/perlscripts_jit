#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';




if (@ARGV != 1) {
    print "$0 fastq.gz|fastq \n" ; 
    exit ;
}

my $filenameA = $ARGV[0];






if ( $filenameA=~ /.gz$/ ) {
    open (IN, "zcat $filenameA |") or die "oops!\n" ;
}
else {
    open (IN, "$filenameA") or die "oops!\n" ;
}

my $line = 0; 
my $count = 1 ; 


while (<IN>) {
    $line++ ; 

    
    if ( $line == 1 ) {
	open OUT, '|-', "gzip > $filenameA.$count.fastq.gz" or die "doadpsaodap\n" ;
    }

    
    my $name = $_ ;
    my $seq = <IN> ;
    my $tmp = <IN> ;
    my $qual = <IN> ;

    print OUT "$name$seq$tmp$qual" ; 

    
    if ( $line == 45000000 ) {
	print "file $count done! \n" ; 
	$line = 0 ;
	$count++ ; 
	close(OUT) ; 
    }

    
    
}




