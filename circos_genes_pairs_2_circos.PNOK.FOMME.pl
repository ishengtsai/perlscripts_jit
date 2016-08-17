#!/usr/bin/perl -w
use strict;



if (@ARGV != 2) {
    print "$0 setfile coords \n" ; 
	print "will parse out genes with smaller scaffolds\n" ;
	exit ;
}

my $setfile = shift @ARGV;
my $file = shift @ARGV;


my $count = 10 ; 

open OUT1, ">", "$file.singlecopy.circos.scaff1" or die "ooops\n" ; 
open OUT2, ">", "$file.singlecopy.circos.scaff2" or die "ooops\n" ;
open OUT3, ">", "$file.singlecopy.circos.scaff3" or die "ooops\n" ;
open OUT4, ">", "$file.singlecopy.circos.scaff4" or die "ooops\n" ;
open OUT5, ">", "$file.singlecopy.circos.scaff5" or die "ooops\n" ;
open OUT6, ">", "$file.singlecopy.circos.scaff6" or die "ooops\n" ;


my %set = () ; 

open (IN, "$setfile") or die "oops!\n" ;
while (<IN>) {
    if ( /(^\S+)/ ) {
        $set{$1}++  ;
    }
}
close(IN) ;


## read the fastas
open (IN, "$file") or die "oops!\n" ;
while (<IN>) {
	

    chomp ; 
    my @r = split /\s+/, $_ ; 

    if ( $set{$r[1]} && $set{$r[4]} ) {

	if ( $r[4] eq 'PNOK.scaff0001' ) {
	    print OUT1 "segdup$count $r[1] $r[2] " . ($r[2]+1) . " \n" ; 
	    print OUT1 "segdup$count $r[4] $r[5] " . ($r[5]+1) . " \n" ;
	}    
        elsif ( $r[4] eq 'PNOK.scaff0004' ) {
            print OUT1 "segdup$count $r[1] $r[2] " . ($r[2]+1) . " \n" ;
            print OUT1 "segdup$count $r[4] $r[5] " . ($r[5]+1) . " \n" ;
        }
        elsif ( $r[4] eq 'PNOK.scaff0005' ) {
            print OUT1 "segdup$count $r[1] $r[2] " . ($r[2]+1) . " \n" ;
            print OUT1 "segdup$count $r[4] $r[5] " . ($r[5]+1) . " \n" ;
        }
        elsif ( $r[4] eq 'PNOK.scaff0010' ) {
            print OUT1 "segdup$count $r[1] $r[2] " . ($r[2]+1) . " \n" ;
            print OUT1 "segdup$count $r[4] $r[5] " . ($r[5]+1) . " \n" ;
        }
	elsif ( $r[4] eq 'PNOK.scaff0003' ) {
            print OUT2 "segdup$count $r[1] $r[2] " . ($r[2]+1) . " \n" ;
            print OUT2 "segdup$count $r[4] $r[5] " . ($r[5]+1) . " \n" ;
        }
	elsif ( $r[4] eq 'PNOK.scaff0011' ) {
            print OUT2 "segdup$count $r[1] $r[2] " . ($r[2]+1) . " \n" ;
            print OUT2 "segdup$count $r[4] $r[5] " . ($r[5]+1) . " \n" ;
        }
	elsif ( $r[4] eq 'PNOK.scaff0002' ) {
            print OUT3 "segdup$count $r[1] $r[2] " . ($r[2]+1) . " \n" ;
            print OUT3 "segdup$count $r[4] $r[5] " . ($r[5]+1) . " \n" ;
        }
	elsif ( $r[4] eq 'PNOK.scaff0008' ) {
            print OUT3 "segdup$count $r[1] $r[2] " . ($r[2]+1) . " \n" ;
            print OUT3 "segdup$count $r[4] $r[5] " . ($r[5]+1) . " \n" ;
        }
	elsif ( $r[4] eq 'PNOK.scaff0012' ) {
            print OUT3 "segdup$count $r[1] $r[2] " . ($r[2]+1) . " \n" ;
            print OUT3 "segdup$count $r[4] $r[5] " . ($r[5]+1) . " \n" ;
        }
	elsif ( $r[4] eq 'PNOK.scaff0009' ) {
            print OUT4 "segdup$count $r[1] $r[2] " . ($r[2]+1) . " \n" ;
            print OUT4 "segdup$count $r[4] $r[5] " . ($r[5]+1) . " \n" ;
        }
	elsif ( $r[4] eq 'PNOK.scaff0007' ) {
	    print OUT5 "segdup$count $r[1] $r[2] " . ($r[2]+1) . " \n" ;
	    print OUT5 "segdup$count $r[4] $r[5] " . ($r[5]+1) . " \n" ;
	}
	elsif ( $r[4] eq 'PNOK.scaff0006' ) {
	    print OUT6 "segdup$count $r[1] $r[2] " . ($r[2]+1) . " \n" ;
	    print OUT6 "segdup$count $r[4] $r[5] " . ($r[5]+1) . " \n" ;
	}
	$count += 10 ;
    }




}

