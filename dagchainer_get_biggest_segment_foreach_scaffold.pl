#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV != 3) {
    print "$0 coords listfile chrname\n\n" ; 
	exit ;
}

my $filenameA = $ARGV[0];
my $listfile = $ARGV[1] ; 
my $chrname = $ARGV[2] ; 

my %list = () ; 
open (IN, "$listfile") or die "ooops\n" ; 
while (<IN>) {

    chomp; 
    $list{$_}++ ; 

}
close(IN); 


open (IN, "$filenameA") or die "oops!\n" ;

my %scaffsize = () ; 
my %scaffline = () ; 

while (<IN>) {
    chomp; 
    my @r = split /\s+/, $_ ; 

    if ( $list{$r[0]} && $r[1] eq $chrname ) {
#	print "$_\n" ; 

	if ( $scaffsize{$r[0]} ) {
	    if ( $scaffsize{$r[0]} < $r[2] ) {
		$scaffsize{$r[0]} = $r[2] ; 
		$scaffline{$r[0]} = $_ ; 
	    }
	}
	else {
	    $scaffline{$r[0]} = $_ ;
	    $scaffsize{$r[0]} = $r[2] ;
	}

    }

}

my %refcoords = () ; 

# need to order
for my $line ( keys %scaffline ) {

    my @r = split /\s+/, $scaffline{$line} ; 
    $refcoords{$r[13]} = $scaffline{$line} ; 

}

for my $coords ( sort {$a<=>$b} keys %refcoords) {
    print "$refcoords{$coords}\n" ; 
}

# need to check for any missing genes
