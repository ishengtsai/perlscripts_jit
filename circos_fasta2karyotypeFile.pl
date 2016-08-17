#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV != 3) {
    print "$0 fasta colour minlen\n" ; 
	exit ;
}

my $filenameA = $ARGV[0];
my $colour = $ARGV[1] ; 
my $minlen = $ARGV[2]  ;

open (IN, "$filenameA") or die "oops!\n" ;

	my $read_name = '' ;
	my $read_seq = '' ;

	while (<IN>) {
	    if (/^>(\S+)/) {
		$read_name = $1 ;
		$read_name =~ s/\#/\./gi ;
		$read_seq = "" ;
		
		while (<IN>) {

			if (/^>(\S+)/) {
			    
			    #print "$read_name\t" . length($read_seq) . "\n" ;

			    if ( length($read_seq) > $minlen ) {
				my $tmp = $1 ; 
				print "chr - $read_name $read_name 0 " . length($read_seq) . " $colour\n" ;
			    }

			    $read_name = $1 ;
			    $read_name =~ s/\#/\./gi ;
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

#print "$read_name\t" . length($read_seq) . "\n" ;

if ( length($read_seq) > $minlen ) {
    print "chr - $read_name $read_name 0 " . length($read_seq) . " $colour\n" ;
}


