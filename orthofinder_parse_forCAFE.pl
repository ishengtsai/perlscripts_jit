#!/usr/bin/perl -w
use strict;







if (@ARGV != 2) {
    print "$0 Orthogroups.GeneCount.csv MaxGeneFamily\n" ; 
	exit ;
}

my $genelocfile = shift ; 
my $max = shift ; 



open (IN, $genelocfile) or die "dadakjdadjklad\n" ; 

open OUT, ">", "$genelocfile.cafe" or die "daospadpoa\n" ;
open OUT2, ">", "$genelocfile.cafeExceed.$max" or die "Daspdoadopapdaosdp\n" ; 

my @header = split /\s+/, <IN> ;

print OUT "Description\tFamily_ID" ;
print OUT2 "Description\tFamily_ID" ;


#print "$header[1]" ; 
for (my $i = 1 ; $i < $#header ; $i++ ) {
    print OUT "\t$header[$i]" ;
    print OUT2 "\t$header[$i]" ;
}
print OUT "\n" ;
print OUT2 "\n" ; 

while (<IN>) {

    chomp; 
    my @r = split /\s+/, $_ ; 

    my $IsExceed = 0 ;
    my $total = 0 ; 

    for (my $i = 1 ; $i < $#r ; $i++) {
	$IsExceed = 1 if $r[$i] > $max ;
	$total += $r[$i] ; 
    }

    #print "@r\n" ; 
    
    # remove gene family with a gene family in any species greater than 100
    if ( $IsExceed == 1 ) {
	print OUT2 "$r[0]\t$r[0]" ;
	for(my $i = 1 ; $i < $#r ; $i++) {
	    print OUT2 "\t$r[$i]" ;
	}
	print OUT2 "\n" ;
	
	next ; 
    }

    # remove gene family with singleton from one species
    next if $total == 1 ; 

    print OUT "$r[0]\t$r[0]" ; 
    for(my $i = 1 ; $i < $#r ; $i++) {
	print OUT "\t$r[$i]" ; 
    }
    print OUT "\n" ; 
    
}
close(IN) ; 


print "$genelocfile.cafe and $genelocfile.cafeExceed.$max produced!\n" ; 
