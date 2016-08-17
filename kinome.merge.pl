#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV != 1) {
    print "$0 *.final.txt[separate.by.comma] \n" ; 
	exit ;
}

my $filenameA = $ARGV[0];



my @files = split (/\,/, $filenameA) ; 


my %kinome = () ; 



foreach my $file (@files ) {
    open (IN, "$file") or die "daodapdoa\n" ; 
    
    while (<IN>) {
	chomp; 
	next if /^\#/ ; 
	next unless /^\S+/ ; 
	my @r = split /\t+/, $_ ; 

	unless ( $r[2] ) {
	    $kinome{$r[0]}{$file} = "$r[1]\tNA" ;
	}
	else {
	    $kinome{$r[0]}{$file} = "$r[1]\t$r[2]" ; 
	}

    }

    close(IN); 
    
}


print "kinase\t" ; 
foreach (@files) { 

    if (/(^\S+)\.fa/) {

	print "\t$1" ; 
    }
    else {
	print "\t$_" ;
    }

}  
print "\n" ; 


for my $kinase (sort keys %kinome ) {

    print "$kinase" ; 

    foreach my $file (@files ) {


	if ( $kinome{$kinase}{$file} ) {
	    print "\t$kinome{$kinase}{$file}" ; 
	}
	else {
	    print "\tNA\tNA" ; 
	}

    }
    print "\n" ; 



}
