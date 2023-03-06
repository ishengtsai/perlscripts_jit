#!/usr/bin/perl -w
use strict;







if (@ARGV != 1) {
    print "$0 cafe.tree\n" ; 
	exit ;
}

my $genelocfile = shift ; 




open (IN, $genelocfile) or die "dadakjdadjklad\n" ; 

while (<IN>) {

    chomp; 

    s/:\d+\.\d+/1/gi ;
    s/[a-z]+//gi ; 
    print "$_\n" ; 
    
}
close(IN) ; 



