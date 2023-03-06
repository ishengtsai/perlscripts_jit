#!/usr/bin/perl -w
use strict;



if (@ARGV != 2) {
	print "$0 gff \n\n" ;
	print "Example usage:\n $0  gff protein_prefix\n\n" ;

	exit ;
}

my $file = shift @ARGV;
my $prefix = shift @ARGV ; 
my $contig_name = '' ;



open OUT, ">", "$file.gene.location" or die "ooops\n" ; 

#open BED, ">", "$file.bed" or die "ooops\n" ; 


open (IN, "$file") or die "oops!\n" ;

# gff

my $intron_start = '' ; 
my $count = 1; 



my %models = (); 
my %gene_start = () ;
my %gene_end = () ;
my %gene_strand = () ; 
my %present = () ; 

my %model_chr_location = () ; 

# read in gff annotations
while (<IN>) {
	
    next unless /gene/ ; 

    my @r = split /\t/ ; 

    if ($r[2] eq 'gene') {
	my $gene ;

	if ( /ID=(\S+)/ ) {
	    $gene = $1 ;
	    $gene =~ s/_NT_/_AA_/ ; 
	}

	print OUT "$prefix\|$gene\t$r[0]\t$r[3]\t$r[4]\t$r[6]\n" ; 

    }
    



    
}
