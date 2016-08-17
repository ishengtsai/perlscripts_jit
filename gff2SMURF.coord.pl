#!/usr/bin/perl -w
use strict;



if (@ARGV != 1) {
    print "$0 gff \n" ; 
	exit ;
}

my $file = shift @ARGV;



open (IN, "$file") or die "oops!\n" ;
open OUT, ">", "$file.SMURF.coords" or die "ooops\n" ; 



## read in the cufflink annotations

my $id = '' ; 

my $scaff_count = 0 ; 
my %scaff = () ; 

while (<IN>) {
	
    chomp ; 
    my @r = split /\s+/, ; 

    if (  $r[8] =~ /ID=(\S+):mRNA\;Nam/ ) {
	my $gene = $1 ; 
	my $scaffold = $r[0] ; 

	if ( $scaff{$scaffold} ) {
	    print OUT "$gene\t$scaff{$scaffold}\t$r[3]\t$r[4]\n" ;
	}
	else {
	    $scaff_count++ ; 
	    $scaff{$scaffold} = $scaff_count ; 
	    print OUT "$gene\t$scaff{$scaffold}\t$r[3]\t$r[4]\n" ;
	}

    }

}

print "done! $file.SMURF.coords produced\n" ; 
