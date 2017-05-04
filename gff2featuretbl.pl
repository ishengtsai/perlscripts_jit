#!/usr/bin/perl -w
use strict;



if (@ARGV != 1) {
    print "$0 gff \n" ; 

	exit ;
}

my $file = shift @ARGV;


## read the fastas
open (IN, "$file") or die "oops!\n" ;

# like this
#PNOK.scaff0001.C        augustus        gene    6681    7721    .       -       .       ID=PNOK_0000400;Name=PNOK_0000400
#PNOK.scaff0001.C        augustus        mRNA    6681    7721    .       -       .       ID=PNOK_0000400.1:mRNA;Name=PNOK_0000400.1:mRNA;Parent=PNOK_0000400;
#PNOK.scaff0001.C        augustus        exon    6681    7721    .       -       .       ID=PNOK_0000400.1:exon:1;Parent=PNOK_0000400.1:mRNA;color=9
#PNOK.scaff0001.C        augustus        gene    9597    9870    .       +       .       ID=PNOK_0000500;Name=PNOK_0000500
#PNOK.scaff0001.C        augustus        mRNA    9597    9870    .       +       .       ID=PNOK_0000500.1:mRNA;Name=PNOK_0000500.1:mRNA;Parent=PNOK_0000500;
#PNOK.scaff0001.C        augustus        exon    9597    9697    .       +       .       ID=PNOK_0000500.1:exon:1;Parent=PNOK_0000500.1:mRNA;color=9
#PNOK.scaff0001.C        augustus        exon    9747    9870    .       +       .       ID=PNOK_0000500.1:exon:2;Parent=PNOK_0000500.1:mRNA;color=9

my %scaffolds = () ;     
my %ScaffoldGenes = () ; 

my %geneStrand = () ;
my %geneLocation = () ; 
my %exons = () ;


while (<IN>) {

    chomp; 
    my @r = split /\s+/, $_ ; 

    unless ( $scaffolds{ $r[0] } ) {
	$scaffolds{ $r[0] }++;
    }

    if ( $r[2] eq 'gene' && /Name=(\S+)$/) {
	my $genename = $1 ;
	$ScaffoldGenes { $r[0] } { $genename } ++ ;
	$geneStrand { $genename } = $r[6] ;
	$geneLocation { $genename } = "$r[3].$r[4]" ; 
    }

    if ( $r[2] eq 'exon' && /Parent=(\S+).1:mRNA/ ) {
	my $genename = $1 ;
	$exons { $genename } { $r[3] } = $r[4]  ;
    }

    
}
close(IN) ; 



for my $scaffold (sort keys %scaffolds ) {
    next if $scaffold =~ /mito/ ;
    
    print ">Feature $scaffold\n" ; 
    
    for my $gene ( sort keys % { $ScaffoldGenes { $scaffold } } ) {
	my ($start,$end) = split /\./, $geneLocation { $gene } ; 
	print "$start\t$end\t$gene\n" ;
	print "\t\t\t\tlocus_tag\t$gene\n" ; 


	#mRNA
	my $firstExon = 1 ;
	if ( $geneStrand { $gene } eq '+' ) {
	    for my $exonStart ( sort {$a<=>$b} keys %{ $exons{$gene} }  ) {
		my $exonEnd =  $exons{$gene}{$exonStart} ;
		print "$exonStart\t$exonEnd" ;
		if ( $firstExon == 1 ) {
		    print "\tmRNA\n" ;
		    $firstExon = 0 ; 
		}
		else {
		    print "\n" ; 
		}
	    }

	}
	else {
            for my $exonStart ( reverse sort {$a<=>$b} keys %{ $exons{$gene} }  ) {
		my $exonEnd =  $exons{$gene}{$exonStart} ;
		print "$exonStart\t$exonEnd" ;
		if ( $firstExon == 1 ) {
		    print "\tmRNA\n" ;
		    $firstExon = 0 ;
		}
		else {
		    print "\n" ;
		}
	    }
	}
	
	print "\t\t\t\tprotein_id\tgnl|TsaiBRCASPNOKV1|$gene\n" ;
	print "\t\t\t\ttranscript_id\tgnl|TsaiBRCASPNOKV1|mrna.$gene\n";
	

	#CDS
	$firstExon = 1 ;
	if ( $geneStrand { $gene } eq '+' ) {
	    for my $exonStart ( sort {$a<=>$b} keys %{ $exons{$gene} }  ) {
		my $exonEnd =  $exons{$gene}{$exonStart} ;
		print "$exonStart\t$exonEnd" ;
		if ( $firstExon == 1 ) {
		    print "\tCDS\n" ;
		    $firstExon = 0 ;
		}
		else {
		    print "\n" ;
		}
	    }

	}
	else {
	    for my $exonStart ( reverse sort {$a<=>$b} keys %{ $exons{$gene} }  ) {
		my $exonEnd =  $exons{$gene}{$exonStart} ;
		print "$exonStart\t$exonEnd" ;
		if ( $firstExon == 1 ) {
		    print "\tCDS\n" ;
		    $firstExon = 0 ;
		}
		else {
		    print "\n" ;
		}
	    }
	}

	print "\t\t\t\tprotein_id\tgnl|TsaiBRCASPNOKV1|$gene\n" ;
	print "\t\t\t\ttranscript_id\tgnl|TsaiBRCASPNOKV1|mrna.$gene\n";



    }

    


}
