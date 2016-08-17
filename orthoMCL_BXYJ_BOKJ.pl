#!/usr/bin/perl -w
use strict;



if (@ARGV != 8) {
	print "$0 contiglen assigned.group assigned.group2 groups.txt gene_location Species1 Species2 minscafflen \n\n" ;
	print "create partitioned list\n" ; 

	exit ;
}


my $contiglenfile = shift @ARGV ;
my $assignedFile1 = shift @ARGV ; 
my $assignedFile2 = shift @ARGV ;

my $file = shift @ARGV;
my $location_file = shift @ARGV ;

my $spe1 =  shift @ARGV ;
my $spe2 = shift @ARGV ; 

my $minscafflen = shift @ARGV ; 


my %location = () ; 
my %scaffold = () ; 

my %assigned_scaffold = () ; 
my %scaffold_gene_count = () ; 
my %contig_len = () ; 

my @celscaffolds = () ; 
my @qryscaffolds = () ; 

open (IN, "$contiglenfile") or die "daoidoadoiad\n" ; 
while (<IN>) {
    if ( /(\S+)\s+(\S+)/ ) {
        #print "$1\t$2\n" ;
        $contig_len{$1} = $2 ;
	chomp; 
    }

}
close(IN) ; 

open (IN, "$assignedFile1") or die "dadiaodiaois\n" ; 
while (<IN>) {

    chomp; 
    my @r = split /\s+/, $_ ;
    if ( $contig_len{$r[0]} >= $minscafflen ) {
	push ( @celscaffolds, $r[0] ) ;
    }

}
close(IN) ;

open (IN, "$assignedFile2") or die "dadiaodiaois\n" ;
while (<IN>) {

    chomp;
    my @r = split /\s+/, $_ ;
    if ( $contig_len{$r[0]} >= $minscafflen ) {
        push ( @qryscaffolds, $r[0] ) ;
    }

}
close(IN) ;


open (IN, "$location_file") or die "oops!\n" ;
while (<IN>) {
    chomp ; 
    if ( /(\S+)\t(\S+)\t(\S+)/ ) {
	$location{$1} = "$2\t$3" ;
	$scaffold{$1} = "$2" ; 
	$scaffold_gene_count{$2}++ ; 
    }

}
close(IN) ; 

my %fasta = () ; 

open (IN, "$spe1.fa") or die "can't open $spe1.fa !\n" ; 
while (<IN>) {
    if (/>(\S+)/ ) {
	my $name = $1 ; 
	my $seq = <IN> ; 
	chomp($seq) ; 

	$seq =~ s/U//gi ; 

	$fasta{$name} = $seq ; 

    }
}
close(IN) ; 


open (IN, "$spe2.fa") or die "can't open $spe2.fa !\n" ;
while (<IN>) {
    if (/>(\S+)/ ) {
        my $name = $1 ;
        my $seq = <IN> ;
	chomp($seq) ;

	$seq =~s/U//gi;

        $fasta{$name} = $seq ;

    }
}
close(IN) ;







open (IN, "$file") or die "oops!\n" ;

open OUT, ">", "$file.$spe1.$spe2.locationcomparison" or die "can't open files erm!!!!!!\n" ; 
open OUT3 , ">", "$file.$spe1.$spe2.locationcomparison.spe1-1.spe2-2" or die "can't open file!\n" ; 
open OUT2, ">", "$file.$spe1.$spe2.locationcomparison.multiple" or die "oooooops\n" ; 
open OUT_ERR, ">", "$file.$spe1.$spe2.locationcomparison.err" or die "can't open file for input!\n" ; 

open OUT4, ">", "$file.$spe1.$spe2.locationcomparison.perscaffTable.forheatmap" or die "ooooca can't create file!\n" ; 

my $count = 0 ;
my %cluster_size = () ;

my %shared_gene = () ;
my %shared_gene_in_scaffold = () ; 
my $gene_pairs = 0 ; 


my %shared_gene_but_not_one_one = () ; 
my %not_found_in_both = () ; 


my %genes_in_cel_chrom = () ; 



