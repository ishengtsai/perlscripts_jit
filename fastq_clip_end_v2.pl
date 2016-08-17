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


open OUT, ">", "$filenameA.$start.$end.fastq" or die "oooops!\n" ;


if ( $filenameA=~ /.gz$/ ) {
    open (IN, "zcat $filenameA |") or die "oops!\n" ;
}
else {
    open (IN, "$filenameA") or die "oops!\n" ;
}


while (<IN>) {

    my $name = $_ ;
    my $seq = <IN> ;
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

    #print "$finalend\n" ;


    my $seq_tmp = substr($seq, $start_zero_based, $len ) ;
    my $qual_tmp = substr($qual, $start_zero_based, $len ) ;


        #print "$name$seq$tmp$qual" ;


    $seq_tmp =~ s/ //gi ;
    $qual_tmp =~ s/ //gi ;
    chomp($seq_tmp) ;
    chomp($qual_tmp) ;

    #print "$name$seq_tmp\n$tmp$qual_tmp\n" ;
    print OUT "$name$seq_tmp\n$tmp$qual_tmp\n" ;



#    last;


}

close(IN) ;

