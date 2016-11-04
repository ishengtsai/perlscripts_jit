#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV != 1) {
    print "$0 emapper.Prokka_CY.faa.refined_hits.annot\n" ;
    exit ;
}

my $file = shift ;
my $out = shift ;

open OUT, ">", "$file.topGO" or die "oooop!\n" ;
open (IN, "$file") or die "can't openfile: $!\n" ;

my %GOterms = ();

while (<IN>) {

    next if /^#/ ;
    next unless /GO\:/ ; 

    chomp;
    my @r = split /\t/, $_ ;

    if ( $r[0] && $r[6] ) {
	
	print OUT "$r[0]\t$r[6]\n" ; 

    }
    else {
	print "Special case: $_\n" ; 
    }


}

for my $gene ( sort keys %GOterms ) {
    print OUT "$gene $GOterms{$gene}\n" ;
}


print "all done! a non redundant GO file: $file.topGO  is produced\n" ;
