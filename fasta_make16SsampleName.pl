#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';




if (@ARGV != 2) {
    print "$0 fasta SampleName\n" ;
	exit ;
}

my $filenameA = $ARGV[0];
my $sample = $ARGV[1] ; 


open OUT, ">", "$sample.16S.fa" ;

open (IN, "$filenameA") or die "oops!\n" ;

my $count = 0 ; 

	while (<IN>) {


	    if (/^>(\S+)/) {
		print OUT ">$sample" . "_$count $1 orig_bc=AAAAAAAAAAAA new_bc=AAAAAAAAAAAA bc_diffs=0\n" ; 
		$count++ ; 
	    }
	    else {
		print OUT "$_" ; 
	    }

	}

close(IN) ;

print "done! A total of $count reads in $sample.16S.fa!\n" ;




