#!/usr/bin/perl -w
use strict;



if (@ARGV != 1) {
    print "$0 gtf\n" ; 


	exit ;
}
my $file = shift @ARGV;


open (IN, "$file") or die "oops!\n" ;
while (<IN>) {
    
    chomp; 
    my @r = split /\s+/, $_ ; 

    print "$r[0]\tannotation\texon\t$r[3]\t$r[4]\t$r[5]\t$r[6]\t.\t$r[8] $r[9]\; transcript_id $r[11]\; exon_number $r[13]\;\n" ; 

}
close(IN) ; 
