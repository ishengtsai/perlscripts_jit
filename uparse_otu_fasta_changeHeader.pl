#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';




if (@ARGV != 1) {
    print "$0 fasta \n" ;
	exit ;
}

my $filenameA = $ARGV[0];



open OUT, ">", "$filenameA.OTUheader.changed.fa" ;

open (IN, "$filenameA") or die "oops!\n" ;

my $count = 1 ; 

	while (<IN>) {



	    if (/^>(\S+)/) {
		my $seqname = $1 ; 

		$seqname =~ s/tax=d/tax=k/ ; 
		$seqname =~ s/\(\d+\.\d+\)//gi ; 
		
		print "changed: $seqname\n" ; 

		print OUT ">$seqname\n" ; 

	    }
	    else {
		chomp; 
		print OUT "$_\n" ;

	    }

	}

close(IN) ;

print "done! $filenameA.OTUheader.changed.fa produced\n" ; 


