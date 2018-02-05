#!/usr/bin/perl -w
use strict;

# Note: Last update with Dang's orthofinder and quick modifition!
# Need careful look!!


if (@ARGV != 3) {
	print "$0 groups.txt Species1 Species2 \n\n" ;
	print "create partitioned list\n" ; 

	exit ;
}




my $file = shift @ARGV;

my $spe1 =  shift @ARGV ;
my $spe2 = shift @ARGV ; 


my %location = () ; 
my %scaffold = () ; 

my %orthoIDtoGene = () ; 

my %scaffold_gene_count = () ; 
my %contig_len = () ; 






open (IN, "$file") or die "oops!\n" ;

open OUT, ">", "$file.$spe1.$spe2.singlecopy.list" or die "can't open files erm!!!!!!\n" ; 
open OUT2, ">", "$file.$spe1.$spe2.duplicate.list" or die "can't open files erm!!!!!!\n" ;
open OUT3, ">", "$file.$spe1.$spe2.quadroplicate.list" or die "dsal;dal;dkla\n"; 





my $count = 0 ;
my %cluster_size = () ;

my %shared_gene = () ;
my %shared_gene_in_scaffold = () ; 
my $gene_pairs = 0 ; 







while (<IN>) {

    chomp ; 
    #print "$_\n" ;

    my @r = split /\s+/, $_ ;

    my $group = '' ;

    if ($r[0] =~ /^(\d+):/) {
	$group = $1 ;
    }




    #print "$r[0]\t$r[1]\n" ;

    my %gene_count = () ; 
    my %genes = () ; 

    for (my $i = 1; $i < @r ; $i++) {

	if ( $r[$i] =~ /(\S+)\|(\S+)/ ) {
	

	    if ( $gene_count{$1}  ) {
		$genes{$1} .= "\t$2"  ; 
	    }
	    else {
		$genes{$1} = "$2"  ;
	    }
	    #print "$1\t$2\n" ; 

	    $gene_count{$1}++ ;

	}       
    }
    
    

    #last; 

    if ( $gene_count{$spe1} && $gene_count{$spe2} ) {
	#print "$gene_count{$spe1}\t$gene_count{$spe2}\t$genes{$spe1}\t.\t$genes{$spe2}\n" ;

	$cluster_size{"$gene_count{$spe1}\t$gene_count{$spe2}"}++ ;
    }
    
    if ( $gene_count{$spe1} && $gene_count{$spe2} ) {

	if ( $gene_count{$spe1} == 1 && $gene_count{$spe2} == 1) {
	    
	    my $gene1 =  $genes{$spe1}  ; 
	    my $gene2 =  $genes{$spe2}  ; 
	    
	    print OUT "$gene1\t$gene2\n" ; 

	}
	elsif ( $gene_count{$spe1} == 1 && $gene_count{$spe2} == 2) {

	    my $gene1 =  $genes{$spe1}  ;
	    my $gene2 =  $genes{$spe2}  ;	    
	    print OUT2 "$gene1\t$gene2\n" ; 


	}
	elsif ( $gene_count{$spe1} == 1 && $gene_count{$spe2} == 4) {

	    my $gene1 =  $genes{$spe1}  ;
	    my $gene2 =  $genes{$spe2}  ;
	    print OUT3 "$gene1\t$gene2\n" ;


	}
	
    }
    elsif ( $gene_count{$spe1} || $gene_count{$spe2} ) {


    }



 



    $count++ ;
    #last if $count == 10;
}



#print OUTSIZE "$spe1\t$spe2\tnum\n" ; 
#for my $cluster ( keys %cluster_size ) {
#    print OUTSIZE "$cluster\t$cluster_size{$cluster}\n" ;
#}




