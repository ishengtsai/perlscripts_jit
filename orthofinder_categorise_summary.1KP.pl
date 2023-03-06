#!/usr/bin/perl -w
use strict;



if (@ARGV != 1) {
	print "$0 groups.txt \n\n" ;
	print "create partitioned list\n" ; 

	exit ;
}

my $file = shift @ARGV;


#my @species_listnames = qw / FALI WPHN MAQO BSVG BCGB ABSS KAYP VYLQ WIGA KRJP YZRI PSJT DHPO XQWC WBOD OBPL PAWA QDVW MUNP XSZI OPDF CSSK AMBO CKAN / ;
my @species_listnames = qw / FALI WPHN MAQO BSVG BCGB ABSS KAYP VYLQ WIGA KRJP YZRI PSJT DHPO XQWC WBOD OBPL AMBO CKAN / ;
my $num = $#species_listnames + 1;


print "number of species in Magnoliids + Ambo: $num\n" ; 

my %species_list = () ;

foreach (@species_listnames) {
    $species_list{$_}++ ; 
}

open (IN, "$file") or die "oops!\n" ;
open OUT, ">", "$file.1KP.singletonCluster" or die "can't create $file.singletonCluster\n" ;
#open OUTGENE , ">", "$file.1KP.geneInOGlist" or die "daosdpapdoapdooa\n" ; 


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


    my $finalline = "$r[0]:" ;
    
    for (my $i = 1 ; $i <@r ; $i++ ) {
	my @id = split /\|/, $r[$i] ; 
	my $gene = $id[1] ; 
	my $species = $id[0] ;

	#print OUTGENE "$species\t$gene\t$r[0]\t" . (@r-1) . "\n" ; 
	$group{$species}++ ;

	if ( $species_list{$species} ) {
	    $finalline .= " $r[$i]" ; 
	}

    }

    my $allspeciespresent = 1 ;
    my $totalgene = 0 ;
    for my $species (sort keys %species_list) {
	if ( $group{$species} ) {
	    $totalgene += $group{$species} ; 
	}
	else {
	    $allspeciespresent = 0 ; 
	}
    }
    

    my $speciessize = scalar keys %group ; 
    my $groupsize = $#r ; 


    if ( $allspeciespresent == 1 && $totalgene == $num ) {

	print OUT "$finalline\n" ; 
    }


    #system("muscle -in $group.fa -out $group.aln") ;
    #system("muscle -in $group.dna.fa -out $group.dna.aln") ;
 



    $count++ ;
    #last if $count == 10;
}


