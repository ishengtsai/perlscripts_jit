#!/usr/bin/perl -w
use strict;



if (@ARGV != 5) {
	print "$0 embl seq_name assembly.fa species start_ID\n\n" ;
	exit ;
}

my $embl = shift @ARGV;
my $seq_name = shift @ARGV ;
my $contig_file = shift @ARGV ; 
my $species = shift @ARGV ;
my $id = shift @ARGV ;

my %fasta = () ; 

system("fasta2singleLine_IMAGE.pl $contig_file zzzzzz.tmp.fa") ; 

open (IN, "zzzzzz.tmp.fa") or die "ppp\n" ; 

while(<IN>) {

    if (/>(\S+)/) {
	my $name = $1 ; 
	my $seq = <IN> ; 
	chomp ($seq) ; 
	$fasta{$name} = $seq ; 
    }

}
close(IN) ; 
system("rm zzzzzz.tmp.fa") ; 


open (IN, "$embl") or die "oops!\n" ;

open OUT, ">", "$embl.gff" or die "oooops\n" ;
open OUT_PARTIAL , ">", "$embl.partial.gff" or die "oooops\n" ;
open OUTTRAIN, ">", "$embl.augustus.train.gff" or die "ooops\n" ; 
open OUTTRAINGENE, ">", "$embl.augustus.train.gene.gff" or die "ooops\n" ;

open OUT_AA, ">", "$embl.aa.fa" or die "oooooooops\n" ; 
open OUT_AA_PART , ">", "$embl.aa.truncated.fa" or die "ooooooooooooops\n" ; 

open OUTHINTS, ">", "$embl.augustus.hints.gff" or die "oooops\n" ; 


#print OUT "\#\#gff-version3\n" ;

my %models_studied = () ; 

my %gene_present = () ;
my %gene_coords = () ; 
my %gene_annotation = () ; 
my %gene_truncated = () ; 

my %gene_augustus_train = () ; 
my %gene_augustus_hints = () ; 

my $count = 1 ; 
my $genecount = $id ;

