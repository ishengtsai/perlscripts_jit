#!/usr/bin/perl -w
use strict;


my $PI = `echo $$` ; chomp($PI); 


if (@ARGV != 4) {
    print "$0 Orthogroups.txt.singletonCluster merged.fasta merged.nuc.fasta /home/ijt/bin/pal2nal.v14/pal2nal.pl \n" ;
    print "note! stop codons have been excluded\n" ; 
	exit ;
}

my $file = shift @ARGV;
my $fasta_file1 = shift @ARGV ;
my $fasta_file2 = shift @ARGV ; 
my $pal2nalCommand = shift @ARGV ;

my %seqs  = () ;
my %seqs_nuc = () ; 

open (IN, $fasta_file1) or die "can't open $fasta_file1!\n" ; 
my $species = '' ; 
my $read_name = '' ;
my $read_seq = '' ;
while (<IN>) {
     s/\:/_/gi ;

    if (/^>(.+)\|(.+)/) {
	$read_name = $2 ;
	$read_seq = "" ;
	$species = $1 ;  
	
	while (<IN>) {
	    $read_seq =~ s/\*//g ;
	    s/\:/_/gi ;
	    
	    if (/^>(.+)\|(.+)/) {

                # remove the last peptide!
                #if ( $species eq 'Bregulorum' ) {
		#    $read_seq =~ s/\S$// ; 
		#}
		#if ( $species eq 'Pcarbo' ) {
		#    $read_seq =~ s/\S$// ;
		#}
		
		
		$seqs{$species}{$read_name} = $read_seq ;
		
		
		$read_name = $2 ;
		$species = $1  ;
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
$read_seq =~ s/\*//g ;
$seqs{$species}{$read_name} = $read_seq ;

open (IN, $fasta_file2) or die "can't open $fasta_file2!\n" ;

$species = '' ;
$read_name = '' ;
$read_seq = '' ;
while (<IN>) {
     s/\:/_/gi ;
    
    if (/^>(.+)\|(.+)/) {
	$read_name = $2 ;
	$read_seq = "" ;
	$species = $1 ;

	while (<IN>) {
	    $read_seq =~ s/\*//g ;
	     s/\:/_/gi ;
	    
	    if (/^>(.+)\|(.+)/) {


		$seqs_nuc{$species}{$read_name} = $read_seq ;


		$read_name = $2 ;
		$species = $1  ;
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
$read_seq =~ s/\*//g ;
$seqs_nuc{$species}{$read_name} = $read_seq ;







mkdir "fastas.$PI" or die "ooops\n" ; 
chdir "fastas.$PI" ; 



open (IN, "../$file") or die "oops! erm \n" ;

my $count = 0 ;
my $howmanymissing = 0 ;
my $howmanydifferent = 0 ;

## read in the cufflink annotations
while (<IN>) {

    chomp ; 
#    print "$_\n" ;

    my @r = split /\s+/, $_ ;

    my $group = '' ;


    if ($r[0] =~ /(OG\S+)\:/) {
	$group = $1 ;
    }



    print "doing $group\n" ; 
    my $ismissing = 0 ; 
    my $peptideNotCDS = 0 ; 
    
    # check if it's missing
    for (my $i = 1 ; $i < @r ; $i++ ) {

	#print "$r[$i]\n" ;

	if ( $r[$i] =~ /(^.+)\|(.+)/ ) {

	    #print "$1 $2\n" ;
	    if ( $seqs{$1}{$2} && $seqs_nuc{$1}{$2} ) {
		my $cdsseq = dna2peptide($seqs_nuc{$1}{$2}) ;
		if ( $seqs{$1}{$2} ne $cdsseq ) {
		    $peptideNotCDS = 1 ;
		    print "\t$1 $2 cds and aa seq not the same!\n" ;
		    #print "$seqs{$1}{$2}\n$seqs_nuc{$1}{$2}\n$cdsseq\n" ; 
		}
	    }
	    else {
		print "\t$group\t$1\t$2 NOT FOUND!\n" ; 
		$ismissing = 1 ;
		#last  ; 
	    }
	}
    }

    $howmanymissing++ if $ismissing == 1 ;
    $howmanydifferent++ if $peptideNotCDS == 1 ; 
    
    next if $ismissing == 1 ;
    next if $peptideNotCDS == 1 ; 

    open OUT, ">", "$group.fa" or die "ooops\n" ;
    open OUTNUC, ">", "$group.nuc.fa" or die "daosdpadoaopd\n" ;

    for (my $i = 1 ; $i < @r ; $i++ ) {

        #print "$r[$i]\n" ;

        if ( $r[$i] =~ /(^.+)\|(.+)/ ) {

            #print "$1 $2\n" ;
            if ( $seqs{$1}{$2} && $seqs_nuc{$1}{$2} ) {
		#print "$1\t$2\n" ; 
                print OUT ">$1\n$seqs{$1}{$2}\n" ;
                print OUTNUC ">$1\n$seqs_nuc{$1}{$2}\n" ;
            }

        }
    }
    close(OUT) ;
    close(OUTNUC) ;

    

    #system("mafft $group.fa > $group.aln") ; 

    #system("mafft --maxiterate 1000 --localpair $group.fa > $group.aln") ; 

    system("mafft --quiet --maxiterate 1000  $group.fa > $group.aln") ;
    system("$pal2nalCommand $group.aln $group.nuc.fa -output fasta > $group.nuc.aln") ; 
    

    #system("muscle -in $group.fa -out $group.aln") ;
    #system("muscle -in $group.dna.fa -out $group.dna.aln") ;
 



    $count++ ;
    #last if $count == 10;
}


print "$howmanymissing missing genes!\n" ;
print "$howmanydifferent different genes!\n" ;




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
	return 'X' ; 
            #print STDERR "Bad codon \"$codon\"!!\n";
        #return 0 ;

    }
}
	

