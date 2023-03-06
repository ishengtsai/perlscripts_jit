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


my $count = 1 ; 
while (<IN>) {

    my $name = $_ ;

    $name =~ s/^\@/\>/ ;

    if ( $name =~ /^(\S+)/ ) {
	$name = $1 ; 
    }
    
    my $seq = <IN> ;
    my $tmp = <IN> ;
    my $qual = <IN> ;

    print "\@Read_$count\n$seq$tmp$qual" ; 
    $count++ ; 
}

close(IN) ; 
