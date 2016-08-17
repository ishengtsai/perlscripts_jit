#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';




if (@ARGV != 1) {
    print "$0 singleline.fasta \n" ; 
	exit ;
}

my $filenameA = $ARGV[0];


my %gene_present = () ; 

open (IN, "$filenameA") or die "oops!\n" ;

	my $read_name = '' ;
	my $read_seq = '' ;

open OUT, ">", "$filenameA.nr.fa" or die "odpsodsss\n" ; 
open OUTID, ">", "$filenameA.id.key" or die "dakdlakdkalskd\n" ; 

my %id = () ; 
my $proteinNO = 0 ; 

my %proteinfound = () ; 
my $proteinfoundNO = 0 ; 

while (<IN>) {

    if (/^>(\S+)\s+\S+\s+(\S+)/) {

	if ( $gene_present{$2} ) {
	    print "redundant! $1 $2\n" ; 
	}
	else {
	    $gene_present{$2}++ ; 

	    $id{$1} = "$2" ; 
	    $proteinNO++ ; 

	    print OUT ">$1\n" ; 
	    my $seq = <IN> ; 
	    print OUT "$seq" ; 

	    print OUTID "$1\t$2\n" ; 
	}

    }

}

close(IN) ;

