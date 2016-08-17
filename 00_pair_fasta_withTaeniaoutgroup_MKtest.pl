#!/usr/bin/perl -w
use strict;





if (@ARGV != 7) {
	print "$0 all_orthomcl.out emu.fa egu.fa tsm.fa emu.aa.fa egu.aa.fa tsm.aa.fa\n\n" ;
	exit ;
}

my $orthofile = $ARGV[0] ; 

my $filenameA = $ARGV[1];
my $filenameB = $ARGV[2];
my $filenameC = $ARGV[3];


my $filenameD = $ARGV[4];
my $filenameE = $ARGV[5] ; 
my $filenameF = $ARGV[6] ; 


my %Emu = () ; 
my %Egu = () ; 
my %Tsm = () ; 

my %EmuAA = () ; 
my %EguAA = () ; 
my %TsmAA = () ; 


my %Emu_VS_Tsm = () ; 


open OUT_RESULT, ">", "MK_result" or die "ooops can't open merged output!\n" ; 
print OUT_RESULT "gene_name\taln_len\tsame_codon\tgap_codon\tP\tPS\tPN\tP_2base\tP_3base\tD\tDS\tDN\tD_2base\tD_3base\twierd\n" ; 

# Ortho list




# Emu
open (IN, "$filenameA") or die "oops!\n" ;
my $read_name = '' ;
my $read_seq = '' ;

