#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV != 2) {
    print "$0 directory evalue\n" ; 
	exit ;
}

my $directory = $ARGV[0];
opendir(DIR, $directory) || die;


my $evalue = $ARGV[1] ; 


my %domain_sum  = () ; 
my %domain_des = () ; 

my %gene_domain_combination = () ; 

my @files = () ;


while(my $file = readdir(DIR) ) {
    

    next if $file =~ /nohup/ ; 
    next unless $file =~ /.out$/ ;
    
    
    open (IN, "$file") or die "daodapdoa\n" ; 
    push(@files, $file) ;
    
    
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

    if (/(^\S+)\.out/) {

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
