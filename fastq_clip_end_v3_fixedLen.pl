#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';




if (@ARGV != 3) {
    print "$0 fastq.gz start finish \n" ;
    exit ;
}

my $filenameA = $ARGV[0];
my $start = $ARGV[1] ;
my $end = $ARGV[2] ;

my $fixedlen = $end - $start + 1 ; 

open OUT, ">", "$filenameA.$start.$end.fastq" or die "oooops!\n" ;


if ( $filenameA=~ /.gz$/ ) {
    open (IN, "zcat $filenameA |") or die "oops!\n" ;
}
else {
    open (IN, "$filenameA") or die "oops!\n" ;
}


my $excluded = 0 ; 
my $total = 0 ; 

while (<IN>) {
    $total++ ; 
    
    my $name  ;

    if ( /(^\S+)/ ) {
	$name = "$1\n" ; 
    }
    
    my $seq = <IN> ;
    chomp($seq) ; 
    my $tmp = <IN> ;
    my $qual = <IN> ;
    my $finalend = 0 ;

    if ( length($seq) < $end ) {
        $finalend = length($seq) ;
    }
    else {
        $finalend = $end ;
    }

    my $len = $finalend - $start + 1 ;
    my $start_zero_based = $start - 1 ;
    my $seq_tmp = substr($seq, $start_zero_based, $len ) ;
    my $qual_tmp = substr($qual, $start_zero_based, $len ) ;

    if ( $fixedlen > $len ) {
	$excluded++ ;
	next ; 
    }



    $seq_tmp =~ s/ //gi ;
    $qual_tmp =~ s/ //gi ;
    chomp($seq_tmp) ;
    chomp($qual_tmp) ;

    #print "$name$seq_tmp\n$tmp$qual_tmp\n" ;
    print OUT "$name$seq_tmp\n$tmp$qual_tmp\n" ;



#    last;


}

close(IN) ;


print "$total total num reads\n" ;
print "$excluded reads were excluded\n" ; 
