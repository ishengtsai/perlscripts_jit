#!/usr/bin/perl -w
use strict;



if (@ARGV != 2) {
    print "$0 tmp.fa a_suum.PRJNA80881.WS238.annotations.gff3\n" ; 


	exit ;
}
my $fasfile = shift @ARGV ; 
my $file = shift @ARGV;


my %fasta = () ; 
open(IN, "$fasfile") or die "daodsiaosid\n" ; 
while (<IN>) {

    chomp; 
    if ( />(\S+)/ ) {
	$fasta{$1}++ ; 
    }


}
close(IN) ; 

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




    if ( $r[2] eq 'exon' ) {

	if ( $r[8] =~ /Parent=transcript:transcript:(\S+)/ ) {
	    $gene = $1 ; 
	}

	next unless $fasta{$gene} ;

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
	    print "$geneinscaff is same as " . $scaffold_order { $gene_start{$geneinscaff} } . " !!!! exiting...\n" ; 
	    exit ; 
	}
	$scaffold_order { $gene_start{$geneinscaff} }  = $geneinscaff ; 
    }


    for my $geneorder (sort { $a <=> $b } keys %scaffold_order ) {
	my $geneinscaff = $scaffold_order { $geneorder } ; 
	my $strand = $gene_strand{$geneinscaff} ; 

	#print "strand: $strand\n" ; 

	print "$scaff\twormbase\tgene\t$gene_start{$geneinscaff}\t$gene_end{$geneinscaff}\t.\t$strand\t.\tID=$geneinscaff\;Name=$geneinscaff\n" ; 
	print "$scaff\twormbase\tmRNA\t$gene_start{$geneinscaff}\t$gene_end{$geneinscaff}\t.\t$strand\t.\tID=$geneinscaff:mRNA\;Name=$geneinscaff:mRNA\;Parent=$geneinscaff\n" ;
	

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

	    print "$scaff\twormbase\texon\t$r[3]\t$r[4]\t.\t$strand\t.\tID=$geneinscaff:exon:$exonnum\;Parent=$geneinscaff:mRNA\n" ; 
	    $exonnum++ ; 
	}
	


	


    } 


}
