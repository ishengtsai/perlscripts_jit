#!/usr/bin/perl -w
use strict;








if (@ARGV != 1) {
    print "$0 sv.txt\n" ; 
	exit ;
}

my $filenameA = $ARGV[0];





open (IN, "$filenameA") or die "daodapdoa\n" ; 

my $tmp = <IN> ; 
    while (<IN>) {
	chomp; 

	my @r = split /\t+/, $_ ; 

	my @pos1 = split /-/, $r[4] ; 
	my @pos2 = split /-/, $r[7] ; 

	print "$r[0]\t$r[1]\t$r[3]\t$pos1[0]\t$pos1[1]\t". ($pos1[1]-$pos1[0]+1) . "\t$r[6]\t$pos2[0]\t$pos2[1]\t". ($pos2[1]-$pos2[0]+1) . "\t$r[8]\t$r[12]\n" ; 

    }

    close(IN); 
    
