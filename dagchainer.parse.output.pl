#!/usr/bin/perl -w
use strict;







if (@ARGV != 2) {
    print "$0 gene.location dagchainer.output.file\n" ; 
	exit ;
}

my $genelocfile = shift ; 
my $filenameA = shift ; 


my %genes = () ; 
my %ref_genes = () ; 
my %qry_genes = () ; 

my %gene_locs = () ; 
my $maxgene_order = 0 ; 
my $maxgene_length_ref = 0 ; 
my $maxgene_length_qry = 0 ; 

open (IN, $genelocfile) or die "dadakjdadjklad\n" ; 
while (<IN>) {

    chomp; 
    my @r = split /\s+/, $_ ; 
    $r[3] =~ s/\S+\.\.\.\.// ; 
    $gene_locs{$r[0]} = "$r[3]\t$r[2]\t$r[4]" ; 
}
close(IN) ; 

open (IN, $filenameA) or die "can't open $filenameA\n" ; 

open OUTREF, ">", "$filenameA.ref.gff" or die "can't open output\n" ; 
open OUTQRY, ">", "$filenameA.qry.gff"or die "can't open output\n" ;

while (<IN>) {

    chomp ;
    if ( /^\#\#/ ) {
	my $strand_ref = '' ; 
	my $strand_qry = '' ; 


	s/\(reverse\)//gi ; 
	
	my @r = split /\s+/, $_ ; 
	$r[13] =~ s/\)\:// ; 

	my $ref_gene = '' ; 
	my $ref_last_gene = '' ; 
	my $qry_gene = '' ; 
	my $qry_last_gene = '' ; 
	
	my $repeated_in_ref = 0 ; 
	my ($ref_scaff, $qry_scaff, $geneorder) = ($r[2], $r[4] ,$r[13]) ;

	for (my $i = 0 ; $i < $geneorder ; $i++) {
	    my @rr = split /\s+/, <IN> ; 
	    $ref_gene = "$rr[1]" if $i == 0 ; 
	    $ref_last_gene = "$rr[1]" if $i == ( $geneorder - 1) ; 
	    $qry_gene = "$rr[5]" if $i == 0 ;
	    $qry_last_gene = "$rr[5]" if $i == ( $geneorder - 1) ;
	    
	    $ref_genes{$rr[1]}++ ; 
	    $qry_genes{$rr[5]}++ ; 
	    
	    if ( $genes{$rr[1]} ) {
		print "warning! $rr[1] used multiple times!\n" ; 
		$repeated_in_ref = 1 ; 
	    }
	    #else {
	    #    $genes{$rr[1]}++ ; 
	    #}
	    
	}
	

	next if $repeated_in_ref == 1 ; 


	$maxgene_order = $r[13] if $maxgene_order < $r[13] ;


	print "$ref_scaff\t$qry_scaff\t$geneorder\t"  ;

	if ( $geneorder == $maxgene_order ) {
	    my @refcoords1 = split /\s+/, $gene_locs{$ref_gene} ; 
	    my @refcoords2 = split /\s+/, $gene_locs{$ref_last_gene} ; 

	    $maxgene_length_ref =  $refcoords2[1] - $refcoords1[1]  ; 
	}

	my @ref_coord = split /\s+/, $gene_locs{$ref_gene} ;
	my @ref_last_coord = split /\s+/, $gene_locs{$ref_last_gene} ; 
	my @qry_coord = split /\s+/, $gene_locs{$qry_gene} ; 
	my @qry_last_coord = split /\s+/, $gene_locs{$qry_last_gene} ;

	# get strand infor
	if ( $ref_coord[1] < $ref_last_coord[1] ) {
	    $strand_ref = 'F' ; 
	}
	else {
	    $strand_ref = 'R' ; 
	}
	if ( $qry_coord[1] < $qry_last_coord[1] ) {
	    $strand_qry = 'F' ; 
	}
	else {
	    $strand_qry = 'R' ; 
	}

	print "$strand_ref$strand_qry\t" ; 

	print "$ref_gene\t$gene_locs{$ref_gene}\t$ref_last_gene\t$gene_locs{$ref_last_gene}\t" if $strand_ref eq 'F' ; 
	print "$ref_gene\t$gene_locs{$ref_gene}\t$ref_last_gene\t$gene_locs{$ref_last_gene}\t" if $strand_ref eq 'R' ;
	print "$qry_gene\t$gene_locs{$qry_gene}\t$qry_last_gene\t$gene_locs{$qry_last_gene}\n" if $strand_qry eq 'F' ; 
	print "$qry_last_gene\t$gene_locs{$qry_last_gene}\t$qry_gene\t$gene_locs{$qry_gene}\n" if $strand_qry eq 'R' ; 

	if ( $geneorder == $maxgene_order ) {
	    $maxgene_length_ref = $ref_last_coord[2] - $ref_coord[1] +1  ;
	    if ( $qry_last_coord[2] > $qry_coord[1] ) {
		$maxgene_length_qry = $qry_last_coord[2] - $qry_coord[1] +1  ;
	    }
	    else {
		$maxgene_length_qry = $qry_coord[2] - $qry_last_coord[1] +1  ;
	    }
        }



	# for bedtools calculation
	if ( $qry_coord[1] < $qry_last_coord[1] ) {
	    print OUTQRY "$qry_scaff\tdagchainer\tblock\t$qry_coord[1]\t$qry_last_coord[2]\t.\t+\t.\t$qry_gene.$qry_last_gene\n" ;
	}
	else {
	    print OUTQRY "$qry_scaff\tdagchainer\tblock\t$qry_last_coord[1]\t$qry_coord[2]\t.\t+\t.\t$qry_gene.$qry_last_gene\n" ;
	}
	if ( $ref_coord[1] < $ref_last_coord[1] ) {
	    print OUTREF "$ref_scaff\tdagchainer\tblock\t$ref_coord[1]\t$ref_last_coord[2]\t.\t+\t.\t$ref_gene.$ref_last_gene\n" ;
	}
	else {
	    print OUTREF "$ref_scaff\tdagchainer\tblock\t$ref_last_coord[1]\t$ref_coord[2]\t.\t+\t.\t$ref_gene.$ref_last_gene\n" ;
	}


    }


}
close(IN) ; 