while (<IN>) {

	chomp ;
	my $model = $_ ; 
	my $seq = '' ; 
	
	if ( /(^\S+)/ ) {
	    $model = $1 ; 
	}
	else {
	    next ; 
	}

	if ( $models_studied{$model} ) {
            print "model already present!\n" ;
            next ;
        }
	else {
	#    print "model: $model\n" ;
	}
	
	#my $gene_name = "$seq_name.curated.$count" ;
	my $exon = 1 ;

	my $idnum = sprintf("%07d", $genecount * 100) ;
	my $gene_name = "$species\_$idnum" ;


	my $strand = '+' ;
	$strand = '-' if $model =~ /complement/ ;
	
	#remove unnecessary lines
	$model =~ s/\(//g ;
	$model =~ s/\)//g ;
	$model =~ s/complement//g ;
	$model =~ s/join//g ;
	

	
	if ( $models_studied{$model} ) {
	    print "model already present!\n" ; 
	    next ; 
	}


	my @cds = split (/,/ , $model ) ; 
	my $left = 0 ;
	my $right = 0 ;
	
	my $dodgy = 0 ;
	
	# check for errors
	
	# ALSO HERE!!! PUT PROTEIN SEQUENCES OUT!!!!!!!
	# VERY IMPORTANT!!!!!

	for (my $i = 0 ; $i < @cds ; $i++) {
	    unless ( $cds[$i] =~ /\.\./ ) {
		print "skip $gene_name! exon size dodgy\n" ;	
		$dodgy = 1 ;
		last ;
	    }	
	    
	    my @exon = split ( /\.\./ , $cds[$i] ) ; 
	    
			if ($exon[1] <= $exon[0] ) {
			    print "warning! $gene_name ! exon size reversed in embl!\n" ;
			    $cds[$i] = "$exon[1]..$exon[0]" ; 
			    #$dodgy = 1 ;	
			    #last ;
			    
			    $seq .= substr( $fasta{$seq_name}, $exon[1]-1, $exon[0]-$exon[1]+1  ) ; 
			}
	    else {
		$seq .= substr( $fasta{$seq_name}, $exon[0]-1, $exon[1]-$exon[0]+1  ) ;
	    }
	    
	    if ( $exon[0] < 1 || $exon[1] < 1 ) {
		print "skip $gene_name! exon coord negative!? in embl\n" ;
			    $dodgy = 1 ;
		last ;
	    }
	    
	    
	    if ($i == 0 ) {						
		$left = $exon[0] ;	
			}
	    if ($i == $#cds ) {
		$right = $exon[1] ;		
	    }
	    
	}
	
		    last if $dodgy == 1 ;
	
	
	my $mRNA = 1 ;
	

		    
	
	# here to check the transcript
	if ( $strand eq '-' ) {
	    $seq = revcom($seq) ; 
	}
	my $aa_seq = dna2peptide($seq) ; 
	
	#print ">$gene_name\t$strand\n$seq\n\n$aa_seq\n" ; 

	# exclude gene length < 100bp!
	if ( $right - $left < 100 ) {
	    print "$gene_name $model extrmely short!?!\n" ; 
	    last ; 
	}
	
	
	my $start = substr ($aa_seq,0,1) ; 
	my $end = substr ($aa_seq, -1,1) ; 
	
	if ( $start ne 'M' || $end ne '_' ) {
	    print "$gene_name $model truncated!\n" ; 
			#last;
	    $gene_truncated{$gene_name}++ ; 
	}
	

	$aa_seq =~ s/_$// ; 

	if ( $aa_seq =~ /0/ || $aa_seq =~ /_/ ) {
	    print "$gene_name $model premature stop codon?\n" ;
	    #last;
	    $gene_truncated{$gene_name}++ ;
	}
	
	
	# print out amino acid sequence
	if ( $gene_truncated{$gene_name} ) {
	    print OUT_AA_PART ">$gene_name\n$aa_seq\n" ;
	}
	else {
	    print OUT_AA ">$gene_name\n$aa_seq\n" ;
	}
	
	
	my $overlap = 0 ; 
	my $most_right = 0 ; 
	
	for (my $i = 0 ; $i < @cds ; $i++) {
	    my @exon = split (/\.\./ , $cds[$i] ) ;
	    
	    
	    if ($exon[0] == $most_right+1 || $exon[1] == $most_right+1 ) {
		print "$gene_name annotation no intron!\n" ; 
		$gene_truncated{$gene_name}++ ;
	    }
	    elsif ( $exon[0] > $most_right && $exon[1] > $most_right ) {
                            $most_right = $exon[1] ;
	    }
	    else {
		print "$gene_name annotation overlapped!\n" ; 
		$gene_truncated{$gene_name}++ ;
	    }
	    
	    
	    if ( $i == 0 && $exon[1] - $exon[0] < 2 ) {
		print "$gene_name first/last exon smaller than 3! $model \n" ;
		$gene_truncated{$gene_name}++ ;
	    }
	    if ( $i == $#cds && $exon[1] - $exon[0] < 2 ) {
		print "$gene_name first/last exon smaller than 3! $model\n" ;
		$gene_truncated{$gene_name}++ ;
	    }

	    
	}
	
	

	
	unless ( $gene_present{$gene_name} ) {			
	    
	    print OUTTRAINGENE "$seq_name\tembl\tgene\t$left\t$right\t1000\t$strand\t.\tID=$gene_name\;Name=$gene_name\n" ;
	    $gene_present{$gene_name}++ ;
	    $gene_coords{$seq_name}{ $left }{$gene_name}++ ; 
			$gene_annotation{ $gene_name } .= "$seq_name\tmanual\tgene\t$left\t$right\t1000\t$strand\t.\tID=$gene_name\;Name=$gene_name\n" ;
	    
	    
	}
	else {
	    print "$gene_name already found!\n" ;	
	}
	
	
	#print OUT "$seq_name\tembl\tmRNA\t$left\t$right\t.\t$strand\t.\tID=\"$gene_name.$mRNA\"\;Parent=\"$gene_name\"\n" ;
	$gene_annotation{ $gene_name } .= "$seq_name\tmanual\tmRNA\t$left\t$right\t.\t$strand\t.\tID=$gene_name.$mRNA:mRNA\;Name=$gene_name.$mRNA:mRNA\;Parent=$gene_name\;\n" ;
	
	
		    # get exon out	
	for (my $i = 0 ; $i < @cds ; $i++) {
	    my @exon = split (/\.\./ , $cds[$i] ) ;
	    #print OUT "$seq_name\tembl\tCDS\t$exon[0]\t$exon[1]\t1000\t$strand\t3\tID=\"$gene_name.$mRNA:exon:" .($i+1). "\"\;Parent=\"$gene_name.$mRNA\"\n" ;
	    
	    if ( $exon[0] > $exon[1] ) {
		print "$gene_name wierd!!!! has exon coords reversed!\n" ;
		$gene_annotation{ $gene_name } .= "$seq_name\tmanual\texon\t$exon[1]\t$exon[0]\t1000\t$strand\t3\tID=$gene_name.$mRNA:exon:" .($i+1). "\;Name=$gene_name.$mRNA:exon:" .($i+1). "\;Parent=$gene_name.$mRNA:mRNA\;color=2\;\n" ;
	    }
	    else {
			    $gene_annotation{ $gene_name } .= "$seq_name\tmanual\texon\t$exon[0]\t$exon[1]\t1000\t$strand\t3\tID=$gene_name.$mRNA:exon:" .($i+1). "\;Name=$gene_name.$mRNA:exon:" .($i+1). "\;Parent=$gene_name.$mRNA:mRNA\;color=2\;\n" ;

			    $gene_augustus_train{ $gene_name } .= "$seq_name\tmanual\texon\t$exon[0]\t$exon[1]\t1000\t$strand\t3\ttranscript_id \"$gene_name\"\n" ; 
			    $gene_augustus_hints{ $gene_name } .= "$seq_name\tmanual\texon\t$exon[0]\t$exon[1]\t.\t$strand\t.\tpri=5\;src=M\n" ; 
	    }
	    
	   
	    #$gene_annotation{ $gene_name } .= "$seq_name\tembl\texon\t$exon[0]\t$exon[1]\t1000\t$strand\t3\tID=\"$gene_name.$mRNA:exon:" .($i+1). "\"\;Parent=\"$gene_name.$mRNA\"\n" ;
	    
	}
	


	$count++ ; 
	$genecount++ ; 
		
	
}



