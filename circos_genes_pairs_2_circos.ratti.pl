#!/usr/bin/perl -w
use strict;



if (@ARGV != 1) {
	print "$0 coords \n\n" ;

	exit ;
}

my $file = shift @ARGV;


my $count = 10 ; 

open OUT1, ">", "$file.singlecopy.circos.chr1" or die "ooops\n" ; 
open OUT2, ">", "$file.singlecopy.circos.chr2" or die "ooops\n" ;
open OUT3, ">", "$file.singlecopy.circos.chrX" or die "ooops\n" ;
open OUT4, ">", "$file.singlecopy.circos.chrUN" or die "ooops\n" ;





## read the fastas
open (IN, "$file") or die "oops!\n" ;
while (<IN>) {
	

    chomp ; 
    my @r = split /\s+/, $_ ; 

    if ( $r[1] =~ /Chr1/ ) {
	print OUT1 "segdup$count $r[1] $r[2] " . ($r[2]+1) . " \n" ; 
	print OUT1 "segdup$count $r[4] $r[5] " . ($r[5]+1) . " \n" ;
    }    
    if ( $r[1] =~ /Chr2/ ) {
        print OUT2 "segdup$count $r[1] $r[2] " . ($r[2]+1) . " \n" ;
        print OUT2 "segdup$count $r[4] $r[5] " . ($r[5]+1) . " \n" ;
    }
    if ( $r[1] =~ /ChrX/ ) {
        print OUT3 "segdup$count $r[1] $r[2] " . ($r[2]+1) . " \n" ;
        print OUT3 "segdup$count $r[4] $r[5] " . ($r[5]+1) . " \n" ;
    }
    if ( $r[1] =~ /Chr00/ ) {
        print OUT4 "segdup$count $r[1] $r[2] " . ($r[2]+1) . " \n" ;
        print OUT4 "segdup$count $r[4] $r[5] " . ($r[5]+1) . " \n" ;
    }

    $count += 10 ; 

}

