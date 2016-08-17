#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV < 2) {
	print "fasta_exclude_subsets.pl fasta(single lined) list \n\n" ;
	exit ;
}

my $filenameA = shift @ARGV;
my $contig_name = shift @ARGV;
my %reads = () ;

open (IN, "$contig_name") or die "oops!\n" ;


while (<IN>) {
	chomp ;
	my @line = split /\s+/ , $_ ;
	$reads{$line[0]}++ ;
}
close(IN) ;

open (IN, "$filenameA") or die "oops!\n" ;

while (<IN>) {

    # print "$_" ;

    if (/^>(\S+)/) {

	my $seq_name = $1 ;
	my $seq = <IN> ;
	chomp($seq) ;
	
	unless ($reads{$seq_name} ) {
			print ">$seq_name\n" ;
			print "$seq\n" ;

	}


    }
	
    
    #last;


}

#print "\#\#the largest length is: $contig with $largest bp \n" ;
