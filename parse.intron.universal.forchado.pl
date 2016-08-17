#! /usr/bin/perl -w
#
# Copyright (C) 2009 by Pathogene Group, Sanger Center
#
# Author: JIT


if (@ARGV != 3 ) {
    print "$0 fasta gff SPECIES\n" ; 
    exit ; 
}

my $fastafile = shift ; 
my $file = shift ; 
my $species = shift ; 


open (IN, "$fastafile") or die "oops!\n" ;

my $read_name = '' ;
my $read_seq = '' ;

my %fasta = () ; 
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




open( IN, "$file" ) or die "Cannot open $file\n" ; 



open OUT, ">", "$file.intron.len.txt" or die "ooops\n" ; 
open SUM, ">", "$file.intron.summary" or die "oosoaposa\n" ; 

open SUM2, ">", "$file.gene.exon.summary" or die "daidsioadioiaosda\n" ; 

open EXON, ">", "$file.gene.exon.len.txt" or die "dospaodpdop\n" ; 

open FA_FIVEEND, ">", "$file.5end.fa" or die "oooops\n" ; 
open FA_THREEEND, ">", "$file.3end.fa" or die "oooops\n" ; 
#open WHOLE, ">", "$file.whole.fa" or die "ooooops\n" ; 

my $exonnum = 0 ; 
my %exoncount = () ; 

my %gene_previous = () ; 

while (<IN>) {

    chomp; 
    my @r = split /\s+/, $_ ; 


    if ( $r[2] ) {



	if ( $r[2] eq 'CDS' ) {
	    
	    if ( $r[8] =~ /ID=(\S+):exon:(\d+)\;Parent/ ) {
		
		$exoncount{$1}++ ;
		$exonnum = $exoncount{$1} ; 
		my $gene = $1 ; 

		print EXON "$gene\t" . ( $r[4] - $r[3] + 1 ) . "\n" ; 


		if ( $exonnum > 1 ) {

		    my $previous = $gene_previous{$gene} ;

		    if ( ($r[3] - $previous + 1 ) > 1 ) {
			my $intronlen = $r[3] -1 - ($previous+1)  + 1 ; 
			print OUT "$species\t$intronlen\n" ; 



			my $seq = substr($fasta{$r[0]}, $previous , $intronlen) ; 
			my $seqWithExon = substr($fasta{$r[0]}, $previous -5 , $intronlen + 10 ) ; 

			if ( $r[6] eq '-' ) {
			    $seq = revcomp($seq) ; 
			    $seqWithExon = revcomp($seqWithExon) ; 
			}


			$seq = uc($seq) ; 
			$seqWithExon = uc($seqWithExon) ; 

			my $first = substr($seq, 0, 2) ;
			my $first5 = substr($seq, 0 , 5) ;

                        my $second = substr($seq, -2) ;
                        my $second5 = substr($seq, -5) ;

                        my ($A_content, $T_content, $C_content, $G_content)  = basecontent($seq) ;

                        print SUM "$r[0]\t$r[6]\t" . ($previous+1) . "\t" . ($r[3]-1) . "\t$intronlen\t" ;
                        print SUM "$first.$second\t$first5\t$second5\t$A_content\t$T_content\t$C_content\t$G_content\n" ;


			my $first15 = substr($seqWithExon, 0, 20) ; 
			my $second15 = substr($seqWithExon, -20) ; 


			print FA_FIVEEND ">$r[0].$previous\n$first15\n" ; 
			print FA_THREEEND ">$r[0].$previous\n$second15\n";
			#print WHOLE ">$r[0].$previous\n$seq\n" ; 

		    }
		    else  {
			print "wtf! wrong $_\n" ; 
			print "previous: $previous\n" ; 
			exit ; 
		    }



		    
		}
		

		$gene_previous{$gene} = $r[4] ; 
	    }
	    



	    #print "$_\n" ;
	}
	
    }



}
close(IN) ; 



#print out intron count per gene
for my $gene (sort keys %exoncount ) {

    print SUM2 "$gene\t$exoncount{$gene}\n" ; 

}




sub revcomp {
    my $dna = shift;
    my $revcomp = reverse($dna);

    $revcomp =~ tr/ACGTacgt/TGCAtgca/;

    return $revcomp;
}


sub basecontent {

    my $seq = shift ; 
    
    my $A_count = $seq =~ s/([a])/$1/gi;
    my $T_count = $seq =~ s/([t])/$1/gi;
    my $C_count= $seq =~ s/([c])/$1/gi;
    my $G_count= $seq =~ s/([g])/$1/gi;
    
    my $A_content = sprintf("%.2f", $A_count / length($seq) ) ; 
    my $T_content = sprintf("%.2f", $T_count / length($seq) ) ;   
    my $C_content = sprintf("%.2f", $C_count / length($seq) ) ;
    my $G_content = sprintf("%.2f", $G_count / length($seq) ) ;
    

    return($A_content, $T_content, $C_content, $G_content) ; 

}


