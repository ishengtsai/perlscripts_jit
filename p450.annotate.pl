#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV != 2) {
    print "$0 fasta blastoutput\n" ; 
	exit ;
}

my $fasta = $ARGV[0] ; 
my $blastoutput = $ARGV[1] ; 


my @seqnames = () ;


open (IN, "$fasta") or die "daodapdoa\n" ; 

    
    
while (<IN>) {
    chomp; 

    if ( /^\>(\S+)/ ) {
	push(@seqnames, $1) ; 
    }
}
close (IN) ; 


my %annotate = () ; 

open (IN, "$blastoutput") or die "daodapdoa\n" ;

while (<IN>) {
    chomp;
    my @r= split /\s+/, $_ ;

    next if  $r[2] < 40 ;  

    if ( $annotate{$r[0]} ) {
	next ; 
    }
    else {
	$annotate{$r[0]} = "$r[1]\t$r[2]" ; 
    }
}


foreach my $gene (@seqnames) {
    if ( $annotate{$gene} ) {
	print "$gene\t$annotate{$gene}\n" ; 
    }
    else {
	print "$gene\tunknown\tNA\n"
    }

}
