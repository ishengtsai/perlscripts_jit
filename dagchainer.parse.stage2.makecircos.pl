#!/usr/bin/perl -w
use strict;



if (@ARGV != 1) {
	print "$0 coords \n\n" ;

	exit ;
}

my $file = shift @ARGV;


my $count = 10 ; 

open OUT1, ">", "$file.circos.chr1" or die "ooops\n" ; 
open OUT2, ">", "$file.circos.chr2" or die "ooops\n" ;
open OUT3, ">", "$file.circos.chrX" or die "ooops\n" ;
open OUT4, ">", "$file.circos.chrUN" or die "ooops\n" ;





## read the fastas
open (IN, "$file") or die "oops!\n" ;
while (<IN>) {
	

    chomp ; 
    next if /^\#\#/ ; 
    my @r = split /\s+/, $_ ; 

    if ( $r[1] =~ /Chr1/ ) {
	print OUT1 "segdup$count $r[0] $r[6] $r[11]\n" ;
	print OUT1 "segdup$count $r[1] $r[14] $r[19]\n" ; 
    }    
    elsif ( $r[1] =~ /Chr2/ ) {
        print OUT2 "segdup$count $r[0] $r[6] $r[11]\n" ;
        print OUT2 "segdup$count $r[1] $r[14] $r[19]\n";
    }
    elsif ( $r[1] =~ /ChrX/ ) {
        print OUT3 "segdup$count $r[0] $r[6] $r[11]\n" ;
        print OUT3 "segdup$count $r[1] $r[14] $r[19]\n";
    }
    elsif ( $r[1] =~ /Chr00/ ) {
        print OUT4 "segdup$count $r[0] $r[6] $r[11]\n" ;
        print OUT4 "segdup$count $r[1] $r[14] $r[19]\n";
    }
    elsif ( $r[0] =~ /Chr1/ ) {
        print OUT1 "segdup$count $r[0] $r[6] $r[11]\n" ;
        print OUT1 "segdup$count $r[1] $r[14] $r[19]\n" ;
    }
    elsif ( $r[0] =~ /Chr2/ ) {
        print OUT2 "segdup$count $r[0] $r[6] $r[11]\n" ;
        print OUT2 "segdup$count $r[1] $r[14] $r[19]\n";
    }
    elsif ( $r[0] =~ /ChrX/ ) {
        print OUT3 "segdup$count $r[0] $r[6] $r[11]\n" ;
        print OUT3 "segdup$count $r[1] $r[14] $r[19]\n";
    }
    elsif ( $r[0] =~ /Chr00/ ) {
        print OUT4 "segdup$count $r[0] $r[6] $r[11]\n" ;
        print OUT4 "segdup$count $r[1] $r[14] $r[19]\n";
    }



    $count += 10 ; 

}

