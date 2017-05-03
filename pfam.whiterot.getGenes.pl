#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV != 2) {
    print "$0 WRpfam Pnok \n" ; 
    exit ;
}

my $list = $ARGV[0] ; 
my $pnokfile = $ARGV[1] ; 

my %pfams = () ; 




open (IN, "$list") or die "oooops\n" ; 

while (<IN>) {
    #print "$_" ; 
    
    while ( /(PF\d+)/g ) {
	$pfams{$1}++ ; 
    }
    #print "\n" ; 

}
close(IN) ; 

my $pfamSize = keys %pfams ; 
print "\#pfamSize: $pfamSize\n" ; 

open (IN, "$pnokfile") or die "oooops\n" ;

my %genePresent = () ; 
my %totalPfam = () ; 

while (<IN>) {
    #print "$_" ;

    next if /^\#/ ;
    next unless /^\S+/ ; 

    chomp; 
    my @r = split /\s+/, $_ ; 
     
    
    while ( /(PF\d+)/g ) {
	my $pfamInPnok = $1 ;

	if ( $pfams{ $pfamInPnok } ) {
	    $genePresent{ $r[0] } ++ ; 
	}
	
    }
    #print "\n" ;

}
close(IN) ;


my $geneSize = keys %genePresent ;
print "\#Genes with expanded pfam: $geneSize\n" ;

for my $gene ( sort keys %genePresent ) {
    print "$gene\n" ; 

}
