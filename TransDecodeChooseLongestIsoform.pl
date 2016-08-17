#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';




if (@ARGV != 1) {
    print "$0 Trinity.fasta.transdecoder.SL.pep \n" ;
    print "has to be singleline..\n" ; 
	exit ;
}

my $filenameA = $ARGV[0];




open (IN, "$filenameA") or die "oops!\n" ;

my %longestisoform = ()  ;
my %isoformFasta = () ; 


while (<IN>) {


    if ( />(\S+)_i\d+\|m\..+len\:(\d+)/ ) { 

	my $seqname = $1 ; 
	my $seqlen = $2 ; 
	my $seq = <IN> ; 
	
	if ( $isoformFasta{$seqname} ) {
	    if ( $seqlen > $longestisoform{$seqname} ) {
		$isoformFasta{$seqname} = $seq ;
		$longestisoform{$seqname} =$seqlen;
	    }
	}
	else {
	    $isoformFasta{$seqname} = $seq ; 
	    $longestisoform{$seqname} = $seqlen ; 
	}

    }
    


}
close(IN) ; 

for my $seqname (sort keys %isoformFasta ) {
    print ">$seqname\n$isoformFasta{$seqname}" ; 
}
