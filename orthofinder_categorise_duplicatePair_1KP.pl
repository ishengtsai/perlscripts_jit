#!/usr/bin/perl -w
use strict;



if (@ARGV != 2) {
	print "$0 groups.txt pairwise_combination_max \n\n" ;
	print "create partitioned list\n" ; 

	exit ;
}

my $file = shift @ARGV;
my $num = shift @ARGV ;



open (IN, "$file") or die "oops!\n" ;
open OUT, ">", "$file.1kp.duplicateCluster" or die "can't create $file.singletonCluster\n" ;



my $count = 0 ;
my %cluster_size = () ;

my %shared_gene = () ;

## read in the cufflink annotations
while (<IN>) {

    chomp ; 
    #print "$_\n" ;

    my @r = split /\s+/, $_ ;
    $r[0] =~ s/\:// ; 
    
    my %group = () ; 
    my %species_gene = () ; 
    
    for (my $i = 1 ; $i <@r ; $i++ ) {
	my @id = split /\|/, $r[$i] ; 
	my $gene = $id[1] ; 
	my $species = $id[0] ;


	$group{$species}++ ;

	if ( $species_gene{$species} ) {
	    $species_gene{$species} .= "\t$id[1]" ;
	}
	else {
	    $species_gene{$species} = "$id[1]" ;
	}
    }


    my $speciessize = scalar keys %group ; 
    my $groupsize = $#r ; 


    for my $species (sort keys %group ) {
	
	if ( $group{$species} != 1 && $group{$species} < $num ) {
	    my @genes = split /\t/, $species_gene{$species} ;

	    #print "$species\t@genes\n\n" ;
	    
	    for ( my $i = 0 ; $i < $#genes ; $i++) {
		my $pairA = $genes[$i] ;
		for (my $j = $i+1 ; $j < @genes ; $j++ ) {
		    print OUT "$species\t$pairA\t$genes[$j]\n" ; 
		}
	    }

	    #print "\n\n" ; 
	}
    }

    


    #system("muscle -in $group.fa -out $group.aln") ;
    #system("muscle -in $group.dna.fa -out $group.dna.aln") ;
 



    $count++ ;
    #last if $count == 10;
}

