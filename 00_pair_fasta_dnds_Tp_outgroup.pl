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


print OUT_RESULT "gene\taln_len\tTw_gap\tTd_gap\tTf_gap\tTp_gap\tlnL_H0\tall_w\tlnL_H1\tTw_Td_w\tTf_w\tTp_w\tlnL_H2\tTp_w\tTf_w\tTw_w\tTd_w\n" ;


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
    #next unless /SPOM/ ; 
    next unless /TAF/ ; 
    next unless /TAP/ ; 

    my $td_count = 0 ;
    my $tw_count = 0 ; 
    my $tp_count = 0 ; 
    my $tf_count = 0 ; 
    #my $sp_count = 0 ; 


    my $td_gene = '' ;
    my $tp_gene = '' ; 
    my $tf_gene = '' ;
    my $tw_gene = '' ;
    #my $sp_gene = '' ;



    for ( my $i = 1 ; $i < @r ; $i++ ) {
	if ( $r[$i] =~ /TAW\|(\S+)/ ) {
	    $tw_count++ ;
	    $tw_gene = $1 ;
	}
	if ( $r[$i] =~ /TAD\|(\S+)/ ) {
            $td_count++ ;
            $td_gene = $1 ;
        }
        if ( $r[$i] =~ /TAP\|(\S+)/ ) {
            $tp_count++ ;
            $tp_gene = $1 ;
        }
        if ( $r[$i] =~ /TAF\|(\S+)/ ) {
            $tf_count++ ;
            $tf_gene = $1 ;
        }
        #if ( $r[$i] =~ /SPOM\|(\S+)/ ) {
        #    $sp_count++ ;
        #    $sp_gene = $1 ;
        #}

    }

    if ( $td_count == 1 && $tw_count == 1 ) {
	if ( $tf_count == 1 && $tp_count == 1 ) {
	    #if ( $sp_count == 1 ) {
		$pairgenes{$tw_gene} = "$td_gene\t$tf_gene\t$tp_gene" ;  ; 
	    #}
	}

    }


}
close(IN) ;








my $pair = 0 ; 

