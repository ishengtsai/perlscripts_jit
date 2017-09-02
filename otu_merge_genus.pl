#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';




if (@ARGV != 1) {
    print "$0 otu_table.txt\n" ; 
    exit ;
}

my $filenameA = $ARGV[0];




open OUT, ">", "$filenameA.uniq.txt" or die "oooops!\n" ;



open (IN, "$filenameA") or die "oops!\n" ;

my %otu = () ; 

my $headerline = <IN> ; 
my @header = split /\t/, $headerline ; 
my $numsamples = @header -2 ; 

print "$numsamples samples\n" ; 



while (<IN>) {
    chomp;
    my @r = split /\s+/, $_ ;
    #print "$r[7]\n" ; 

    my $taxa = $r[7] ; 
    
    for (my $i = 1 ; $i < ($numsamples+1) ; $i++) {
	#print "$r[$i]\n" ;
	$otu{$taxa}{$i} += $r[$i] ; 
    }

}
close(IN) ;

my $num = 1 ;
print OUT "$headerline" ; 
 
for my $taxa (sort keys %otu ) {

    #print "$taxa\n" ; 

    print OUT "Otu$num\t" ;
    $num++ ; 
    for (my $i = 1 ; $i < ($numsamples+1) ; $i++) {

	if ( $otu{$taxa}{$i} ) {
	    print OUT "$otu{$taxa}{$i}\t" ; 
	}
	else {
	    print OUT "0\t" ; 
	}

    }
    print OUT "$taxa\n" ;
    
}
