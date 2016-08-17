#!/usr/bin/perl -w
use strict;



if (@ARGV != 5) {
    print "$0 a_suum.PRJNA62057.WS248.genomic.fa a_suum.PRJNA80881.WS248.annotations.gff3 key a_suum.WS248.gff a_suum.WS248.htseq.gtf\n\n" ;

	exit ;
}

my $fasfile = shift @ARGV ; 
my $file = shift @ARGV;
my $keyfile = shift @ARGV ; 

my $outfile1 = shift @ARGV ; 
my $outfile2 = shift @ARGV ; 

open OUT, ">" , "$outfile1" or die "can't oepn $outfile1\n" ; 
open OUT2, ">" ,"$outfile2" or die "can't oepn $outfile2\n" ; 

my %fasta = () ; 
open(IN, "$fasfile") or die "daodsiaosid\n" ; 
while (<IN>) {

    chomp; 
    if ( />(\S+)/ ) {
	$fasta{$1}++ ; 
    }


}
close(IN) ; 

my %key = () ; 

open (IN, "$keyfile") or die "daodpao\n" ; 
while (<IN>) {

    if ( /(\S+)\s+(\S+)/ ) {
	$key{$1} = $2 ; 
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

    next unless "$r[1]" eq "WormBase_imported" ; 


    if ( $r[2] eq 'CDS' ) {

	if ( $r[8] =~ /ID=cds:(\S+)\;Parent/ ) {
	    #print "$1 found!\n" ; 

	    if ( $key{$1} ) {
		$gene = $key{$1} ; 
	    }
	    else {
		#print "$1 not found!\n" ; 
		next ; 
	    }

        #  print "$gene\n" ; 
	#    $gene = $1 ; 
	}
	else {
	    next ; 
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

	print OUT "$scaff\twormbase\tgene\t$gene_start{$geneinscaff}\t$gene_end{$geneinscaff}\t.\t$strand\t.\tID=$geneinscaff\;Name=$geneinscaff\n" ; 
	print OUT "$scaff\twormbase\tmRNA\t$gene_start{$geneinscaff}\t$gene_end{$geneinscaff}\t.\t$strand\t.\tID=$geneinscaff:mRNA\;Name=$geneinscaff:mRNA\;Parent=$geneinscaff\n" ;
	

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

	    print OUT "$scaff\twormbase\texon\t$r[3]\t$r[4]\t.\t$strand\t.\tID=$geneinscaff:exon:$exonnum\;Parent=$geneinscaff:mRNA\n" ; 
	    print OUT2 "$scaff\twormbase\texon\t$r[3]\t$r[4]\t.\t$strand\t.\tgene_id \"$geneinscaff\"\; transcript_id \"$geneinscaff:mRNA\"\; exon_number \"$exonnum\"\;\n" ; 

	    $exonnum++ ; 
	}
	


	


    }





}
