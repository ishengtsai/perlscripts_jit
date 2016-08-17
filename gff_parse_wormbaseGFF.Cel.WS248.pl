#!/usr/bin/perl -w
use strict;



if (@ARGV != 4) {
    print "$0 c_elegans.PRJNA13758.WS248.protein.fa c_elegans.PRJNA13758.WS248.annotations.gff2 CEL.WS248.gff CEL.WS248.forcuff.gtf\n" ; 
    exit ;
}

my $fasfile = shift @ARGV ; 
my $file = shift @ARGV;

my $outfile1 = shift @ARGV ; 
my $outfile2 = shift @ARGV ; 

open OUT, ">" , "$outfile1" or die "can't oepn $outfile1\n" ; 
open OUT2, ">" ,"$outfile2" or die "can't oepn $outfile2\n" ; 

my %fasta = () ; 
my %WBname = () ; 

open(IN, "$fasfile") or die "daodsiaosid\n" ; 
while (<IN>) {

    chomp; 
    if ( />(\S+)\s+\S+\s+(\S+)/ ) {
	$fasta{$1}++ ; 
	$WBname{$1} = $2 ; 
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

    my @r = split /\s+/, $_ ; 

    next unless "$r[1]" eq "Coding_transcript" ; 



    if ( $r[2] eq 'coding_exon' ) {

	if ( $r[12] =~ /"(\S+)"/ ) {
	    $gene = $1 ; 
	}
	else {
	    next ; 
	}

	if ( $fasta{$gene} ) {

	}
	else {
	    print "$gene not found in protein sequence!!! weird!\n" ; 
	}



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

	print "$_" if $gene eq 'Bm14341' ; 

    }




}
close(IN); 






for my $scaff (sort { $a cmp $b } keys %scaffolds ) {
    
    my %scaffold_order = () ;
    for my $geneinscaff ( keys %{ $scaffolds{$scaff} } ) {
	if ( $scaffold_order { $gene_start{$geneinscaff} } ) {
		print "$geneinscaff is same as " . $scaffold_order { $gene_start{$geneinscaff} } . " !!!! skip...\n" ;
		#exit ;
	}
	$scaffold_order { $gene_start{$geneinscaff} }  = $geneinscaff ;
    }
    
    
    for my $geneorder (sort { $a <=> $b } keys %scaffold_order ) {
	my $geneinscaff = $scaffold_order { $geneorder } ;
	my $strand = $gene_strand{$geneinscaff} ;
	


	#print "strand: $strand\n" ; 
	my $WB = $WBname{$geneinscaff} ; 

	print OUT "$scaff\twormbase\tgene\t$gene_start{$geneinscaff}\t$gene_end{$geneinscaff}\t.\t$strand\t.\tID=$WB\;Name=$WB\n" ; 
	print OUT "$scaff\twormbase\tmRNA\t$gene_start{$geneinscaff}\t$gene_end{$geneinscaff}\t.\t$strand\t.\tID=$WB:mRNA\;Name=$WB:mRNA\;Parent=$WB\n" ;
	

	my @exons = split /\n/, $gene_exons{$geneinscaff} ; 
        my %order = () ;


        if (  $#exons > 0 ) {
            for( my $i = 0 ; $i < @exons ; $i++) {
                my @thisexon = split /\s+/, $exons[$i] ;
                $order{$thisexon[3]} = $exons[$i] ;

                #print "$thisexon[3]\t$exons[$i]\n" ;
            }

            @exons = () ;
            for my $exon (sort { $a <=> $b } keys %order ) {
                #print "$exon\n" ;
                push(@exons, $order{$exon}) ;
            }

        }



	my $exonnum = 1 ; 
	foreach (@exons) {
	    my @r = split /\s+/, $_ ; 

	    print OUT "$scaff\twormbase\texon\t$r[3]\t$r[4]\t.\t$strand\t.\tID=$WB:exon:$exonnum\;Parent=$WB:mRNA\n" ; 
	    print OUT2 "$scaff\twormbase\texon\t$r[3]\t$r[4]\t.\t$strand\t.\tgene_id \"$WB\" transcript_id \"$WB:mRNA\" exon_number \"$exonnum\"\n" ; 

	    $exonnum++ ; 
	}
	


	


    }





}
