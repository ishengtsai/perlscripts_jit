#!/usr/bin/perl -w
use strict;



if (@ARGV != 1) {
    print "$0 Amborella_trichopoda_annos1-cds0-id_typename-nu1-upa1-add_chr0.gid36588.gff\n" ; 



	exit ;
}

my $file = shift @ARGV;



open (IN, "$file") or die "oops!\n" ;

my $exon_num = 0  ;
my $gene = '' ; 
  

my %gene_start = () ; 
my %gene_end = () ; 
my %gene_strand = () ; 
my %gene_exons = () ; 

my %scaffolds = () ; 


while (<IN>) {
    next if /\#/ ; 

    my @r = split /\t/, $_ ; 




    if ( $r[2] eq 'CDS' && $r[8] =~ /^Parent=(\S+\.1)-OS.+\;ID/ ) {

	$gene = $1 ; 




#	print "$_" ; 

	if ( $gene_start{$gene} ) {
	    $gene_start{$gene} = $r[3] if  $r[3] < $gene_start{$gene} ;
	}
	else {
	    $gene_start{$gene} = $r[3] ; 
	}

	if ( $gene_end{$gene} ) {
	    $gene_end{$gene} = $r[4]  if  $r[4] > $gene_end{$gene} ; 
	}
	else {
	    $gene_end{$gene} = $r[4] ; 
	}

	$scaffolds{$r[0]}{$gene}++ ; 
	$gene_strand{$gene} = $r[6] ; 
	$gene_exons{$gene} .= "$_" ; 
    }




}
close(IN); 


for my $scaff (sort { $a cmp $b } keys %scaffolds ) {

    my %scaffold_order = () ; 
    for my $geneinscaff ( keys %{ $scaffolds{$scaff} } ) {
	if ( $scaffold_order { $gene_start{$geneinscaff} } ) {
	    
	    print "$geneinscaff is same as $gene_start{$geneinscaff} " . $scaffold_order { $gene_start{$geneinscaff} } . " !!!! exiting...\n" ; 
	    exit ; 
	}
	$scaffold_order { $gene_start{$geneinscaff} }  = $geneinscaff ; 
    }


    for my $geneorder (sort { $a <=> $b } keys %scaffold_order ) {
	my $geneinscaff = $scaffold_order { $geneorder } ; 
	my $strand = $gene_strand{$geneinscaff} ; 

	#print "strand: $strand\n" ; 

	print "$scaff\tCoge\tgene\t$gene_start{$geneinscaff}\t$gene_end{$geneinscaff}\t.\t$strand\t.\tID=$geneinscaff\;Name=$geneinscaff\n" ; 
	print "$scaff\tCoge\tmRNA\t$gene_start{$geneinscaff}\t$gene_end{$geneinscaff}\t.\t$strand\t.\tID=$geneinscaff:mRNA\;Name=$geneinscaff:mRNA\;Parent=$geneinscaff\n" ;
	

	my @exons = split /\n/, $gene_exons{$geneinscaff} ; 

	my $isreverse = 0 ; 

	if ( @exons > 1 ) {

	    my $exon1start = 0 ; 
	    my $exon2start = 0 ; 


	    if ( $exons[0] =~ /exon\s+(\d+)\s+/ ) {
		$exon1start = $1 ; 
	    }
	    if ( $exons[1] =~ /exon\s+(\d+)\s+/) {
		$exon2start = $1 ;
	    }

	    $isreverse = 1 if $exon1start > $exon2start ; 

	}



	if ( $isreverse == 1 ) {
	    my @reversedExons = reverse(@exons) ;
             @exons = @reversedExons ;
	}

	my $exonnum = 1 ; 
	foreach (@exons) {
	    my @r = split /\s+/, $_ ; 

	    print "$scaff\tCoge\texon\t$r[3]\t$r[4]\t.\t$strand\t.\tID=$geneinscaff:exon:$exonnum\;Parent=$geneinscaff:mRNA;\n" ; 
	    $exonnum++ ; 
	}
	


	


    } 


}
