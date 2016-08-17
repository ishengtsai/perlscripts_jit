#!/usr/bin/perl -w
use strict;



if (@ARGV != 2) {
    print "$0 setfile coords \n" ; 

	exit ;
}


my $setfile = shift @ARGV;
my $file = shift @ARGV;





my $count = 10 ; 

open OUT1, ">", "$file.circos.ChrI" or die "ooops\n" ; 
open OUT2, ">", "$file.circos.ChrII" or die "dadoiasdioa\n" ; 
open OUT3, ">", "$file.circos.ChrIII" or die "dadoiasdioa\n" ;

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

	if ( $r[4] eq 'I' ) {
	    print OUT1 "segdup$count $r[1] $r[2] " . ($r[2]+1) . " \n" ;
            print OUT1 "segdup$count $r[4] $r[5] " . ($r[5]+1) . " \n" ;
	}
	elsif ( $r[4] eq 'II' ) {
            print OUT2 "segdup$count $r[1] $r[2] " . ($r[2]+1) . " \n" ;
            print OUT2 "segdup$count $r[4] $r[5] " . ($r[5]+1) . " \n" ;
	}
	elsif ( $r[4] eq 'III' ) {
            print OUT3 "segdup$count $r[1] $r[2] " . ($r[2]+1) . " \n" ;
            print OUT3 "segdup$count $r[4] $r[5] " . ($r[5]+1) . " \n" ;
	}

	$count += 10 ;

    }


}
close(IN); 
