#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV != 1) {
	print "$0 fasta\n\n" ;
	exit ;
}

my $filenameA = $ARGV[0];

my %fastas = () ; 

open (IN, "$filenameA") or die "oops!\n" ;

	my $read_name = '' ;
	my $read_seq = '' ;

	while (<IN>) {
	    if (/^>(\S+)/) {
		$read_name = $1 ;
		$read_seq = "" ;
		
		while (<IN>) {

			if (/^>(\S+)/) {
			    
			    #print "$read_name\t" . length($read_seq) . "\n" ;

			    if ( $read_name eq 'unitig_0' ) {
				my $reorderedSeq = '' ;

				my $seq1 = substr ( $read_seq, 4909149 ) ; 
				my $seq2 = substr ( $read_seq, 0, 4909149 ) ; 
				$reorderedSeq = "$seq1$seq2" ; 

				print ">ChrI\n$reorderedSeq\n" ; 
			    }
			    else {
				print ">$read_name\n$read_seq\n"; 
			    }

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

if ( $read_name eq 'unitig_0' ) {
    
}
else {
    print ">$read_name\n$read_seq\n";
}
