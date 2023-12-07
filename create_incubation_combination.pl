#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';




if (@ARGV != 5) {
    print "$0 strain_list\n" ; 
    exit ;
}


my $readfile = $ARGV[0] ; 

my @strains = () ;
my @substrates = split /\,/ , $ARGV[1] ;
my @media = split /\,/, $ARGV[2] ;
my @temp = split /\,/, $ARGV[3] ;
my @replicate = split /\,/, $ARGV[4] ; 

print "SAMPLE_ID\tOther_name\tSOURCE_ID\tsubstrate\tmedia\ttemperature\treplicate\n" ; 

open (IN, "$readfile") or die "oops!\n" ;
while (<IN>) {
    chomp;
    my $strain = $_ ;

    my $count = 0 ; 
    
    foreach my $substrate ( @substrates ) {

	foreach my $medium ( @media ) {
	    for (my $i = 0 ; $i < @temp ; $i++ ) {
		for (my $j = 0 ; $j < $replicate[$i] ; $j++ ) {
		    $count++ ;
		    print "$strain\_" ; 
		    printf '%03s', $count;
		    print "\t.\t$strain\t$substrate\t$medium\t$temp[$i]\t$replicate[$j]\n" ;
		}
	    }
	}
	

    }

}
close(IN) ; 





print "all done! all done!\n" ; 



