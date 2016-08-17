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

my %gene_domain_combination = () ; 

foreach my $file (@files ) {
    open (IN, "$file") or die "daodapdoa\n" ; 
    
    while (<IN>) {
	chomp; 
	next if /^\#/ ; 
	next unless /^\S+/ ; 
	my @r = split /\s+/, $_ ; 

	$domain_des{$r[5]} = $r[6] ; 

	
	if ( $r[12] < $evalue ) {

	    if ( $gene_domain_combination{$r[0]}{$r[5]} ) {
		
	    }
	    else {
		$domain_sum{"$r[5]"}{$file}++ ;
		$gene_domain_combination{$r[0]}{$r[5]}++ ; 
	    }

	}
	else {
	    #print "below evalue: $_\n" ;
	}
	
    }
    close(IN); 
    
}

#headers
print "domain\tfunc" ; 
foreach (@files) { 

    if (/(^\S+)\.fa/) {

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
