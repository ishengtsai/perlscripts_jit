#!/usr/bin/perl -w
use strict;



if (@ARGV != 2) {
	print "$0 groups.txt num_species \n\n" ;
	print "create partitioned list\n" ; 

	exit ;
}

my $file = shift @ARGV;
my $num = shift @ARGV ;



open (IN, "$file") or die "oops!\n" ;
open OUT, ">", "$file.duplicateCluster" or die "can't create $file.singletonCluster\n" ;



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

    for (my $i = 1 ; $i <@r ; $i++ ) {
	my @id = split /\|/, $r[$i] ; 
	my $gene = $id[1] ; 
	my $species = $id[0] ;


	$group{$species}++ ; 
    }


    my $speciessize = scalar keys %group ; 
    my $groupsize = $#r ; 


    if ( $speciessize == $num && $groupsize == ($num+1) ) {
	if ( $group{'CKAN'} == 2 ) {
	    print OUT "$_\n" ; 
	}
    }


    #system("muscle -in $group.fa -out $group.aln") ;
    #system("muscle -in $group.dna.fa -out $group.dna.aln") ;
 



    $count++ ;
    #last if $count == 10;
}

