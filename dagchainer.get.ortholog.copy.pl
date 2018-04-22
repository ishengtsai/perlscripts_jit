#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';




if (@ARGV != 2) {
    print "$0 fasta \n" ;
	exit ;
}

my $filenameA = $ARGV[0];
my $numCopies = $ARGV[1] ; 


my %genes = () ; 
my %gene_synteny_count = () ; 

open (IN, "$filenameA") or die "oops!\n" ;


open OUT, ">", "$filenameA.duplicatePair" or die "daosdpaodspao\n" ; 

while (<IN>) {

    chomp; 
    next if /^\#/ ; 
    
    my @r = split /\s+/ , $_ ;

    $genes{ $r[1] }{ $r[5] } ++ ; 
    $gene_synteny_count{ $r[1] } ++ ; 


}


my %ortholog_counts = () ; 

for my $gene (sort keys  %gene_synteny_count ) {

    #print "$gene\t$gene_synteny_count{$gene}\n" ; 

    $ortholog_counts{ $gene_synteny_count{$gene} } ++ ;

    if ( $gene_synteny_count{$gene} <= $numCopies ) {
	for my $genepair ( keys % { $genes{$gene} } ) {
	    print OUT "$gene\t$genepair\n" ;
	}
    }
}


for my $count ( sort keys %ortholog_counts  ) {

    print "$count\t$ortholog_counts{$count}\n" ; 

}