close(OUTREF)  ;
system("bedtools sort -i $filenameA.ref.gff > $filenameA.ref.sorted.gff") ; 
system("bedtools merge -i $filenameA.ref.sorted.gff > $filenameA.ref.sorted.uniq.bed") ; 

close(OUTQRY) ; 
system("bedtools sort -i $filenameA.qry.gff > $filenameA.qry.sorted.gff") ; 
system("bedtools merge -i $filenameA.qry.sorted.gff > $filenameA.qry.sorted.uniq.bed") ; 

open REFGENE, ">", "$filenameA.ref.genes" or die "diaodisaoda\n" ; 
for my $gene (sort keys %ref_genes) {
    print REFGENE "$gene\n" ; 
}
open QRYGENE, ">", "$filenameA.qry.genes" or die "daidosaidai\n" ; 
for my $gene (sort keys %qry_genes) {
    print QRYGENE "$gene\n" ; 
}
close(REFGENE) ; 
close(QRYGENE) ; 


my $refsum = 0 ; 
my $qrysum = 0 ; 

open (IN, "$filenameA.ref.sorted.uniq.bed") or die "dakldjalkda\n" ; 
while (<IN>) {
    chomp; 
    my @r = split /\s+/, $_ ; 
    $refsum += ($r[2] - $r[1] +1 ) ; 
}
close(IN); 

open (IN, "$filenameA.qry.sorted.uniq.bed") or die "dakldjalkda\n" ;
while (<IN>) {
    chomp;
    my @r = split /\s+/, $_ ;
    $qrysum += ($r[2] - $r[1] +1 ) ;
}
close(IN);




print "\#\#reference syntenic region: $refsum\n" ; 
print "\#\#reference genes in synteny: " . (scalar keys %ref_genes) . "\n\#\#\n" ; 

print "\#\#query syntenic region: $qrysum\n" ;
print "\#\#quey genes in synteny: : ". (scalar keys %qry_genes) . "\n" ; 

print "\#\#longest number of gene synteny : $maxgene_order\n" ; 
print "\#\#longest block in ref: $maxgene_length_ref bp\n" ; 
print "\#\#longest block in qry: $maxgene_length_qry bp\n" ;


