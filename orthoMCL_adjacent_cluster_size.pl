#!/usr/bin/perl -w
use strict;



if (@ARGV != 4) {
	print "$0 species gff groups.txt distance \n\n" ;
	print "create partitioned list\n" ; 

	exit ;
}

my $specieschoice = shift @ARGV;
my $gffinput  = shift @ARGV;
my $file = shift @ARGV;
my $distance = shift @ARGV ;

my %location = () ; 

open (IN, "$gffinput") or die "oops\n"; 
while (<IN>) {

    my @r = split /\s+/, $_ ; 
    if ( $r[2] eq 'gene' && $r[8] =~ /Name=(\S+)/ ) {
	if ( $specieschoice ne 'CEL' ) {
	    $location{"$1.1"} = $_ ; 
	}
	else {
	    $location{"$1"} = $_ ;
	}
    }
}
close(IN) ; 


open (IN, "$file") or die "oops!\n" ;
open OUT, ">", "$specieschoice.$file.adjacentclustersize" or die "can't create $file.singletonCluster\n" ;
open OUT2, ">", "$specieschoice.$file.adjacentclustersummary" or die "dakdkaldklaa\n" ; 

print OUT2 "clustername\tnum.genes\tmaxcluster\tnum.genes.in.cluster\n" ; 

my $count = 0 ;



## read in the cufflink annotations
while (<IN>) {

    chomp ; 
    #print "$_\n" ;

    my @r = split /\s+/, $_ ;

    my %group = () ; 
    my @cluster = () ;
    my $clustername = $r[0] ; 

    for (my $i = 1 ; $i <@r ; $i++ ) {
	my @id = split /\|/, $r[$i] ; 
	my $gene = $id[1] ; 
	my $species = $id[0] ; 

	$group{$species}++ ; 
	if ( $species eq $specieschoice ) {
	    push(@cluster, $gene) ; 
	}
    }


    my $speciessize = @cluster ; 

    if ( $speciessize >= 5 ) {

	open TMP, ">" , "tmp.to.calculate.gff" or die "osdoad\n" ; 

	foreach(@cluster) {
	    print TMP "$location{$_}" ; 	    
	}
	close(TMP) ; 
	system("bedtools sort -i tmp.to.calculate.gff  > tmp.to.calculate.sorted.gff") ; 
	system("bedtools merge -i tmp.to.calculate.sorted.gff -n -d $distance > tmp.to.calculate.sorted.merged.gff ") ; 

	open (IN2, "tmp.to.calculate.sorted.merged.gff") or die "can't open tmp file\n" ; 
	print OUT2 "$clustername\t$speciessize\t" ;

	my $max = 0 ; 
	my $numIscluster = 0 ; 
	
	while (<IN2>) {
	    chomp  ; 
	    my @r = split /\s+/, $_ ; 
	    print OUT "$_\n" ; 
	    $max = $r[3] if $max <= $r[3] ; 
	    $numIscluster += $r[3] if $r[3] > 1 ; 
	}

	print OUT2 "$max\t$numIscluster\n" ; 
	close(IN2) ; 


	$count++ ;
	#last if $count == 10;

    }



 




}

