#!/usr/bin/perl -w
use strict;
use warnings;




my $largest = 0;
my $contig = '';


if (@ARGV != 2) {
    print "$0 ref.fa.out.gff consensus_copy\n" ; 
	exit ;
}

my $filenameA = shift @ARGV;
my $consensus = shift @ARGV;




my %coverage = () ; 



open (IN, "$filenameA") or die "oops!\n" ;

while (<IN>) {
    next if /^\#/ ;

    s/\"//gi ;
    s/Motif://gi ; 
    my @r = split /\s+/, $_ ;

    next unless $r[9] eq $consensus ; 
    #print "$r[9]\t$r[10]\t$r[11]\n" ; 

    for (my $i = $r[10] ; $i < ($r[11]+1) ; $i++) {
	$coverage{$i}++ ; 
    }
    

}
close(IN) ; 


for my $pos (sort {$a <=> $b} keys %coverage) {

    print "$pos\t$coverage{$pos}\n" ; 
    
}

