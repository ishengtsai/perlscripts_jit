#!/usr/bin/perl -w
use strict;










my %gene ;



while (<>) {
    chomp ;

    my @r = split /\t/, $_ ;

    next if $r[2] eq 'gene' ;
    next if $r[2] eq 'mRNA' ;
    next if $r[2] eq 'CDS' ;
    next if /pseudo=true/ ;
    next if $r[2] eq 'biological_region' ;
    next if $r[2] eq 'mitotic_recombination_region' ; 
    next if $r[2] eq 'DNAseI_hypersensitive_site' ;
    next if $r[2] eq 'origin_of_replication' ;
    next if $r[2] eq 'replication_regulatory_region' ;
    next if $r[2] eq 'meiotic_recombination_region' ;
    next if $r[2] eq 'nucleotide_cleavage_site' ;
    next if $r[2] eq 'nucleotide_motif' ;
    next if $r[2] eq 'promoter' ;
    next if $r[2] eq 'protein_binding_site';
    next if $r[2] eq 'replication_regulatory_region' ;
    next if $r[2] eq 'replication_start_site' ;
    next if $r[2] eq 'silencer' ;
    next if $r[2] eq 'transcriptional_cis_regulatory_region' ; 
    next if $r[2] eq 'D_loop' ; 
    next if $r[2] eq 'non_allelic_homologous_recombination_region';
    next if $r[2] eq 'sequence%2C' ;
    next if $r[2] eq 'locus_control_region' ;
    next if $r[2] eq 'mobile_genetic_element' ;
    next if $r[2] eq 'sequence' ;
    next if $r[2] eq 'tandem_repeat' ;

    
    #print "$r[1]\t$r[2]\t$r[8]\t$r[12]\n" ; 

    if ( $r[2] eq 'enhancer' && $r[8] =~ /ID=(.+)\;Dbxref/ ) {
	my $gene = $1 ; 
	
	if ( $gene{"$gene\tenhancer"} ) {
            $gene{"$gene\tenhancer"} .= " $r[12]" ;
        }
        else {
            $gene{"$gene\tenhancer"} = $r[12] ;
        }

	
    }
    elsif ( $r[8] =~ /Parent=(.+)\;Dbxref.+gene=(.+)\;inference=/ ) {
	 my $parent = $1 ;
        my $gene = $2 ;
        #print "$parent\t$gene\t$r[12]\n" ;

        if ( $gene{"$gene\t$parent"} ) {
            $gene{"$gene\t$parent"} .= " $r[12]" ;
        }
        else {
            $gene{"$gene\t$parent"} = $r[12] ;
        }
	
    }
    elsif ( $r[8] =~ /Parent=(.+)\;Dbxref.+gene=(.+)\;model_evidence=/ ) {
	my $parent = $1	;
        my $gene = $2 ;
	#print "$parent\t$gene\t$r[12]\n" ;

	if ( $gene{"$gene\t$parent"} ) {
	    $gene{"$gene\t$parent"} .= " $r[12]" ;
	}
	else {
	    $gene{"$gene\t$parent"} = $r[12] ; 
	}
	
    }
    elsif ( $r[8] =~ /Parent=(.+)\;Dbxref.+gene=(.+)\;product/ ) {
	my $parent = $1 ;
	my $gene = $2 ;
	#print "$parent\t$gene\t$r[12]\n" ;

	if ( $gene{"$gene\t$parent"} ) {
            $gene{"$gene\t$parent"} .= " $r[12]" ;
	}
	else {
            $gene{"$gene\t$parent"} = $r[12] ;
	}
    }
    else {
	print "not found!\t$r[1]\t$r[2]\t$r[8]\t$r[12]\n" ;
    }
    
    
}


print "\#all run through!\n" ;


print "ID\tGene\tcalled.fraction\n" ;

for my $id (sort keys %gene ) {
    print "$id\t$gene{$id}\n" ; 
}


