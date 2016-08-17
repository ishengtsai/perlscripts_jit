#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';




if (@ARGV != 1) {
    print "$0 fasta \n" ;
	exit ;
}

my $filenameA = $ARGV[0];

system("fasta2singleLine.pl $filenameA zz.tmp.fa") ; 

open OUT, ">", "$filenameA.nr.fa" ;
open (IN, "zz.tmp.fa") or die "oops!\n" ;

my $count = 1 ; 

my %found = () ; 

while (<IN>) {
    if (/^>.+gene:(\S+)/) {
	my $seqname = $1 ; 
	$seqname =~ s/\|/./gi ; 
	$seqname =~ s/\#/./gi ; 
	
	my $seq = <IN> ; 


	if ( $found{$seqname} ) {
	    print "$seqname already found! isoform skipped\n" ; 
	}
	else {
	    $found{$seqname}++ ; 
	    print OUT ">$seqname\n$seq" ; 
	    
	}
	
    }
}

close(IN) ;




