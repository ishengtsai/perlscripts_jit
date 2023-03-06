#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV != 3) {
	print "$0 fasta gff overlap_len \n\n" ;
	exit ;
}

my $filenameA = $ARGV[0];
my $contig_name = $ARGV[1];
my $overlap = $ARGV[2] ; 
my %reads = () ;

open (IN, "$contig_name") or die "oops!\n" ;


while (<IN>) {
    chomp ;
    my @line = split /\s+/ , $_ ;
    $line[9] =~ s/\"//gi ;
    $line[9] =~ s/Motif\:// ;

    if ( $line[21] >= $overlap ) {
	#print "$line[9] overlap $line[21] bp !\n" ;	
	$reads{$line[9]}++ ;
	
    }
}
close(IN) ;


for my $oldrepeat (sort  keys %reads ) {
    print "$oldrepeat\t$reads{$oldrepeat}\n" ; 
} 



open (IN, "$filenameA") or die "oops!\n" ;
open OUT, ">", "$filenameA.overlapWithLTRfull.excluded.fa" or die "daodpoad\n" ; 

my $read_name = '' ;
my $read_seq = '' ;
my $read_type = '' ; 


while (<IN>) {
    if (/^>(\S+)(\#\S+)/) {
	$read_name = $1 ;
	$read_type = $2 ; 
	$read_seq = "" ;

		
		while (<IN>) {

			if (/^>(\S+)(\#\S+)/) {
			    
			    if ( $reads{$read_name} ) {
			    }
			    else {
				print OUT ">$read_name$read_type\n$read_seq\n" ; 
			    }

			    $read_name = $1 ;
			    $read_type = $2 ; 
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

if ( $reads{$read_name} ) {
}
else {
    print OUT ">$read_name\n$read_seq\n" ;
}

print "all done! $filenameA.overlapWithLTRfull.excluded.fa produced\n" ; 