while (<IN>) {

    chomp ; 
    #print "$_\n" ;

    my @r = split /\s+/, $_ ;

    my $group = '' ;

    if ($r[0] =~ /(ORTHOMCL\S+):/) {
	$group = $1 ;
    }




    #print "$r[0]\t$r[1]\n" ;

    my %gene_count = () ; 
    my %genes = () ; 

    for (my $i = 1; $i < @r ; $i++) {

	if ( $r[$i] =~ /(\S+)\|(\S+)/ ) {
	
	    

	    if ( $gene_count{$1}  ) {
		$genes{$1} .= "\t$2"  ; 
	    }
	    else {
		$genes{$1} = "$2"  ;
	    }
	    #print "$1\t$2\n" ; 

	    $gene_count{$1}++ ;

	}       
    }
    
    

    #last; 

    if ( $gene_count{$spe1} && $gene_count{$spe2} ) {
	#print "$gene_count{$spe1}\t$gene_count{$spe2}\t$genes{$spe1}\t.\t$genes{$spe2}\n" ; 
    }
    
    if ( $gene_count{$spe1} && $gene_count{$spe2} ) {

	if ( $gene_count{$spe1} == 1 && $gene_count{$spe2} == 1) {
	    
	    my $gene1 = $genes{$spe1} ; 
	    my $gene2 = $genes{$spe2} ; 


	    if ( $location{$gene1} && $location{$gene2}) {
		print OUT "$gene1\t$location{$gene1}\t$gene2\t$location{$gene2}\t" ; 
		
		my $location1 = $scaffold{$gene1} ; 
		my $location2 = $scaffold{$gene2} ; 
		$genes_in_cel_chrom{$location1}{ $location2    }++ ; 
		$genes_in_cel_chrom{$location2}{ $location1    }++ ;


		$gene_pairs++ ; 

		$shared_gene{$gene1}++ ; 
		$shared_gene{$gene2}++ ;

		$shared_gene_in_scaffold{ $scaffold{$gene1} }++ ; 
		$shared_gene_in_scaffold{ $scaffold{$gene2} }++;
		
		if ( $fasta{$gene1} && $fasta{$gene2} ) {

		    # actually skip all the alignment part
		    print OUT "\tNA\n" ; 
		    next ; 
		    

		    open TMP, ">", "tmp.fa" or die "ooops!\n" ; 
		    print TMP ">$gene1\n$fasta{$gene1}\n" ; 
		    print TMP ">$gene2\n$fasta{$gene2}\n" ;
		    close(TMP) ; 
		    
		    # alignment
		    system("mafft --maxiterate 1000 --localpair tmp.fa > tmp.aln") ; 
		    system("fasta2singleLine_IMAGE.pl tmp.aln tmp.SL.aln") ; 

		    open (ALN, "tmp.SL.aln") or die "ooops!\n" ; 
		    my $tmp = <ALN> ; 
		    my $aln1 = <ALN> ; 
		    chomp($aln1) ; 
		    $tmp = <ALN> ;
		    my $aln2= <ALN> ;
                    chomp($aln2) ;
		    close(ALN) ; 

		    my $same = 0 ; 
		    my $bothnucleotide = 0 ; 
		    for (my $i = 0 ; $i < length($aln1) ; $i++ ) {
			my $base1 = substr($aln1, $i, 1) ; 
			my $base2 = substr($aln2, $i, 1) ; 

			if ( $base1 eq '-'  || $base2  eq '-' ) {
			    next ; 
			}


			$same++ if $base1 eq $base2 ; 		       
			$bothnucleotide++ ; 


		    }
		    
		    my $similarity = sprintf ("%.3f", $same / $bothnucleotide ) ; 
		    my $similarity_gap = sprintf ("%.3f", $same /length($aln1) ) ;

		    print OUT "" . (length($fasta{$gene1}) ). "\t". (length($fasta{$gene2}) )  . "\t$same\t$bothnucleotide\t" . (length($aln1)) . "\t$similarity\t$similarity_gap\n" ; 

		    #print "$aln1\n$aln2\n" ; 
		    #exit ; 
		}
		else {
		    print "$gene1 or $gene2 missing!\n" ; 

		    print OUT "\tNA\tNA\tNA\tNA\tNA\tNA\tNA\n" ; 
	#	    exit ; 
		}




	    }
	    else {

		unless ( $location{$gene1} ) {
		    print OUT_ERR "$gene1 wierd!!!\n" ; 
		}

		unless ( $location{$gene2} ) {
                    print OUT_ERR "$gene2 wierd!!!\n" ;
		}

	    }


	}
	elsif ( $gene_count{$spe1} == 1 && $gene_count{$spe2} == 2) {


            my $gene1 = $genes{$spe1} ;	  
            my @gene2 = split (/\t/, $genes{$spe2} ) ;

	#    print "pair @gene2\n" ; 

            if ( $location{$gene1} ) {
		if ( $location{$gene2[0]} && $location{$gene2[1] }) {

		    print OUT3 "$gene1\t$location{$gene1}\t$gene2[0]\t$location{$gene2[0]}\t$gene2[1]\t$location{$gene2[1]}\n" ;
		    $gene_pairs++ ;
		    
		    #$shared_gene{$gene1}++ ;
		    #$shared_gene{$gene2}++ ;
		    
		    #$shared_gene_in_scaffold{ $scaffold{$gene1} }++ ;
		    #$shared_gene_in_scaffold{ $scaffold{$gene2} }++;
		    
		}
            }






	}
	else {
	    #print "here!\n" ; 

	    for (my $i = 1; $i < @r ; $i++) {
		#print "$r[$i]\n" ; 

		if ( $r[$i] =~ /(\S+)\|(\S+)/ ) {
		    my $gene = $2 ; 
		    my $species = $1 ; 

		    if ( $species eq $spe1 || $species eq $spe2 ) {
			my $loc = $scaffold{$gene} ;
			#print "$spe1\n" ; 
			if ( $scaffold{$gene} ) {
			    $shared_gene_but_not_one_one{$loc}++ ; 
			}
			else {
			    print "$gene not found in location!\n" ; 
			}
		    }


		}
	    }
	    


	}
	
    }
    elsif ( $gene_count{$spe1} || $gene_count{$spe2} ) {

	for (my $i = 1; $i < @r ; $i++) {

	    if ( $r[$i] =~ /(\S+)\|(\S+)/ ) {
		my $gene = $2 ;
		my $species = $1 ;



		if ( $1 eq $spe1 || $1 eq $spe2 ) {
		    my $loc = $scaffold{$2} ; 
		    if ( $scaffold{$2} ) {
			my $loc = $scaffold{$2} ; 
			$not_found_in_both{$loc}++ ; 
		    }
		    else {
			print "$2 not found in location!\n" ;
		    }


		}
	    }
	}

	

    }



    #system("muscle -in $group.fa -out $group.aln") ;
    #system("muscle -in $group.dna.fa -out $group.dna.aln") ;
 



    $count++ ;
    #last if $count == 10;
}


