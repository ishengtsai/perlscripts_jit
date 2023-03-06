#!/usr/bin/perl -w
use strict;



if (@ARGV != 3) {
	print "$0 gff fasta  outprefix \n\n" ;
	exit ;
}

my $file = shift @ARGV;
my $fastafile = shift @ARGV ;
my $prefix = shift @ARGV ; 


my $contig_name = '' ;

my %fasta = () ;

## read the fastas
open (IN, "$fastafile") or die "oops!\n" ;
my $read_name = '' ;
my $read_seq = '' ;
while (<IN>) {
            if (/^>(\S+)/) {
                $read_name = $1 ;
                $read_seq = "" ;

                while (<IN>) {

                        if (/^>(\S+)/) {

                            $fasta{$read_name} = $read_seq ;
                            $read_name = $1 ;
                            $read_seq = "" ;

                        }
                        else {
                            chomp ;
                            $read_seq .= $_ ;
                        }


                }

            }
}
close(IN) ;
$fasta{$read_name} = $read_seq ;



open (IN, "$file") or die "oops!\n" ;

open OUTAA, ">", "$prefix.aa.fa" or die "oooops\n" ; 
open OUTNUC, ">", "$prefix.nuc.fa" or die "doapdoaopdoa\n" ; 
open OUT_FAULT, ">", "$prefix.fault" or die "oooops\n" ;



my %gene_seqs = () ;
my %gene_features = () ;

## read in the cufflink annotations
while (<IN>) {
	
	chomp ;
	my @r = split /\s+/, $_ ;
	
	#next if $r[0] ne $contig_name ;

	next if $r[2] eq 'gene' ;

	if ($r[2] eq 'mRNA') {

	    #chrIII_RagTag   Liftoff mRNA    1367    2107    .       +       .       ID=YCL076W_mRNA;Name=YCL076W_mRNA;Parent=YCL076W;extra_copy_number=0

	    #SGD format
	    if ( /ID=(\S+)_mRNA\;Name/ ) {
		$gene_features{$1} = "$r[0].$r[3]-$r[4].$1" ;
	    }


	    next ;
	}




	next if $r[2] ne 'CDS' ;


	my $transcript = '' ;

	if ( /Parent=(\S+)_mRNA;Name/) {
	    $transcript = $1 ;
	#    print "$transcript here!\n" ; 
	}	



	my $seq = substr($fasta{$r[0]}, ($r[3]-1), ($r[4]-$r[3]+1) ) ;			
	$gene_seqs{$transcript} .= $seq ;


	#last;
}
close(IN) ;


my $start = 0 ;
my $end = 0 ;

my $total_genes = 0 ; 
my $fault_genes = 0 ; 
my $premature_stop_genes = 0 ;


for my $gene ( keys %gene_features ) {


    $total_genes++ ; 
    $start = 0 ;
    $end = 0 ;


    # quick hack script
    $gene_seqs{$gene} = uc($gene_seqs{$gene}) ;
    



    my $aa_start = substr($gene_seqs{$gene}, 0 , 3) ;
    my $aa_end = substr($gene_seqs{$gene}, length($gene_seqs{$gene})-3, 3) ;

    $start = 1 if $aa_start eq 'ATG' ;
    $start = 2 if $aa_end eq 'CAT' ;



    if ( $start == 0 ) {
	print OUT_FAULT "$gene no start!\n" ;
	print OUT_FAULT "$gene_seqs{$gene}\n\n" ; 

	$fault_genes++ ; 
	next ;
    }

    if ( $start == 1) {
	$end = 1 if $aa_end eq 'TAA' ;
	$end = 1 if $aa_end eq 'TAG' ;
	$end = 1 if $aa_end eq 'TGA' ;
    }
    elsif ( $start == 2 ) {	
	$end = 1 if $aa_start eq 'TTA' ;
	$end = 1 if $aa_start eq 'CTA' ;
	$end = 1 if $aa_start eq 'TCA' ;
    }


    # check if it's bad
    if ( $start == 1 && $end != 1 ) {

	print OUT_FAULT "$gene no end! len:" .(length($gene_seqs{$gene})).  " $aa_start\t$aa_end\n" ;
	print OUT_FAULT "$gene_seqs{$gene}\n\n";

	$fault_genes++ ;
	next;
    }
    elsif ( $gene_seqs{$gene}  =~ /N/ ) {
	$fault_genes++ ;
        next;
    }



    #print "$gene\t$aa_start\t$aa_end\n" ;


    my $seq = '' ;
    if ( $start == 1 ) {
	
	$seq = dna2peptide($gene_seqs{$gene}) ;
	
    }
    else {
	my $seq_tmp = revcom($gene_seqs{$gene}) ;
	$seq = dna2peptide($seq_tmp) ;
	
    }


    # remove the last stop codon    
    $seq =~ s/_$//gi ; 


    
    if ( $seq =~ /_/ ) {
	#print "$gene contain premature stop codons!\n" ;
	$premature_stop_genes++ ;
	next; 
    }

	
    # print out aa sequence
    print OUTAA ">$gene\n$seq\n" ;

	
    if ( $start == 1 ) {
	print OUTNUC ">$gene\n$gene_seqs{$gene}\n" ;
    }
    else {
	my $seq_tmp = revcom($gene_seqs{$gene}) ;
	print OUTNUC ">$gene\n$seq_tmp\n" ;
    }
	

    



    
}

print "total genes: $total_genes\n" ;
print "genes without ATG or STOP: $fault_genes\n" ; 
print "genes with premature STOP: $premature_stop_genes\n" ; 

print "all done!!!\n" ;



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

        print STDERR "Bad codon \"$codon\"!!\n";
	return 'X' ;
	#exit ; 
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
