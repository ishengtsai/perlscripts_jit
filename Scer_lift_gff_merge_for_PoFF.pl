#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV != 2) {
    print "$0 liftoverGFF AugustusGFF\n" ; 

	exit ;
}



my $filenameA = $ARGV[0];
my $filenameB = $ARGV[1] ; 


open (IN, "$filenameA") or die "oops!\n" ;

while (<IN>) {
    chomp ; 
    my @r = split /\s+/, $_ ; 
    if ( $r[2] eq 'CDS' ) {
	if ($r[8] =~ /Name=(\S+)_CDS;/ ) {
	    #print "$1\n" ;

	    $r[8] = "Name=$1" ; 

	    
	    foreach my $item (@r) {
		print "$item\t" ; 
	    }
	    print "\n" ; 
	    
	}
	
    }
}
close(IN) ;


    
open (IN, "$filenameB") or die "oops!\n" ;

while (<IN>) {
    chomp ;
    my @r = split /\s+/, $_ ;
    if ( $r[2] eq 'CDS' ) {
        if ($r[8] =~ /ID=(\S+).cds;/ ) {
            #print "$1\n" ;

            $r[8] = "Name=$1" ;


	    foreach my $item (@r) {
		print "$item\t"	;
            }
            print "\n" ;

        }

    }
}
close(IN) ;