for my $scaffold ( sort keys %gene_coords ) {
    
    for my $coords ( sort { $a <=> $b }  keys %{ $gene_coords{$scaffold} } ) {
	
	for my $gene_name ( keys % { $gene_coords{$scaffold}{$coords} } ) {
	    
	    if ( $gene_truncated{$gene_name} ) {
		print OUT_PARTIAL  "$gene_annotation{ $gene_name }" ;
		print OUT "$gene_annotation{ $gene_name }" ;
	    }
	    else {
		print OUT "$gene_annotation{ $gene_name }" ;

		my $train = "$gene_augustus_train{ $gene_name }" ; 
		$train =~ s/exon/CDS/gi ; 
		print OUTTRAIN "$train" ; 


		print OUTHINTS "$gene_augustus_hints{ $gene_name }" ;
	    }
	}
	
	
    }
    
}


print "\n\n\n All done all done!!!\n $count genes curated in this case\n" ; 



# dna2peptide
#
# A subroutine to translate DNA sequence into a peptide

sub dna2peptide {

    my($dna) = @_;

    # Initialize variables
    my $protein = '';

    # Translate each three-base codon to an amino acid, and append to a protein
    for(my $i=0; $i < (length($dna) - 2) ; $i += 3) {
        $protein .= codon2aa( substr($dna,$i,3) );
    }

    return $protein;
}


