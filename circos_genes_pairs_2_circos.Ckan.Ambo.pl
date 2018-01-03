#!/usr/bin/perl -w
use strict;



if (@ARGV != 1) {
	print "$0 coords \n" ;
	print "will parse out genes with smaller scaffolds\n" ;
	exit ;
}

my $file = shift @ARGV;

my $count = 10 ; 

open OUT1, ">", "$file.singlecopy.circos" or die "ooops\n" ; 






## read the fastas
open (IN, "$file") or die "oops!\n" ;
while (<IN>) {
	

    chomp ; 
    my @r = split /\s+/, $_ ; 


    print OUT1 "$r[1] $r[2] " . ($r[2]+1) . " $r[4] $r[5] " . ($r[5]+1) . "\n" ;
	



    $count += 10 ; 

}

