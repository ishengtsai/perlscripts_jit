#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV != 2) {
    print "$0 phylogeny list\n\n" ;
    print "list contain ID\\tStringToAdd\n" ; 
	exit ;
}



my $filenameA = $ARGV[0];
my $list = $ARGV[1] ; 


open (IN, "$filenameA") or die "oops!\n" ;
my $phylogeny ;
while (<IN>) {
    $phylogeny .= $_ ; 
}
close(IN) ;

open (IN, "$list") or die "oops!\n" ;

while (<IN>) {
    if (/^(\S+)\s+(\S+)/) {
	my $ID = $1 ;
	my $addString = "$1.$2" ; 

	$phylogeny =~ s/ $ID/ $addString/gi ;
	$phylogeny =~ s/\($ID/\($addString/gi ; 
	$phylogeny =~ s/,$ID/,$addString/gi ;
	
    }
}
close(IN) ;


print "$phylogeny\n" ; 
    
