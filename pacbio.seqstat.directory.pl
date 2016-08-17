#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV != 1) {
    print "$0 directory \n" ;
    exit ;
}

my $directory = shift @ARGV;


opendir (DIR, "$directory/Analysis_Results") or die $!;

my $seq = 0 ; 

while (my $file = readdir(DIR)) {

    next unless $file =~ /.fasta/ ; 
    print "$directory/Analysis_Results/$file\t" ;

    my $result = `seqstat $directory/Analysis_Results/$file | grep residues` ; 
   

    if ( $result =~ /(\d+)$/ ) {
	print "$1\n" ; 
	$seq += $1 ; 
    }

    #print "$seq\n" ; 


}

print "\n$directory\t$seq\n" ; 
