#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV != 2) {
    print "$0 hmmscan.perseq.out.files[separate.by.comma] evalue\n" ; 
	exit ;
}

my $filenameA = $ARGV[0];
my $evalue = $ARGV[1] ; 


my @files = split (/\,/, $filenameA) ; 



my %domain_sum  = () ; 
my %domain_des = () ; 

foreach my $file (@files ) {
    open (IN, "$file") or die "daodapdoa\n" ; 
    
    while (<IN>) {
	chomp; 
	next if /^\#/ ; 
	my @r = split /\s+/, $_ ; 

	$domain_des{$r[1]} = $r[0] ; 

#	print "$r[1]\t$r[7]\n" ; 
	
	if ( $r[7] < $evalue ) {
	    #print "$r[1]\t$r[7]\n" ;
	    $domain_sum{$r[1]}{$file}++ ; 
	}
	else {
	   # print "$r[1]\t$r[7]\n" ;
	}
	
    }
    close(IN); 
    
}

#headers
print "domain\tfunc" ; 
foreach (@files) { 

    if ( /(^\S+)\.fa/ ) {
	print "\t$1" ; 
    }
    else {
	print "\t$_" ; 
    }
}  
print "\n" ; 


for my $domain (sort keys %domain_sum ) {

    print "$domain\t$domain_des{$domain}" ; 

    foreach my $file (@files ) {


	if ( $domain_sum{$domain}{$file} ) {
	    print "\t$domain_sum{$domain}{$file}" ; 
	}
	else {
	    print "\t0" ; 
	}

    }
    print "\n" ; 



}
