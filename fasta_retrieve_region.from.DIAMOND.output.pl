#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV < 2) {
	print "fasta_retrieve_region.pl fasta Region\n\n" ;
	exit ;
}

my $filenameA = shift @ARGV;

my $region = shift @ARGV;



my $contig_name = '';
my $start = '';
my $end = '';

#ref2.scaff0016:900000-950200
if ( $region =~ /(\S+)\:(\d+)-(\d+)/ ) {
    $contig_name = $1 ;
    $start = $2 ;
    $end = $3 ; 
}


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


print ">$contig_name:$start-$end\n" ;
$region = substr($contig_seq{$contig_name}, ($start-1), ($end-$start+1) ) ;
print "$region\n" ;




