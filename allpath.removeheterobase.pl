#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV != 1) {
	print "$0 fasta\n\n" ;
	exit ;
}

my $filenameA = $ARGV[0];

my %seqs = () ; 

open (IN, "$filenameA") or die "oops!\n" ;

	my $read_name = '' ;
	my $read_seq = '' ;

	while (<IN>) {
	    if (/^>(\S+)/) {
		$read_name = $1 ;
		$read_seq = "" ;
		
		while (<IN>) {

			if (/^>(\S+)/) {
			    
			    $seqs{$read_name} = $read_seq ; 
			    
			    $read_name = $1 ;
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

$seqs{$read_name} = $read_seq ;


for my $seqname (sort keys %seqs ) {

    my $seq = $seqs{$seqname} ; 

    $seq =~ s/R/A/gi ; 
    $seq =~ s/Y/C/gi ; 
    $seq =~ s/S/G/gi ;
    $seq =~ s/W/T/gi ;
    $seq =~ s/K/G/gi ;
    $seq =~ s/M/A/gi ;
    $seq =~ s/B/G/gi ;
    $seq =~ s/D/A/gi ;
    $seq =~ s/H/T/gi ;
    $seq =~ s/V/A/gi ;

    print ">$seqname\n$seq\n" ; 

}
