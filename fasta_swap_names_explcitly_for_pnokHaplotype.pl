#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV != 2) {
	print "$0 fasta name_list\n\n" ;
	exit ;
}

my $filenameA = $ARGV[0];
my $contig_name = $ARGV[1];
my %reads = () ;

open (IN, "$contig_name") or die "oops!\n" ;


while (<IN>) {
    next if /^\#/ ; 
    chomp ;
    my @line = split /\s+/ , $_ ;
    $reads{$line[0]} = $line[1] ;
    $reads{"$line[0].0"} = "$line[1].haplo0" ;
    $reads{"$line[0].1"} = "$line[1].haplo1" ;
}
close(IN) ;



open (IN, "$filenameA") or die "oops!\n" ;
open OUT, ">", "$filenameA.changed.fa" or die "daodpoad\n" ; 

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
				print OUT ">$reads{$read_name}\n$read_seq\n" ;
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
    print OUT ">$reads{$read_name}\n$read_seq\n" ;
}
else {
    print OUT ">$read_name\n$read_seq\n" ;
}

print "all done! $filenameA.changed.fa produced\n" ; 
