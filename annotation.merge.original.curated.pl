#!/usr/bin/perl -w
use strict;



if (@ARGV != 3) {
    print "$0 overlap.region originalGff curatedGff \n" ; 

	exit ;
}

my $file = shift @ARGV;
my $file2 = shift @ARGV ;
my $file3 = shift @ARGV;



my %scaffolds = () ; 
my %ScaffoldGenes = () ; 
my %LocationIsGenes = () ; 

my %geneblock = () ; 
my %toInclude = () ; 

my $genename = '' ; 
my $numCurated = 0 ;

open (IN, "$file") or die "oops!\n" ;

while (<IN>) {

    chomp; 
    my @r = split /\s+/, $_ ; 
    $scaffolds{$r[0]}++ ; 

    if ( $r[2] eq 'gene' && /Name=(\S+)$/) {
	$toInclude {$1}++ ; 
			
    }

}
close(IN) ; 

open (IN, "$file2") or die "oops!\n" ;
while (<IN>) {

    chomp;
    my @r = split /\s+/, $_ ;

    if ( $r[2] eq 'gene' && /Name=(\S+)$/) {
	$genename = $1 ;

	if ( $toInclude{ $genename } ) {
	    $ScaffoldGenes { $r[0] } { $r[3] } ++ ;
	    $LocationIsGenes { "$r[0].$r[3]" } = "$genename" ; 
	}

    }

    if ( $toInclude{ $genename } ) {
	$geneblock{ $genename} .= "$_\n" ;
    }

}
close(IN) ;

open (IN, "$file3") or die "oops!\n" ;



while (<IN>) {

    chomp;
    my @r = split /\s+/, $_ ;
    $r[7] = '.' ; 

    
    if ( $r[2] eq 'gene' && /Name=(\S+)$/) {
	$genename = $1 ;
	$ScaffoldGenes { $r[0] } { $r[3] } ++ ;
	$LocationIsGenes { "$r[0].$r[3]" } = "$genename" ;
	$numCurated++ ;
    }

    $geneblock{ $genename} .= "$_\n" ;

    

}
close(IN) ;


my $numExactModels = 0 ;

open OUT, ">", "$file2.withcurated.gff" or die "daodspaodoapsdoaposd\n" ; 



for my $scaffold (sort keys %scaffolds ) {


    for my $locus (sort {$a <=> $b} keys %{ $ScaffoldGenes { $scaffold } } ) {


	my $gene = $LocationIsGenes { "$scaffold.$locus"  } ; 
	

	#print "$scaffold\t$locus\t$gene\n" ; 

	print OUT "$geneblock{$gene}" ;  
	
    }

}

print "$file2.withcurated.gff output!\n$numCurated curated models inserted!\n" ; 




