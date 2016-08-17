#!/usr/bin/perl -w
use strict;



if (@ARGV != 1) {
	print "$0 gff \n\n" ;
	print "Example usage:\n $0  gff \n\n" ;

	exit ;
}

my $file = shift @ARGV;
my $fastafile = shift @ARGV ;
my $contig_name = '' ;



open OUT, ">", "$file.gene.location" or die "ooops\n" ; 
open BED, ">", "$file.bed" or die "ooops\n" ; 


open (IN, "$file") or die "oops!\n" ;

# gff

my $intron_start = '' ; 

my $count = 1; 

my %loc = () ; 

# read in gff annotations
while (<IN>) {
	
    next if /rfamscan/ ; 
    next if /tRNA/ ; 
    next if /rRNA/ ; 
    next if /^\#/ ; 
	chomp ;
	my @r = split /\s+/, $_ ;

	#updated: for parsing the RATT event 
	$r[8] =~ s/\"//gi ; 

	

	
	if ( $r[2] eq 'mRNA' ) {


	    if ( $r[8] =~ /Name=(\S+):mRNA/) {

		

		my $countFormatted = sprintf("%05d", $count);

		print OUT "$1\t$r[0]\t$r[3]\t$r[0]....$countFormatted\n" ;
		print BED "$r[0]\t$r[3]\t$r[4]\t$1\n" ;

	    }

	    $count++ ; 
	}
	else {
	    next ; 

        }


	#last;
}
close(IN) ;


#print "all done!!!\n" ;
