#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV != 2) {
    print "$0 fasta result\n" ;
	exit ;
}

my $filenameA = $ARGV[0];
my $result = $ARGV[1] ;


my %seqs = () ;

open (IN, "$filenameA") or die "oops!\n" ;

	my $read_name = '' ;
	my $read_seq = '' ;

	while (<IN>) {
	    if (/^>(\S+)/) {
		$read_name = "$1" ;
		$read_seq = "" ;
		
		while (<IN>) {
		    
		    if (/^>(\S+)/) {
			
			$seqs{$read_name} = $read_seq ;
			
			$read_name = "$1" ;
			$read_seq = "" ;
			
			
			
		    }
		    else {
			chomp ;
			$read_seq .= $_ ;
		    }
		    
		    
		}
		
	    }
}

close(IN) ;

$seqs{$read_name} =$read_seq ;


open (IN, "$result") or die "oops" ;

open OUT, ">", "$result.fa" or die "oooooops\n" ;

while (<IN>) {




    if (/Chain\s+(\S+)\s+(\d+)-(\d+)\s+(\S+)\s+(\d+)-(\d+)/) {

	print "$1\t$2\t$3\t$4\t$5\t$6\n" ;

	my $seq = substr ($seqs{$4}, $5-1 , ($6-$5+1)) ;

	print OUT ">$1.$2-$3.$4.$5-$6\n$seq\n" ;

    }





}
