#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV != 1) {
	print "$0 fasta \n" ;
	exit ;
}

my $filenameA = $ARGV[0];



open (IN, "$filenameA") or die "oops!\n" ;

my %fa = () ; 

	my $read_name = '' ;
	my $read_seq = '' ;

	while (<IN>) {
	    if (/^>(\S+)/) {
		$read_name = $1 ;
		$read_seq = "" ;
		$read_name =~ s/\#/\./gi ; 
		
		while (<IN>) {

			if (/^>(\S+)/) {
			    $fa{$read_name} = $read_seq ; 
		    
			    $read_name = $1 ;
			    $read_seq = "" ;
			    $read_name =~ s/\#/\./gi ;


			}
			else {
			    chomp ;
			    $read_seq .= $_ ;
			}


		}

	    }
	}

close(IN) ;

$fa{$read_name} = $read_seq;


#12268-14825
#1-9709
#9710-12267

#seed2 500 72696
#seed4 5058 59378
#seed3 43627 52100

my $seqpart1 = substr($fa{"Sp34MtDNA"}, 9941) ; 
my $seqpart2 = substr($fa{"Sp34MtDNA"}, 0, 9941 ) ; 


my $newseq = $seqpart1 . $seqpart2  ; 

print ">merged\n$newseq\n" ; 
