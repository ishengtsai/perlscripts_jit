#! /usr/bin/perl -w
#
# Copyright (C) 2009 by Pathogene Group, Sanger Center
#
# Author: JIT


if (@ARGV != 2 ) {
    print "$0 gff SPECIES\n" ; 
    exit ; 
}


my $file = shift ; 
my $species = shift ; 


open( IN, "$file" ) or die "Cannot open $file\n" ; 
open OUT, ">", "$file.intron.len.txt" or die "ooops\n" ; 
open SUM2, ">", "$file.gene.exon.summary" or die "daidsioadioiaosda\n" ; 
open EXON, ">", "$file.gene.exon.len.txt" or die "dospaodpdop\n" ; 



my $exonnum = 0 ; 
my %exoncount = () ; 

my %gene_previous = () ; 

while (<IN>) {

    chomp; 
    my @r = split /\s+/, $_ ; 


    if ( $r[2] ) {



	if ( $r[2] eq 'CDS' ) {
	    
	    if ( $r[8] =~ /ID=cds:(\S+);Parent/ ) {
		
		$exoncount{$1}++ ;
		$exonnum = $exoncount{$1} ; 
		my $gene = $1 ; 

		print EXON "$species\t" . ( $r[4] - $r[3] + 1 ) . "\n" ; 


		if ( $exonnum > 1 ) {
		    
		    my $previous = $gene_previous{$gene} ;

		    if ( $r[6] eq '+' ) {

			if ( ($r[3] - $previous + 1 ) > 1 ) {
			    my $intronlen = $r[3] -1 - $previous ; 
			    print OUT "$species\t$intronlen\n" ; 
			}
			else  {
			    print "wtf! wrong $_\n" ; 
			    print "previous: $previous\n" ; 
			    exit ; 
			}
		    }
		    else  {
			if ( ($previous - $r[4] + 1 ) > 1 ) {
			    my $intronlen = $previous -1  - $r[4]   ;
                            print OUT "$species\t$intronlen\n" ;
			}
			else {
			    print "wtf! wrong $_\n" ;
                            print "previous: $previous\n" ;
                            exit ;
			}


		    }



		    
		}
		
		if ( $r[6] eq '+' ) {
		    $gene_previous{$gene} = $r[4] ; 
		}
		else {
		    $gene_previous{$gene} = $r[3] ;
		}


	    }
	    



	    #print "$_\n" ;
	}
	
    }



}
close(IN) ; 



#print out exon count per gene
for my $gene (sort keys %exoncount ) {

    print SUM2 "$species\t$exoncount{$gene}\n" ; 

}


print "all done! for $file\n" ; 


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


