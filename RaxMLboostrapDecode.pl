#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';




if (@ARGV != 2) {
    print "$0 boostraptree decode \n" ;
	exit ;
}

my $filenameA = $ARGV[0];
my $decodefile = $ARGV[1] ; 



open (IN, "$filenameA") or die "oops!\n" ;
system("rm $filenameA.decoded.tree") if -e "$filenameA.decoded.tree" ; 

my $count = 0  ; 
while (<IN>) {


    open OUT, ">", "zzz.tmp" or die "oops\n" ; 
    print OUT "$_" ; 
    close(OUT) ; 

    system("t_coffee -other_pg seq_reformat -decode $decodefile -in zzz.tmp >> $filenameA.decoded.tree") ; 

    $count++ ; 
    print "done $count\n " ; 
}
close(IN) ; 

print "all done!\n" ; 
