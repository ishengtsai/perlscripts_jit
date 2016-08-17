#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV != 2) {
	print "$0 fasta excluded_list\n\n" ;
	exit ;
}

my $filenameA = $ARGV[0];
my $contig_name = $ARGV[1];
my %reads = () ;

open (IN, "$contig_name") or die "oops!\n" ;


while (<IN>) {
    chomp ;
    my @line = split /\s+/ , $_ ;
    $reads{$line[0]}++ ;
}
close(IN) ;



open (IN, "$filenameA") or die "oops!\n" ;
open OUT, ">", "$filenameA.excluded.fa" or die "daodpoad\n" ; 

	my $read_name = '' ;
	my $read_seq = '' ;

	while (<IN>) {
	    if (/^>(\S+)/) {
		$read_name = $1 ;
		$read_seq = "" ;
		$read_name =~ s/\#/\./gi ; 
		
		while (<IN>) {

			if (/^>(\S+)/) {
			    
			    if ( $reads{$read_name} ) {
			    }
			    else {
				print OUT ">$read_name\n$read_seq\n" ; 
			    }

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

if ( $reads{$read_name} ) {
}
else {
    print OUT ">$read_name\n$read_seq\n" ;
}

print "all done! $filenameA.excluded.fa produced\n" ; 
