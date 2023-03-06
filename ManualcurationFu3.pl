#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV != 1) {
	print "$0 assemBeforeJoin \n\n" ;
	exit ;
}

my $filenameA = $ARGV[0];


my %combine = () ; 

open (IN, "$filenameA") or die "oops!\n" ;

	my $read_name = '' ;
	my $read_seq = '' ;

	while (<IN>) {
	    if (/^>(\S+)/) {
		$read_name = $1 ;
		$read_seq = "" ;
		
		while (<IN>) {

			if (/^>(\S+)/) {
			    my $newseq = $1 ;

			    if ( $read_name eq 'tig00000169' ) {
				$combine{$read_name} = substr($read_seq, 0 , 842471) ;
				$read_name = $newseq ;
				$read_seq = "" ;
				next; 
			    }
			    if ( $read_name eq 'tig00000001' ) {
				$combine{$read_name} = $read_seq ;
				$read_name = $newseq ;
				$read_seq = "" ;
				next;
			    }
			    if ( $read_name eq 'utg000004l.440215.505111' ) {
				$combine{$read_name} = $read_seq ;
				$read_name = $newseq ;
				$read_seq = "" ;
				next;
			    }
			    
			    
			    print ">$read_name\n$read_seq\n" ;
			    $read_name = $newseq ;
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

if ( $read_name eq 'utg000004l.440215.505111' ) {
    $combine{$read_name} = $read_seq ;

}




my $seq = $combine{'tig00000169'} . $combine{'utg000004l.440215.505111'} . $combine{'tig00000001'} ;

print ">tig00000001\n$seq\n" ; 


