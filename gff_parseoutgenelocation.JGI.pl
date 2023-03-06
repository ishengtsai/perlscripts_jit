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
	
    next unless /CDS/ ; 


    s/\#/\./gi ; 
	chomp ;
	my @r = split /\t/, $_ ;

	#updated: for parsing the RATT event 
	$r[8] =~ s/\"//gi ; 

	

	
	if ( $r[2] eq 'CDS' ) {

	    if ( $r[8] =~ /proteinId (\d+)\;/) {
		my $gene = $1 ; 

		
		if ( $present{$gene} ) {
		    #print "$gene already printed\n" ;
		    $gene_end{$gene} = $r[4] ; 
		}
		else {
		    $models{"$r[0]"}{"$r[3]"} = $gene ;
		    $gene_start{$gene} = $r[3] ;
		    $gene_end{$gene} = $r[4] ;
		    $gene_strand{$gene} = $r[6] ; 
		    $present{$gene}++ ;
		}
		

	    }


	}
	    



	#last;
}
close(IN) ;




for my $scaff (sort keys %models ) {


    for my $start ( sort { $a <=> $b } keys (%{ $models{$scaff} }) ) {
	
	my $gene = $models{$scaff}{$start} ; 

	print OUT "$prefix\|$gene\t$scaff\t$start\t$gene_end{$gene}\t$gene_strand{$gene}\n" ; 
	

    }

    
    
}



print "all done!!! $file.gene.location\n" ;
