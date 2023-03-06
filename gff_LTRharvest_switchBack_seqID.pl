#!/usr/bin/perl -w
use strict;



if (@ARGV != 1) {
    print "$0 ref.fa.ltrharvest.gff\n" ; 



	exit ;
}

my $file = shift @ARGV;



open (IN, "$file") or die "oops!\n" ;

  

my %scaffold = () ; 

my @unique = () ; 

while (<IN>) {
    next if /\#\#\#/ ; 
    next if /gff-version/ ; 

    my @r = split /\s+/, $_ ; 

    if ( $r[0] =~ /sequence-region/ ) {
	push (@unique, $r[1]) ;
	next ; 
    }
    elsif ( $r[0] =~ /\#\w+/ ) {
	$r[0] =~ s/^\#// ;
	print "\#$unique[0]\t$r[0]\n" ; 
	$scaffold{$unique[0]} = $r[0] ;
	shift(@unique) ;
	next ; 
    }
    

    if ( $scaffold{$r[0]} ) {
	$r[0] = $scaffold{$r[0]} ; 
	print join( "\t", @r ), "\n";
    }

}
close(IN) ; 
