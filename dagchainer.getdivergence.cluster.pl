#!/usr/bin/perl -w
use strict;







if (@ARGV != 4) {
    print "$0 input.filtered.aligncoords.similarity gene.space min.cluster.size divergence \n" ; 
	exit ;
}


my $dagfile = shift ; 
my $genedistance = shift ; 
my $minclustersize = shift ; 
my $divergence = shift ; 




open (IN, $dagfile) or die "can't open $dagfile\n" ;

my $header  ; 
my $previous  ; 
my $id = 0 ; 
my $firstline = 1 ; 
my $clustersize = 0 ; 
my $clusternumber = 1 ;

while (<IN>) {

    if (/^\#/ ) {
	if ( $previous && $clustersize >= $minclustersize ) {
            print "Cluster:$clusternumber\n$previous" ;
	    $clusternumber++ ; 
	}


	$header = $_ ; 
	$clustersize = 0 ;
	$firstline = 1 ; 
	next ; 
    }

    my @r = split /\s+/, $_ ; 
    next unless $r[15] < $divergence ; 


    if ( $firstline == 1 ) {

	$previous = $_ ; 
	$id = $r[2] ;
	$firstline = 0 ; 
	$clustersize = 1 ; 
	next ; 
    }

    if ( ( $r[2] - $id ) <= $genedistance  ) {
	$previous .= $_ ; 
	$id = $r[2] ; 
	$clustersize++ ; 
    }
    else {
	if ( $previous && $clustersize >= $minclustersize ) {
	    print "Cluster:$clusternumber\n$previous" ; 
	}
	else {
	    #print "not!!\t$clustersize\t$previous" ;
	}

	$previous = $_ ;
	$id = $r[2] ;
	$clustersize = 1 ; 

    }


}
close(IN) ; 
