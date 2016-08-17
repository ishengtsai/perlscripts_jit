#!/usr/bin/perl -w
use strict;



if (@ARGV != 1) {
    print "$0 gff \n" ; 
	exit ;
}

my $file = shift @ARGV;



open (IN, "$file") or die "oops!\n" ;
open OUT, ">", "$file.ripcal.gff" or die "ooops\n" ; 



## read in the cufflink annotations

my $id = '' ; 

my $scaff_count = 0 ; 
my %copy = () ; 

while (<IN>) {
	
    next if /^\#/ ; 
    s/similarity/Repeat_Region/ ;
    my @r = split /\s+/, ; 



    my $gene = '' ; 

    if ( /Motif:(\S+)\"/ ) {
	$gene = $1 ; 
	$copy{$gene}++ ; 
    }


    for (my $i = 0 ; $i < 8 ; $i++ ) {
	print OUT "$r[$i]\t" ; 
    }
    
    print OUT "Name=$gene\; ID=$gene\_" . $copy{$gene} . "\; Target=$gene $r[10] $r[11]\;\n" ; 

}
close(IN) ; 
