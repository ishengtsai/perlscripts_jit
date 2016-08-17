#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV < 3) {
	print "fasta_retrieve_region.pl fasta contig_name all[0or1] start finish\n\n" ;
	exit ;
}

my $filenameA = shift @ARGV;
my $contig_name = shift @ARGV;
my $all = shift @ARGV;
my $start = shift @ARGV;
my $end = shift @ARGV;



my %contig_seq = () ;

open (IN, "$filenameA") or die "oops!\n" ;

	my $read_name = '' ;
	my $read_seq = '' ;

	while (<IN>) {
	    if (/^>(\S+)/) {
		$read_name = $1 ;
		$read_seq = "" ;
		
		while (<IN>) {

			if (/^>(\S+)/) {
			    
				$contig_seq{$read_name} = $read_seq ;

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
$contig_seq{$read_name} = $read_seq ;


if ($all == 0 ) {
	print ">$contig_name.$start.$end\n" ;
	my $region = substr($contig_seq{$contig_name}, ($start-1), ($end-$start+1) ) ;
	print "$region\n" ;

}
else {
    print ">$contig_name\n" ; 
    print "$contig_seq{$contig_name}\n" ;
}


