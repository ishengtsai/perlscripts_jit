#!/usr/bin/perl -w
use strict;



if (@ARGV != 1) {
    print "$0 gff \n" ; 

	exit ;
}

my $file = shift @ARGV;


## read the fastas
open (IN, "$file") or die "oops!\n" ;

while (<IN>) {

    chomp; 
    my @r = split /\s+/, $_ ;
    my $line = $_ ; 

    if ( $r[2] eq 'CDS' ) {

	$line =~ s/CDS/exon/gi ;
	print "$_\n$line\n" ; 
	
    }
    else {
	print "$line\n" ; 
    }


}
close(IN) ; 
