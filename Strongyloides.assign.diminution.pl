#!/usr/bin/perl -w
use strict;







if (@ARGV != 4) {
    print "$0 assigned.chr.list v4list fa.len.txt diminutionfile \n" ; 
	exit ;
}

my $genelocfile = shift ; 
my $v4file = shift ; 
my $lenfile = shift ; 
my $filenameA = shift ; 


my %groups = () ; 

open (IN, $genelocfile) or die "dadakjdadjklad\n" ; 
while (<IN>) {
    chomp; 
    my @r = split /\s+/, $_ ; 
    $groups{$r[0]} = "$r[1]" ; 
}
close(IN) ; 

my %v4 = () ; 
open (IN, $v4file) or die "daidoaisdioas\n" ; 
while (<IN>) {
    chomp; 
    my @r = split /\s+/, $_ ;
    $v4{$r[0]} = "$r[1]" ; 


}

my %falen = () ; 
open (IN, $lenfile) or die "daidoaisdioas\n" ;
while (<IN>) {
    chomp;
    my @r = split /\s+/, $_ ;
    $falen{$r[0]} = "$r[1]" ;

}


open (IN, $filenameA) or die "can't open $filenameA\n" ; 


my %assigned = () ; 

while (<IN>) {
    next if /\#/ ; 

    chomp ;
    my @r = split /\s+/, $_ ; 

    my $diminution = "$r[1].$r[2]" ; 
    my $scaff = $v4{$r[0]} ; 

    if ( $groups{$scaff} ) {
	print "$r[0]\t$diminution\t$scaff\t$falen{$scaff}\t$groups{$scaff}\n" ; 
    }
    else {
	print "$r[0]\t$diminution\t$scaff\t$falen{$scaff}\tunplaced\n" ; 
    }
    

}