# start printing out scaffolds

print OUT4 "scaff\tcontig_len\tgenes_in_scaff\tnot_found_in_both\tshared_but_not_one_one\tshared_one_one\t" ; 
print OUT4 "@celscaffolds\n" ; 

foreach my $scaff ( @qryscaffolds ) {

    print OUT4 "$scaff\t$contig_len{$scaff}\t$scaffold_gene_count{$scaff}\t" ; 

    if ( $not_found_in_both{$scaff} ) {
	print OUT4 "$not_found_in_both{$scaff}\t" ; 
    }
    else {
	print OUT4 "0\t" ; 
    }


    if ( $shared_gene_but_not_one_one{$scaff} ) {
	print OUT4 "$shared_gene_but_not_one_one{$scaff}\t" ; 
    }
    else {
	print OUT4 "0\t" ; 
    }

    if ( $shared_gene_in_scaffold{$scaff} ) {
	print OUT4 "$shared_gene_in_scaffold{$scaff}\t" ; 


	# insert things here
	foreach my $celscaffold ( @celscaffolds ) {

	    if ( $genes_in_cel_chrom{$scaff}{"$celscaffold"} ) {
		my $num = $genes_in_cel_chrom{$scaff}{"$celscaffold"} ; 
		print OUT4 "$num\t" ; 
	    }
	    else {
		print OUT4 "0\t" ; 
	    }
	}

    }
    else {
	print OUT4 "0" . ( "\t0" x @celscaffolds ) . "" ; 
    }

    print OUT4 "\n" ; 

}


print "all done! $gene_pairs single gene pairs output!\n" ; 
