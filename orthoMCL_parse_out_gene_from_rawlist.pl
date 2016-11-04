#!/usr/bin/perl -w
use strict;



if (@ARGV != 2) {
    print "$0 orthomcl_19710.cluster SPECIES\n" ;


    exit ;
}


my $file = $ARGV[0];
my $species = $ARGV[1];


open (IN, $file) or die "ooops\n" ;
while (<IN>) {

    chomp ;
    #print "$_\n" ;

    my @r = split /\s+/, $_ ;

    my $group = '' ;

    if ($r[0] =~ /(^OG\S+)\:/) {
	$group = $1 ;
    }

    # put clusters info into hash
    my %cluster = () ;
    for ( my $i = 1 ; $i < @r ; $i++ ) {

	if ( $r[$i] =~ /($species)\|(\S+)/ ) {
	    print "$1\|$2\t$group\n" ;
	}
    }



}
