#!/usr/bin/perl -w
use strict;





if (@ARGV != 3) {
	print "$0 merged.transcript.fa merged.aa.fa groups.txt\n\n" ;
	exit ;
}

my $filenameA = $ARGV[0];
my $filenameB = $ARGV[1];
my $filenameC = $ARGV[2];


my %transcripts = () ; 
my %AA = () ; 


open OUT_RESULT, ">", "paml_result" or die "ooops can't open merged output!\n" ; 
print OUT_RESULT "gene\taln_len\tTw_gap\tTd_gap\tdN/dS\tdN\tdS\tH0(w=1):lnL\tH1(w!=1):lnL\n" ;

# transcripts
open (IN, "$filenameA") or die "oops!\n" ;
my $read_name = '' ;
my $read_seq = '' ;

while (<IN>) {
            if (/^>(\S+)/) {

                $read_name = $1 ;
                $read_seq = "" ;

                while (<IN>) {

                    if (/^>(\S+)/) {
			
                        $transcripts{$read_name} = $read_seq ;
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
$transcripts{$read_name} = $read_seq ;


# aa sequences
open (IN, "$filenameB") or die "oops!\n" ;
$read_name = '' ;
$read_seq = '' ;

while (<IN>) {
            if (/^>(\S+)/) {
		$read_name = $1 ;
		$read_seq = "" ;
		
		while (<IN>) {
		    
                    if (/^>(\S+)/) {
			
                        $AA{$read_name} = $read_seq ;
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
$AA{$read_name} = $read_seq ;


my %pairgenes = () ; 

open (IN, "$filenameC") or die "oops!\n" ;
while (<IN>) {

    chomp ;
    my @r = split /\s+/, $_ ;

    next unless /TAW/ ;
    next unless /TAD/ ;

    my $td_count = 0 ;
    my $tw_count = 0 ; 

    my $td_gene = '' ;
    my $tw_gene = '' ; 

    for ( my $i = 1 ; $i < @r ; $i++ ) {
	if ( $r[$i] =~ /TAW\|(\S+)/ ) {
	    $tw_count++ ;
	    $tw_gene = $1 ;
	}
	if ( $r[$i] =~ /TAD\|(\S+)/ ) {
            $td_count++ ;
            $td_gene = $1 ;
        }
    }

    if ( $td_count == 1 && $tw_count == 1 ) {
	#print "pair: $tw_gene and $td_gene\n" ; 
	    $pairgenes{$tw_gene} = $td_gene ; 
    }


}
close(IN) ;








my $pair = 0 ; 

# start sorting out files
# and run paml
for my $gene (sort keys %pairgenes ) {


    print "$gene and $pairgenes{ $gene }\n" ; 
    my $correspondgene = $pairgenes{ $gene } ; 

  
	
	if ( $AA{$gene} && $AA{$correspondgene} ) {

	    #next unless $transcripts{$gene} ; 
	    

	    
	    print "$gene found in both!\n" ; 	
		$pair++ ; 		
		
		open TMP, ">", "$gene.aa.fasta" or die "\n" ; 
		print TMP ">Tw\n$AA{$gene}\n>Td\n$AA{$correspondgene}\n"; 
		close(TMP) ; 

                #open TMP, ">", "$gene.nuc.fasta" or die "\n" ;
		#print TMP ">Tw\n$transcripts{$gene}\n>Td\n$transcripts{$correspondgene}\n";
                #close(TMP) ;
		
		#system("./translatorx_vLocal.pl -i $gene.fasta -p F") ; 
		#system("mv translatorx_res.nt_ali.fasta $gene.transX.aln \; rm translatorx_res*") ; 
		system("mafft --maxiterate 1000 --globalpair  $gene.aa.fasta > tmp.$gene.aa.aln\; fasta2single.pl tmp.$gene.aa.aln > $gene.mafft.aa.aln\; rm tmp.$gene.aa.aln") ; 
		
		my $seq_aa1 = '' ; 
		my $seq_aa2 = '' ; 
		my $tmp = '' ; 
                my $align1 = '' ;
                my $align2 = '' ;


	    open (IN, "$gene.mafft.aa.aln") or die "ooops\n" ;
	    #seq1 is Tw
	    #seq2 is Td
	    $tmp = <IN> ; $seq_aa1 = <IN> ; chomp($seq_aa1) ; $tmp = <IN> ; $seq_aa2 = <IN> ;chomp($seq_aa2) ; close(IN) ; 

	    my $offset = 0 ; 
	    my $Emu_offset = 0 ; 
	    my $Egu_offset = 0 ; 
	    
	    # this bit is to align the nucleotides based on the protein alignment!!!!
	    #	print "$gene\n" ; 
	    
	    #Tw
	    for (my $i = 0 ; $i < length($seq_aa1) ; $i ++ ) {
		my $aa1 = substr($seq_aa1, $i, 1) ; 
		
		if ( $aa1 ne '-' ) {
		    my $codon = substr( $transcripts{$gene} , 3*($i-$offset), 3 ) ;
		    #print "$i\t$codon\n" ; 
		    $align1 .= $codon ; 
		}
		else {
		    #print "$i\t---\n" ; 
		    $align1.= '---' ; 
		    $offset++ ; 
		}
		
	    }
	    $Emu_offset = $offset ; 
	    

	    #Td
	    $offset = 0  ;	    
	    for (my $i = 0 ; $i < length($seq_aa2) ; $i ++ ) {
		my $aa1 = substr($seq_aa2, $i, 1) ;
		
		if ( $aa1 ne '-' ) {
		    my $codon = substr( $transcripts{$correspondgene} , 3*($i-$offset), 3 ) ;
		    #print "$i\t$codon\n" ;
			$align2.= $codon ;
		}
		else {
		    #print "$i\t---\n" ;
		    $align2.= '---';
		    $offset++ ;
		}
		
	    }	    
	    $Egu_offset = $offset ; 

	    # replace with small ex
	    for ( my $i = 0 ; $i < length($align1) ; $i += 3 ) {
		my $codon = substr( $align1 , $i, 3 ) ; 
		my $codon2 = substr( $align2 , $i, 3 ) ;
		my $isSTOP = 0 ; 

		my $aa1 = codon2aa($codon) ; 
		my $aa2 = codon2aa($codon2) ; 

		$isSTOP = 1  if $aa1 eq '_' || $aa1 eq 'X' ; 
		$isSTOP = 1  if $aa2 eq '_' || $aa2 eq 'X' ;

		# replace 
		substr( $align1 , $i, 3 , '???') if $isSTOP == 1 ;
		substr( $align2 , $i, 3 , '???')  if $isSTOP == 1 ;
	    }

	    
	    


	#	print "$align1\n$align2\n" ; 


		my $seq_len = length($align1) ; 
		my %paml_seqs = () ;  
		$paml_seqs{'Tw'} = $align1 ;
		$paml_seqs{'Td'} = $align2 ;

	
     
		#generate input sequence file
		open OUT, ">seqfile.txt" || die print "can not create file, please check with your admin" ;
	    open OUTCHECK, ">$gene.aligned.transcript.fa" || die "adsiasdoiado\n" ; 
		print OUT "" .(scalar keys %paml_seqs). "\t$seq_len\n" ;
		for my $species (sort keys %paml_seqs) {
		    print OUT "$species\n$paml_seqs{$species}\n" ; 	
		    print OUTCHECK ">$species\n$paml_seqs{$species}\n" ;
		}
		close(OUT);
		
		
		#construct ctl file for paml (fixed omega)
		open OUT, ">codeml.ctl" || die print "can not create file, please check with your admin" ;
		print OUT '
					
			seqfile = seqfile.txt   * sequence data filename';
		print OUT "\n\toutfile = tmp.results.H0.txt\n" ;
					print OUT '

		    noisy = 0        * 0,1,2,3,9: how much rubbish on the screen
		    verbose = 0      * 1:detailed output
		    runmode = -2     * 0:user defined tree

		    seqtype = 1      * 1:codons
		    CodonFreq = 3    * 0:equal, 1:F1X4, 2:F3X4, 3:F61

		    model = 0      * 0:one omega ratio for all branches
		                   * 1:separate omega for each branch
		                   * 2:user specified dN/dS ratios for branches

		    NSsites = 0    * 

		    icode = 0      * 0:universal code
		    fix_kappa = 0  * 1:kappa fixed, 0:kappa to be estimated
		        kappa = 2  * initial or fixed kappa
			';
			print OUT "\n\tfix_omega = 1\n\tomega = 1\n";
			close(OUT);
	
			system('codeml');	
			
			
			
			#construct ctl file for paml (fixed omega)
			open OUT, ">codeml.ctl" || die print "can not create file, please check with your admin" ;
			print OUT '
					
			seqfile = seqfile.txt   * sequence data filename';
			print OUT "\n\toutfile = tmp.results.H1.txt\n" ;
			print OUT '

       	            noisy = 0        * 0,1,2,3,9: how much rubbish on the screen
		    verbose = 0      * 1:detailed output
		    runmode = -2     * 0:user defined tree

		    seqtype = 1      * 1:codons
		    CodonFreq = 3    * 0:equal, 1:F1X4, 2:F3X4, 3:F61

		    model = 0      * 0:one omega ratio for all branches
		                   * 1:separate omega for each branch
		                   * 2:user specified dN/dS ratios for branches

		    NSsites = 0    * 

		    icode = 0      * 0:universal code

		    fix_kappa = 0  * 1:kappa fixed, 0:kappa to be estimated
		        kappa = 2  * initial or fixed kappa
			';
			print OUT "\n\tfix_omega = 0\n\tomega = 1\n";
			close(OUT);
	
		system('codeml');

	
			# parse the likelihood, ML dn/ds ,and nei-gojobori out
			open(IN, "tmp.results.H0.txt") || die print "blah" ;
			print OUT_RESULT "$gene\t" . length($align1) . "\t" . ($Emu_offset * 3) . "\t" . ($Egu_offset * 3) . "\t" ;
	
			while(<IN>) {

				#Nei-gojobori
				if (/Tw\s+(\S+)\s+\((\S+)\s+(\S+)\)/) {print OUT_RESULT "$1\t$2\t$3\t" ;}	
				#ML
				if (/lnL =\s?(\S+)/) {  print OUT_RESULT "$1\t";}
				if (/dN\/dS=\s?(\S+)\s+dN= (\S+)\s+dS= (\S+)/) {print OUT_RESULT "$1\t$2\t$3\t" ; last ;}
			}
			close(IN);

			open(IN, "tmp.results.H1.txt") || die print "blah" ;
			while(<IN>) {
			    

				if (/lnL =\s?(\S+)/) {  print OUT_RESULT "$1\t";}
				if (/dN\/dS=\s?(\S+)\s+dN= (\S+)\s+dS= (\S+)/) {print OUT_RESULT "$1\t$2\t$3" ; last ;}

			}
			close(IN);
			print OUT_RESULT "\n" ; 
		


	    #last ; 
	}	
	else {

	    #print "erm! $gene not found\n" ; 

	}



	system("rm $gene.*") ; 
	#last if $pair == 5 ; 
	#last ; 
}

print "$pair paired genes \n" ; 



	#system("rm *.mafft.aln") ; 
	#system("rm 2*") ; 
	#system("rm tmp.*") ; 



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

#        print STDERR "Bad codon \"$codon\"!!\n";
        return 'X' ;
        #exit ;
    }
}
