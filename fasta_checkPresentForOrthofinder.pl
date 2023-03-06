#!/usr/bin/perl -w
use strict;





if (@ARGV != 2) {
    print "$0 A.fasta B.fasta \n" ;
    print "check if all the A.fasta names are also present in B.fasta\n" ; 
	exit ;
}

my $filenameA = $ARGV[0];
my $filenameB = $ARGV[1] ; 



open (IN, "$filenameA") or die "oops!\n" ;

my %seqA = () ; 

while (<IN>) {

    
    if (/^>(.+)/) {
	$seqA{$1}++ ; 
    }
    
    
}
close(IN) ;
print "$filenameA read!\n" ; 

open (IN, "$filenameB") or die "oops!\n" ;

my %seqB = () ;

while (<IN>) {


    if (/^>(.+)/) {
        $seqB{$1}++ ;
    }


}
close(IN) ;
print "$filenameB read!\n" ;


my $seq_num = 0 ; 
for my $name (keys %seqA) {

    if ( $seqB{$name} ) {
	$seq_num++ ; 
    }
    else {
	print "$name not found in $filenameB!!!\n" ;
	#last ; 
    }


	
}


print "all done or exited! $seq_num read!  \n" ; 
