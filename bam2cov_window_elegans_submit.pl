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


if (@ARGV != 2 ) {
    print "$0 lane winsize\n" ; 
	exit;
}



my $lane = shift;
my $windowsize = shift ; 




my @scaffolds = ( "CHROMOSOME_I", "CHROMOSOME_II", "CHROMOSOME_III", "CHROMOSOME_IV", "CHROMOSOME_V", "CHROMOSOME_X" , "CHROMOSOME_MtDNA") ; 


print "@scaffolds\n" ; 



foreach my $scaffold ( @scaffolds ) {

    print "$scaffold\n" ; 
    my $command = "bam2cov_window.pl 1 ref.fa.len.txt  $scaffold $windowsize ref.fa $lane" ; 
    print "$command\n" ; 
    system("$command") ; 

}
