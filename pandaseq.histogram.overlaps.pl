#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';

if (@ARGV != 1) {
    print "$0 logfile \n" ; 


    exit ;
}

my $logfile = shift ; 


open OUT, ">", "$logfile.histogram" or die "doasodpad\n" ; 



open (IN, "$logfile") or die "dadoapdao\n" ; 

my @bases = () ; 

while (<IN>) {

    next unless /OVERLAPS/ ; 

    chomp; 
    my @r = split /\s+/, $_ ; 

    for (my $i = 3 ; $i < @r ; $i++ ) {
	$bases[$i-3] = $r[$i] ; 

    }



}
close(IN) ; 

for (my $i = 0 ; $i < @bases ; $i++ ) {
    print OUT "$i\t$bases[$i]\n" ; 

}