# start sorting out files
# and run paml
for my $gene (sort keys %pairgenes ) {


    print "$gene and $pairgenes{ $gene }\n" ; 

    my @othergenes = split /\s+/,  $pairgenes{ $gene } ; 
    my $td_gene = $othergenes[0] ;
    my $tp_gene = $othergenes[2] ; 
    my $tf_gene = $othergenes[1] ; 
    my $tw_gene = $gene ;
    #my $sp_gene = $othergenes[3] ;



  
	
#	if ( $AA{$gene} && $AA{$correspondgene} ) {

	    #next unless $transcripts{$gene} ; 
	    

	    

    $pair++ ; 		
		
		open TMP, ">", "$gene.aa.fasta" or die "\n" ; 

    # START MODIFYING HERE!!!

		print TMP ">Tw\n$AA{$tw_gene}\n>Td\n$AA{$td_gene}\n>Tf\n$AA{$tf_gene}\n>Tp\n$AA{$tp_gene}\n"; 
		close(TMP) ; 

                #open TMP, ">", "$gene.nuc.fasta" or die "\n" ;
		#print TMP ">Tw\n$transcripts{$gene}\n>Td\n$transcripts{$correspondgene}\n";
                #close(TMP) ;
		
		#system("./translatorx_vLocal.pl -i $gene.fasta -p F") ; 
		#system("mv translatorx_res.nt_ali.fasta $gene.transX.aln \; rm translatorx_res*") ; 
		system("mafft --maxiterate 1000 --globalpair  $gene.aa.fasta > tmp.$gene.aa.aln\; fasta2single.pl tmp.$gene.aa.aln > $gene.mafft.aa.aln\; rm tmp.$gene.aa.aln") ; 
		
		my $seq_aa1 = '' ; 
		my $seq_aa2 = '' ; 
                my $seq_aa3 = '' ; 
                my $seq_aa4 = '' ; 

		my $tmp = '' ; 
                my $align1 = '' ;
                my $align2 = '' ;
                my $align3 = '' ; 
                my $align4 = '' ; 


	    open (IN, "$gene.mafft.aa.aln") or die "ooops\n" ;
	    #seq1 is Tw
	    #seq2 is Td
            #seq3 is Tf
            #seq4 is Tp
	    $tmp = <IN> ; $seq_aa1 = <IN> ; chomp($seq_aa1) ; $tmp = <IN> ; $seq_aa2 = <IN> ;chomp($seq_aa2) ; 
    $tmp = <IN> ; $seq_aa3 = <IN> ; chomp($seq_aa3) ; $tmp = <IN> ; $seq_aa4 = <IN> ;chomp($seq_aa4) ;
    

            close(IN) ; 

	    my $offset = 0 ; 

	    my $Tw_offset = 0 ; 
	    my $Td_offset = 0 ; 
            my $Tp_offset = 0 ;
            my $Tf_offset = 0 ;   

	    # this bit is to align the nucleotides based on the protein alignment!!!!
	    #	print "$gene\n" ; 
	    
	    #Tw
	    for (my $i = 0 ; $i < length($seq_aa1) ; $i ++ ) {
		my $aa1 = substr($seq_aa1, $i, 1) ; 
		
		if ( $aa1 ne '-' ) {
		    my $codon = substr( $transcripts{$tw_gene} , 3*($i-$offset), 3 ) ;
		    #print "$i\t$codon\n" ; 
		    $align1 .= $codon ; 
		}
		else {
		    #print "$i\t---\n" ; 
		    $align1.= '---' ; 
		    $offset++ ; 
		}
		
	    }
	    $Tw_offset = $offset ; 
	    

	    #Td
	    $offset = 0  ;	    
	    for (my $i = 0 ; $i < length($seq_aa2) ; $i ++ ) {
		my $aa1 = substr($seq_aa2, $i, 1) ;
		
		if ( $aa1 ne '-' ) {
		    my $codon = substr( $transcripts{$td_gene} , 3*($i-$offset), 3 ) ;
		    #print "$i\t$codon\n" ;
			$align2.= $codon ;
		}
		else {
		    #print "$i\t---\n" ;
		    $align2.= '---';
		    $offset++ ;
		}
		
	    }	    
	    $Td_offset = $offset ; 

    #Tf
    $offset = 0  ;
    for (my $i = 0 ; $i < length($seq_aa3) ; $i ++ ) {
	my $aa1 = substr($seq_aa3, $i, 1) ;
	
	if ( $aa1 ne '-' ) {
	    my $codon = substr( $transcripts{$tf_gene} , 3*($i-$offset), 3 ) ;
	    #print "$i\t$codon\n" ;
	    $align3.= $codon ;
	}
	else {
	    #print "$i\t---\n" ;
	    $align3.= '---';
	    $offset++ ;
	}

    }
    $Tf_offset = $offset ;
    
    
    #Tp
    $offset = 0  ;
    for (my $i = 0 ; $i < length($seq_aa4) ; $i ++ ) {
        my $aa1 = substr($seq_aa4, $i, 1) ;
	
	if ( $aa1 ne '-' ) {
            my $codon = substr( $transcripts{$tp_gene} , 3*($i-$offset), 3 ) ;
            #print "$i\t$codon\n" ;
            $align4.= $codon ;
        }
        else {
            #print "$i\t---\n" ;
            $align4.= '---';
            $offset++ ;
        }
	
    }
    $Tp_offset = $offset ;


	    # replace with small ex
	    for ( my $i = 0 ; $i < length($align1) ; $i += 3 ) {
		my $codon = substr( $align1 , $i, 3 ) ; 
		my $codon2 = substr( $align2 , $i, 3 ) ;
		my $codon3 = substr( $align3 , $i, 3 ) ;
		my $codon4 = substr( $align4 , $i, 3 ) ;
		my $isSTOP = 0 ; 

		my $aa1 = codon2aa($codon) ; 
		my $aa2 = codon2aa($codon2) ; 
		my $aa3 = codon2aa($codon3) ; 
		my $aa4 = codon2aa($codon4) ; 


		$isSTOP = 1  if $aa1 eq '_' || $aa1 eq 'X' ; 
		$isSTOP = 1  if $aa2 eq '_' || $aa2 eq 'X' ;
		$isSTOP = 1  if $aa3 eq '_' || $aa3 eq 'X' ;
		$isSTOP = 1  if $aa4 eq '_' || $aa4 eq 'X' ;
		
		# replace 
		substr( $align1 , $i, 3 , '???') if $isSTOP == 1 ;
		substr( $align2 , $i, 3 , '???')  if $isSTOP == 1 ;
		substr( $align3 , $i, 3 , '???')  if $isSTOP == 1 ;
		substr( $align4 , $i, 3 , '???')  if $isSTOP == 1 ;
	    }

	    
	    


    #	print "$align1\n$align2\n" ; 
    
    
    my $seq_len = length($align1) ; 
    my %paml_seqs = () ;  
    $paml_seqs{'Tw'} = $align1 ;
    $paml_seqs{'Td'} = $align2 ;
    $paml_seqs{'Tf'} = $align3 ;
    $paml_seqs{'Tp'} = $align4 ;
    
    
    #generate input sequence file
    open OUT, ">seqfile.txt" || die print "can not create file, please check with your admin" ;
    open OUTCHECK, ">$gene.aligned.transcript.fa" || die "adsiasdoiado\n" ; 
    print OUT "" .(scalar keys %paml_seqs). "\t$seq_len\n" ;
    for my $species (sort keys %paml_seqs) {
	print OUT "$species\n$paml_seqs{$species}\n" ; 	
	print OUTCHECK ">$species\n$paml_seqs{$species}\n" ;
    }
    close(OUT);
    
    #construct ctl file for paml (one omega for whole tree)
    open OUT, ">codeml.ctl" || die print "can not create file, please check with your admin" ;
    print OUT '

                        seqfile = seqfile.txt   * sequence data filename';
    print OUT "\n\toutfile = $tw_gene.results.H0.txt\n" ;
    print OUT "\n\ttreefile = tree.H0.txt\n" ;
    print OUT '

                    noisy = 3        * 0,1,2,3,9: how much rubbish on the screen
                    verbose = 0      * 1:detailed output
                    runmode = 0     * 0:user defined tree

                    seqtype = 1      * 1:codons
                    CodonFreq = 3    * 0:equal, 1:F1X4, 2:F3X4, 3:F61

                    model = 0      * 0:one omega ratio for all branches
                                   * 1:separate omega for each branch
                                   * 2:user specified dN/dS ratios for branches

                    NSsites = 0    *

                    icode = 0      * 0:universal code

                    fix_kappa = 0  * 1:kappa fixed, 0:kappa to be estimated
                        kappa = 2  * initial or fixed kappa

                        fix_omega = 0
                                omega = 0.2
                        ';
    
    close(OUT);        
    system('codeml');	
    
        #construct ctl file for paml (one omega for whole tree)
    open OUT, ">codeml.ctl" || die print "can not create file, please check with your admin" ;
        print OUT '

                        seqfile = seqfile.txt   * sequence data filename';
    print OUT "\n\toutfile = $tw_gene.results.H2.txt\n" ;
    print OUT "\n\ttreefile = tree.H0.txt\n" ;
        print OUT '

                    noisy = 3        * 0,1,2,3,9: how much rubbish on the screen
                    verbose = 0      * 1:detailed output
                    runmode = 0     * 0:user defined tree

                    seqtype = 1      * 1:codons
                    CodonFreq = 3    * 0:equal, 1:F1X4, 2:F3X4, 3:F61

                    model = 1      * 0:one omega ratio for all branches
                                   * 1:separate omega for each branch
                                   * 2:user specified dN/dS ratios for branches

                    NSsites = 0    *

                    icode = 0      * 0:universal code

                    fix_kappa = 0  * 1:kappa fixed, 0:kappa to be estimated
                        kappa = 2  * initial or fixed kappa

                        fix_omega = 0
                                omega = 0.2
                        ';

    close(OUT);

    system('codeml');


    #construct ctl file for paml (Eu != Fe = cario)
    open OUT, ">codeml.ctl" || die print "can not create file, please check with your admin" ;
        print OUT '

                        seqfile = seqfile.txt   * sequence data filename';
    print OUT "\n\toutfile = $tw_gene.results.H1.txt\n" ;
    print OUT "\n\ttreefile = tree.H1.txt\n" ;
        print OUT '

                    noisy = 3        * 0,1,2,3,9: how much rubbish on the screen
                    verbose = 0      * 1:detailed output
                    runmode = 0     * 0:user defined tree

                    seqtype = 1      * 1:codons
                    CodonFreq = 3    * 0:equal, 1:F1X4, 2:F3X4, 3:F61

                    model = 2      * 0:one omega ratio for all branches
                                   * 1:separate omega for each branch
                                   * 2:user specified dN/dS ratios for branches

                    NSsites = 0    *

                    icode = 0      * 0:universal code

                    fix_kappa = 0  * 1:kappa fixed, 0:kappa to be estimated
                        kappa = 2  * initial or fixed kappa

                        fix_omega = 0
                                omega = 0.2
                        ';

    close(OUT);

    system('codeml');


    print OUT_RESULT "$tw_gene\t" . length($align1) .  "\t$Tw_offset\t$Td_offset\t$Tf_offset\t$Tp_offset\t" ;


    open(IN, "$tw_gene.results.H0.txt") || die print "blah" ;
    while(<IN>) {
                if (/lnL.+-(\S+)/) {  print OUT_RESULT "-$1\t";}
                if (/\(dN\/dS\).+=\s+(\S+)/) {print OUT_RESULT "$1\t" ; last ;}
    }
    close(IN);


    open(IN, "$tw_gene.results.H1.txt") || die print "blah" ;
    while(<IN>) {
	
	if (/lnL.+-(\S+)/) {  print OUT_RESULT "-$1\t";}
	if (/\(dN\/dS\).+:\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)/) {print OUT_RESULT "$2\t$3\t$4\t" ; last ;}
    }
    close(IN);
    
    open(IN, "$tw_gene.results.H2.txt") || die print "blah" ;
    while(<IN>) {
	if (/lnL.+-(\S+)/) {  print OUT_RESULT "-$1\t";}
	if (/\(dN\/dS\).+:\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)/) {print OUT_RESULT "$4\t$3\t$1\t$2\t" ; last ;}
    }
    close(IN);
    
    
    
    print OUT_RESULT "\n" ;
    
       

    system("rm $gene.*") ; 
	#last if $pair == 5 ; 
	#last ; 
}

print "all done! A total of $pair clustered genes \n" ; 



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
