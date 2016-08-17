#!/usr/bin/perl -w
use strict;



if (@ARGV != 1) {
	print "$0 groups.txt \n\n" ;
	print "create partitioned list\n" ; 

	exit ;
}

my $file = shift @ARGV;




open (IN, "$file") or die "oops!\n" ;
open OUT, ">", "$file.singletonCluster" or die "can't create $file.singletonCluster\n" ;



my $count = 0 ;
my %cluster_size = () ;

my %shared_gene = () ;

## read in the cufflink annotations
while (<IN>) {

    chomp ; 
    #print "$_\n" ;

    my @r = split /\s+/, $_ ;

    my %group = () ; 
    my $sakura_family = '' ; 

    for (my $i = 1 ; $i <@r ; $i++ ) {
	my @id = split /\|/, $r[$i] ; 
	my $gene = $id[1] ; 
	my $species = $id[0] ; 

	$group{$species}++ ; 

	if ( $species =~ /TA/ ) {
	    if ( $sakura_family ) {
		$sakura_family .= "\t$gene" ; 
	    }
	    else {
		$sakura_family = "$gene" ;
	    }
	}
	
    }


    my $speciessize = scalar keys %group ; 
    my $groupsize = $#r ; 

    next unless $group{'TAW'} && $group{'TAW'} == 1 ; 
    next unless $group{'TAP'} && $group{'TAP'} == 1 ;
    next unless $group{'TAF'} && $group{'TAF'} == 1 ;    
    next unless $group{'TAD'} && $group{'TAD'} == 1 ;

    print OUT "$sakura_family\n" ; 



    #system("muscle -in $group.fa -out $group.aln") ;
    #system("muscle -in $group.dna.fa -out $group.dna.aln") ;
 



    $count++ ;
    #last if $count == 10;
}

