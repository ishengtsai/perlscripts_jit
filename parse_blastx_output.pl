#!/usr/bin/perl -w
use strict ;







if (@ARGV != 2) {
    print "$0 output numoutput\n" ;
	exit ;
}

my $file = shift ;
my $numlines = shift ;





open(IN, "$file") or die "can't open $!"; 

my %result = () ; 

while (<IN>) {
    chomp ;
    my @r = split /\s+/, $_ ;

    next if /hypothetical/ ; 
    next if /Hypothetical/ ;
#    next if /PREDICT/ ; 

    if ( $result{$r[0]} ) {
	if ( $result{$r[0]} > $numlines ) {
	    next ;
	}
	else {
	    print "$_\n" ;
	    $result{$r[0]}++ ;

	}

    }
    else {
	print "$_\n" ;
	$result{$r[0]}++ ;
    }

}
