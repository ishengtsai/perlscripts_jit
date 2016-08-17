#! /usr/bin/perl -w
#
#
# Copyright (C) 2009 by Pathogene Group, Sanger Center
#
# Author: JIT
# Description: 
#		a script that map the Solexa reads back to the reference/contigs
#		and parition them based on either ends of the contigs
#
#
#



use strict;
use warnings;

# to print
local $" = "\t";


my $PI = `echo $$` ; chomp($PI) ;


#"


if (@ARGV != 4 ) {
    print "$0 bam winsize file.len.txt minimum.scaff.len \n" ; 
	exit;
}



my $lane = shift;
my $windowsize = shift ; 
my $file = shift ; 
my $scafflen = shift ; 

my @scaffolds = () ; 
open (IN, $file ) or die "doapodoapdo\n" ; 
while (<IN>) {

    chomp; 
    if ( /(^\S+)\s+(\d+)/ ) {

	if ( $2 >= $scafflen ) {
	    push (@scaffolds, $1) ; 
	}

    }

}
close(IN) ; 






print "@scaffolds\n" ; 



foreach my $scaffold ( @scaffolds ) {

    print "$scaffold\n" ; 
    my $command = "bam2cov_window.pl 1 ref.fa.len.txt  $scaffold $windowsize ref.fa $lane" ; 
    print "$command\n" ; 
    system("$command") ; 

}
