#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV != 2) {
    print "$0 fasta len\n\n" ;
    print "Only swap one fasta at a time!\n" ; 
	exit ;
}

my $filenameA = $ARGV[0];
my $pos = $ARGV[1] ; 


open (IN, "$filenameA") or die "oops!\n" ;


	my $read_name = '' ;
	my $read_seq = '' ;

	while (<IN>) {
	    if (/^>(\S+)/) {
		$read_name = $1 ;
		$read_seq = "" ;
		$read_name =~ s/\#/\./gi ; 
		
		while (<IN>) {

			if (/^>(\S+)/) {

			    print "More than one seq!!!!! Exit...\n" ; 
			    die ; 
			}
			else {
			    chomp ;
			    $read_seq .= $_ ;
			}
		}

	    }
	}


my $new_seq = substr($read_seq, $pos - 1) . substr ($read_seq, 0, $pos) ; 


close(IN) ;





print ">$read_name\n" ;
print "$new_seq\n" ; 
