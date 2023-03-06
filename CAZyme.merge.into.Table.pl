#!/usr/bin/perl -w
use strict;







if (@ARGV != 1) {
    print "$0 file \n" ; 
    exit ;
}

my $list = $ARGV[0] ; 

my %species = () ; 
#my %genes = () ; 

my %enzymes = () ; 

# check for redundant genes
my %uid = () ; 

open (IN, "$list") or die "oooops\n" ; 

while (<IN>) {
    next if /^Gene\s+ID/ ; 
    next unless /^\S+/ ; 

    chomp ; 
    my @r = split /\s+/, $_ ; 

    my $speciesIs = '' ; 
    
    if ( $r[0] =~ /(\S+)\|(\S+)/ ) {
	$speciesIs = $1 ; 
    }

    if ( $uid{$r[0]} ) {
	print "$r[0] appear more than two times!\n" ;
	exit ; 
    }
    
    $species{$speciesIs}++ unless $species{$speciesIs} ; 
    
    if ( $r[1] eq '-' && $r[3] ne '-' ) {
	$enzymes{$r[3]}{$speciesIs}++ ; 
    }
    elsif ( $r[1] ne '-' ) {
	$r[1] =~ s/\(\d+-\d+\)//gi ; 
	
	$enzymes{$r[1]}{$speciesIs}++ ;
    }
    
}
close(IN) ; 

#header
print "CAzyme" ;
for my $speciesIs (sort keys %species) {
    print "\t$speciesIs" ; 
}
print "\n" ; 


for my $enzyme (sort keys %enzymes )  {
    print "$enzyme" ; 

    for my $speciesIs (sort keys %species) {

	if ( $enzymes{$enzyme}{$speciesIs} ) {
	    print "\t$enzymes{$enzyme}{$speciesIs}" ; 
	}
	else {
	    print "\t0" ; 
	}
	
    }
    print "\n" ; 
}





