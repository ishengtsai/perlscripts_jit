#!/usr/bin/perl -w
use strict;



if (@ARGV != 5) {
    print "$0 ratti.protein.singleLine.fa ratti.gff BMA.WS235.gff BMA.WS235.forcuff.gtf xxx.forortho.fa \n\n" ;


	exit ;
}
my $fasfile = shift @ARGV ; 
my $file = shift @ARGV;

my $outfile1 = shift @ARGV ; 
my $outfile2 = shift @ARGV ; 
my $outfile3 = shift @ARGV ;

open OUT, ">" , "$outfile1" or die "can't oepn $outfile1\n" ; 
open OUT2, ">" ,"$outfile2" or die "can't oepn $outfile2\n" ; 
open OUT3, ">" , "$outfile3" or die "odspaodppaod\n" ; 

my %fasta = () ; 
open(IN, "$fasfile") or die "daodsiaosid\n" ; 
while (<IN>) {

    chomp; 
    if ( />(TMUE_s\d+)/ ) {
	$fasta{"$1"}++ ; 


	print OUT3 ">$1\n" ; 
	my $seq = <IN> ; 
	print OUT3 "$seq" ; 
	


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



    if ( $r[2] eq 'CDS' ) {

	if ( $r[8] =~ /Parent=(\S+):mRNA/ ) {
	    $gene = "$1" ; 
	}

	unless ( $fasta{$gene} ) {
	    print "$gene not found in fasta!\n" ; 
	}

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


for my $gene (sort keys %fasta ) {

    print "$gene not found\n" unless $gene_exons{$gene} ; 
}




for my $scaff (sort { $a cmp $b } keys %scaffolds ) {

    for my $geneinscaff (sort { $a cmp $b } keys %{ $scaffolds{$scaff} } ) {
	my $strand = $gene_strand{$geneinscaff} ; 

	#print "strand: $strand\n" ; 

	print OUT "$scaff\twormbase\tgene\t$gene_start{$geneinscaff}\t$gene_end{$geneinscaff}\t.\t$strand\t.\tID=$geneinscaff\;Name=$geneinscaff\n" ; 
	print OUT "$scaff\twormbase\tmRNA\t$gene_start{$geneinscaff}\t$gene_end{$geneinscaff}\t.\t$strand\t.\tID=$geneinscaff:mRNA\;Name=$geneinscaff:mRNA\;Parent=$geneinscaff\n" ;
	

	my @exons = split /\n/, $gene_exons{$geneinscaff} ; 

	#if ( $gene_strand{$geneinscaff} eq '-') {
	#    my @reversedExons = reverse(@exons) ;
        #    @exons = @reversedExons ;
	#}

	my $exonnum = 1 ; 
	foreach (@exons) {
	    my @r = split /\s+/, $_ ; 

	    print OUT "$scaff\twormbase\texon\t$r[3]\t$r[4]\t.\t$strand\t.\tID=$geneinscaff:exon:$exonnum\;Parent=$geneinscaff:mRNA\n" ; 
	    print OUT2 "$scaff\twormbase\texon\t$r[3]\t$r[4]\t.\t$strand\t.\tgene_id \"$geneinscaff\" transcript_id \"$geneinscaff:mRNA\" exon_number \"$exonnum\"\n" ; 

	    $exonnum++ ; 
	}
	


	


    } 


}