while (<IN>) {
            if (/^>\S+_(\d+)\.1/) {

                $read_name = $1 ;
                $read_seq = "" ;

                while (<IN>) {

                    if (/^>\S+_(\d+)\.1/) {

                        $Emu{$read_name} = $read_seq ;
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
$Emu{$read_name} = $read_seq ;


# Egu
# need to remove \.1 ....
open (IN, "$filenameB") or die "oops!\n" ;
$read_name = '' ;
$read_seq = '' ;

while (<IN>) {
            if (/^>\S+_(\d+)\.1/) {
$read_name = $1 ;
                        $read_seq = "" ;

while (<IN>) {

                    if (/^>\S+_(\d+)\.1/) {

                        $Egu{$read_name} = $read_seq ;
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
$Egu{$read_name} = $read_seq ;


# Tsm
open (IN, "$filenameC") or die "oops!\n" ;
$read_name = '' ;
$read_seq = '' ;

while (<IN>) {
    if (/^>\S+_(\d+)\.1/) {
	$read_name = $1 ;
	$read_seq = "" ;
	
	while (<IN>) {
	    
	    if (/^>\S+_(\d+)\.1/) {

		$Tsm{$read_name} = $read_seq ;
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
$Tsm{$read_name} = $read_seq ;



open (IN, "$filenameD") or die "oops!\n" ;
while (<IN>) {
            if (/^>\S+_(\d+)\.1/) {

                $read_name = $1 ;
                $read_seq = "" ;

                while (<IN>) {

                    if (/^>\S+_(\d+)\.1/) {

                        $EmuAA{$read_name} = $read_seq ;
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
$EmuAA{$read_name} = $read_seq ;

open (IN, "$filenameE") or die "oops!\n" ;
while (<IN>) {
            if (/^>\S+_(\d+)\.1/) {
		
		$read_name = $1 ;
		$read_seq = "" ;
		
		while (<IN>) {
		    
                    if (/^>\S+_(\d+)\.1/) {
			
                        $EguAA{$read_name} = $read_seq ;
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
$EguAA{$read_name} = $read_seq ;


open (IN, "$filenameF") or die "oops!\n" ;
while (<IN>) {
            if (/^>\S+_(\d+)\.1/) {

                $read_name = $1 ;
                $read_seq = "" ;

                while (<IN>) {

                    if (/^>\S+_(\d+)\.1/) {

                        $TsmAA{$read_name} = $read_seq ;
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
$TsmAA{$read_name} = $read_seq ;


open (IN, $orthofile) or die "ooops\n" ; 
while (<IN>) {

    chomp ;
    my @r = split /\s+/, $_ ;

    next unless /TAE/ ; 

    my $tae_count = 0 ; 
    my $tae_gene = '' ; 

    for ( my $i = 3 ; $i < @r ; $i++ ) {
            if ( $r[$i] =~ /TsM_(\S+)\.\d+\((\S+)\)/) {
		    $tae_count++ ; 
		    $tae_gene = $1 ; 

            }
    }

    if ( $tae_count == 1 ) {


	for ( my $i = 3 ; $i < @r ; $i++ ) {
            if ( $r[$i] =~ /EmW_(\S+)\.\d+\((\S+)\)/) {
		    $Emu_VS_Tsm{$1} = $tae_gene ; 
            }
	}
	

    }


}
close(IN) ; 


my $orphan = 0 ;
my $triplet = 0 ;
my %paired_genes = () ;


my $triplet_count = 0 ; 


for my $Emu_gene (sort keys %Emu_VS_Tsm ) {
    my $Tae_gene = $Emu_VS_Tsm{$Emu_gene} ; 

    print "$Emu_gene\t$Tae_gene\n" ; 

    if ( $EguAA{$Emu_gene} && $Egu{$Emu_gene} ) {

	next unless $Emu{$Emu_gene} ;
	next unless $Tsm{$Tae_gene} ; 



	open TMP, ">", "$Emu_gene.aa.fasta" or die "\n" ;
	print TMP ">Emu\n$EmuAA{$Emu_gene}\n>Egu\n$EguAA{$Emu_gene}\n>Tae\n$TsmAA{$Tae_gene}\n";
	close(TMP) ; 

	open TMP, ">", "$Emu_gene.nuc.fasta" or die "\n" ;
	print TMP ">Emu\n$Emu{$Emu_gene}\n>Egu\n$Egu{$Emu_gene}\n>Tae\n$Tsm{$Tae_gene}\n";
	close(TMP) ; 


	system("mafft --maxiterate 1000 --globalpair  $Emu_gene.aa.fasta > tmp.$Emu_gene.aa.aln\; fasta2single.pl tmp.$Emu_gene.aa.aln > $Emu_gene.mafft.aa.aln\; rm tmp.$Emu_gene.aa.aln") ;


	$triplet++ ;

	my $seq_aa1 = '' ;
	my $seq_aa2 = '' ;
	my $seq_aa3 = '' ; 

	my $tmp = '' ;
	my $align1 = '' ;
	my $align2 = '' ;
	my $align3 = '' ; 

	open (IN, "$Emu_gene.mafft.aa.aln") or die "ooops\n" ;
	$tmp = <IN> ; $seq_aa1 = <IN> ; chomp($seq_aa1) ; $tmp = <IN> ; $seq_aa2 = <IN> ;chomp($seq_aa2) ; $tmp =<IN> ; $seq_aa3 = <IN> ; chomp($seq_aa3) ; close(IN) ;

	my $offset = 0 ;
	
	# this bit is to align the nucleotides based on the protein alignment!!!!                                                                                                                                                   
        #       print "$gene\n" ;                                                                                                                                                                                                           
	
	for (my $i = 0 ; $i < length($seq_aa1) ; $i ++ ) {
	    my $aa1 = substr($seq_aa1, $i, 1) ;
	    
	    if ( $aa1 ne '-' ) {
		my $codon = substr( $Emu{$Emu_gene} , 3*($i-$offset), 3 ) ;
		#print "$i\t$codon\n" ;                                                                                                                                                                                             
		$align1 .= $codon ;
	    }
	    else {
		#print "$i\t---\n" ;                                                                                                                                                                                                
		$align1.= '---' ;
		$offset++ ;
	    }
	    
	}
	$offset = 0  ;
	
	for (my $i = 0 ; $i < length($seq_aa2) ; $i ++ ) {
	    my $aa1 = substr($seq_aa2, $i, 1) ;

	    if ( $aa1 ne '-' ) {
		my $codon = substr( $Egu{$Emu_gene} , 3*($i-$offset), 3 ) ;
		#print "$i\t$codon\n" ;                                                                                                                                                                                             
		$align2.= $codon ;
	    }
	    else {
                        #print "$i\t---\n" ;                                                                                                                                                                                                
		$align2.= '---';
		$offset++ ;
	    }

	}
	$offset = 0  ;

        for (my $i = 0 ; $i < length($seq_aa3) ; $i ++ ) {
            my $aa1 = substr($seq_aa3, $i, 1) ;

            if ( $aa1 ne '-' ) {
                my $codon = substr( $Tsm{$Tae_gene} , 3*($i-$offset), 3 ) ;
                #print "$i\t$codon\n" ;                                                                                                                                                                                                     
                $align3.= $codon ;
            }
            else {
		$align3.= '---';
                $offset++ ;
            }

        }


	print "$align1\n$align2\n$align3\n" ;


	my $seq_len = length($align1) ;
	
	open OUT_SEQ, ">", "$Emu_gene.final.aln" or die "ooops\n" ; 
	print OUT_SEQ ">$Emu_gene\n$align1\n>$Emu_gene\n$align2\n>$Tae_gene\n$align3\n" ; 






	#generate input sequence file                                                                                                                                                                                               
	my $result = `/nfs/users/nfs_j/jit/repository/pathogen/user/jit/2genome_comaparison/MKtest.pl $Emu_gene.final.aln` ; 
	print OUT_RESULT "$result" ; 

	


	$triplet_count++ ; 
	#last if $triplet_count == 10 ; 

    }

}

system("rm *.mafft.aa.aln *.nuc.fasta *.aa.fasta") ; 




exit ; 



my $pair = 0 ; 


# start sorting out files
# and run paml
for my $gene (sort keys %EmuAA) {
    

	
	if ( $EguAA{$gene} && $Egu{$gene} ) {

	    next unless $Emu{$gene} ; 


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
	
			system('/nfs/users/nfs_j/jit/bin/paml4.5/bin/codeml');	
			
			
			
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
	
		system('/nfs/users/nfs_j/jit/bin/paml4.5/bin/codeml');

	
			# parse the likelihood, ML dn/ds ,and nei-gojobori out
			open(IN, "tmp.results.H0.txt") || die print "blah" ;
			print OUT_RESULT "EmW_$gene\t" ;
	
			while(<IN>) {

				#Nei-gojobori
				if (/Emu\s+(\S+)\s+\((\S+)\s+(\S+)\)/) {print OUT_RESULT "$1\t$2\t$3\t" ;}	
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
		
		$paired_genes{$gene}++ ; 
	}	
	else {
		#print "$gene orphan!\n" ; 	
		$orphan++ ;
		next ; 
	}



	system("rm $gene.*") ; 
	#last if $pair == 5 ; 
	#last ; 
}

print "$pair paired genes and $orphan orphan genes\n" ; 



	system("rm *.mafft.aln") ; 
	system("rm 2*") ; 
	system("rm tmp.*") ; 


