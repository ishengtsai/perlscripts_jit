#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV != 1) {
    print "$0 file \n" ; 
    exit ;
}

my $list = $ARGV[0] ; 

my %genes = () ; 




open (IN, "$list") or die "oooops\n" ; 

while (<IN>) {
    next if /^\#/ ; 
    next unless /^\S+/ ; 

    chomp ; 
    my @r = split /\s+/, $_ ; 

    $genes{$r[0]}{$r[3]} = "$r[4]:$r[6]" ; 
}
close(IN) ; 


for my $gene (sort keys %genes )  {
    print "$gene\t" ; 
    
    my $count = 0 ; 
    for my $domainstart ( sort {$a<=>$b} keys % { $genes{$gene} } ) {
	if ( $count == 0 ) {
	    print "$domainstart-$genes{$gene}{$domainstart}" ; 
	}
	else {
	    print ",$domainstart-$genes{$gene}{$domainstart}" ;
	}

	$count++ ; 
    }

    print "\n" ; 
}