#
# codon2aa
#
# A subroutine to translate a DNA 3-character codon to an amino acid
#   Version 3, using hash lookup

sub codon2aa {
    my($codon) = @_;
    $codon = uc $codon;

    my(%genetic_code) = (

    'TCA' => 'S',    # Serine
    'TCC' => 'S',    # Serine
    'TCG' => 'S',    # Serine
    'TCT' => 'S',    # Serine
    'TTC' => 'F',    # Phenylalanine
    'TTT' => 'F',    # Phenylalanine
    'TTA' => 'L',    # Leucine
    'TTG' => 'L',    # Leucine
    'TAC' => 'Y',    # Tyrosine
    'TAT' => 'Y',    # Tyrosine
    'TAA' => '_',    # Stop
    'TAG' => '_',    # Stop
    'TGC' => 'C',    # Cysteine
    'TGT' => 'C',    # Cysteine
    'TGA' => '_',    # Stop
    'TGG' => 'W',    # Tryptophan
    'CTA' => 'L',    # Leucine
    'CTC' => 'L',    # Leucine
    'CTG' => 'L',    # Leucine
    'CTT' => 'L',    # Leucine
    'CCA' => 'P',    # Proline
    'CCC' => 'P',    # Proline
    'CCG' => 'P',    # Proline
    'CCT' => 'P',    # Proline
    'CAC' => 'H',    # Histidine
    'CAT' => 'H',    # Histidine
    'CAA' => 'Q',    # Glutamine
    'CAG' => 'Q',    # Glutamine
    'CGA' => 'R',    # Arginine
    'CGC' => 'R',    # Arginine
    'CGG' => 'R',    # Arginine
    'CGT' => 'R',    # Arginine
    'ATA' => 'I',    # Isoleucine
    'ATC' => 'I',    # Isoleucine
    'ATT' => 'I',    # Isoleucine
    'ATG' => 'M',    # Methionine (Start)
    'ACA' => 'T',    # Threonine
    'ACC' => 'T',    # Threonine
    'ACG' => 'T',    # Threonine
    'ACT' => 'T',    # Threonine
    'AAC' => 'N',    # Asparagine
    'AAT' => 'N',    # Asparagine
    'AAA' => 'K',    # Lysine
    'AAG' => 'K',    # Lysine
    'AGC' => 'S',    # Serine
    'AGT' => 'S',    # Serine
    'AGA' => 'R',    # Arginine
    'AGG' => 'R',    # Arginine
    'GTA' => 'V',    # Valine
    'GTC' => 'V',    # Valine
    'GTG' => 'V',    # Valine
    'GTT' => 'V',    # Valine
    'GCA' => 'A',    # Alanine
    'GCC' => 'A',    # Alanine
    'GCG' => 'A',    # Alanine
    'GCT' => 'A',    # Alanine
    'GAC' => 'D',    # Aspartic Acid
    'GAT' => 'D',    # Aspartic Acid
    'GAA' => 'E',    # Glutamic Acid
    'GAG' => 'E',    # Glutamic Acid
    'GGA' => 'G',    # Glycine
    'GGC' => 'G',    # Glycine
    'GGG' => 'G',    # Glycine
    'GGT' => 'G',    # Glycine
        );

    if(exists $genetic_code{$codon}) {
        return $genetic_code{$codon};
    }else{

            #print STDERR "Bad codon \"$codon\"!!\n";
        return 0 ;

    }
}


sub revcom {

    my($dna) = @_;

    # First reverse the sequence
    my $revseq = reverse ($dna);

    # Next, complement the sequence, dealing with upper and lower case
    # A->T, T->A, C->G, G->C
    $revseq =~ tr/ACGTacgt/TGCAtgca/;

    return $revseq;
}



