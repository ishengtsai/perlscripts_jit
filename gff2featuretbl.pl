#!/usr/bin/perl -w
use strict;



if ( @ARGV != 4) {
    print "$0 gff product to_exclude to_exclude_2 \n" ; 

	exit ;
}

my $file = shift @ARGV;
my $productfile = shift @ARGV ; 

my $excludefile = shift @ARGV ; 
my $excludefile2 = shift @ARGV ; 



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
my %productDESC = () ; 

my %exclude = () ;

#11 ERROR:   SEQ_FEAT.InternalStop
#    2 ERROR:   SEQ_FEAT.StartCodon
#    2 ERROR:   SEQ_INST.BadProteinStart
#    11 ERROR:   SEQ_INST.StopInProtein

#    7 ERROR:   SEQ_FEAT.NoStop
#    SEQ_FEAT.BadTrailingCharacter

open (IN, "$excludefile") or die "daosdpadoapdoas\n" ;

while (<IN>) {

    if ( /SEQ_FEAT.BadTrailingCharacter/ ) {
	chomp ;
	#print "$_\n" ;

	if ( /\|(\D+\d+)\]$/ ) {
	    #print "$1\n" ;
	    $exclude{$1}++ ;
	}
    }

    
    if ( /SEQ_FEAT.NoStop/ ) {
	chomp ;
	#print "$_\n" ;

	if ( /\|(\D+\d+)\]$/ ) {
	    #print "$1\n" ;
	    $exclude{$1}++ ;
	}
    }
    
    if ( /SEQ_FEAT.InternalStop/ ) {
	chomp ;
	#print "$_\n" ; 
	
	if ( /\|(\D+\d+)\]$/ ) {
	    #print "$1\n" ;
	    $exclude{$1}++ ; 
	}
    }

    if ( /SEQ_FEAT.StartCodon/ ) {
	chomp ;
	#print "$_\n" ;

	if ( /\|(\D+\d+)\]$/ ) {
	    #print "$1\n" ;
	    $exclude{$1}++ ;
	}
    }

    if ( /SEQ_INST.BadProteinStart/ ) {
	chomp ;
	#print "$_\n" ;

	if ( /\|(\D+\d+)\]$/ ) {
	    #print "$1\n" ;
	    $exclude{$1}++ ;
	}
    }

    if ( /SEQ_INST.StopInProtein/ ) {
	chomp ;
	#print "$_\n" ;

	if ( /\|(\D+\d+)\]$/ ) {
	    #print "$1\n" ;
	    $exclude{$1}++ ;
	}
    }

}
close (IN) ; 


open (IN, "$excludefile2") or die "daosdpadoapdoas\n" ;

while (<IN>) {
    chomp ;
    my @r = split /\s+/, $_ ;
    $exclude{$r[1]}++ ; 
}
close(IN) ; 




open (IN, "$productfile") or die "daospdaooap\n" ;
while (<IN>) {
    next if /^SeqName/ ;
    chomp ; 
    my @r = split /\t/ ; 

    $r[0] =~ s/\.1// ;
    $r[1] =~ s/\s+$//gi ; 

    # partial
    $r[1] =~ s/partial$// ;
    $r[1] =~ s/pseudo$// ; 
    $r[1] =~ s/\s+$//gi ;
    
    next if $r[1] =~ /hypothetical/ ;
    next if $r[1] =~ /---NA---/ ;
    next if $r[1] =~ /DUF\d+/gi ;
    next if $r[1] =~ /=/ ;
    next if $r[1] =~ /\#/ ;
    next if $r[1] =~ /^-/ ;
    next if $r[1] =~/^\d+$/ ;
    next if $r[1] =~/\[.+\]/ ;
    next if $r[1] eq 'predicted protein' ; 
    next if $r[1] =~ /Plasmodium/ ; 
    next if $r[1] =~ /c-term/gi ; 
    
    if ( $r[1] =~ /\-\s?$/ ) {
	$r[1] =~ s/\-\s?$// ;
    } 

    if ( $r[1] =~ /\_$/ ) {
	$r[1] =~ s/\_$// ;
    }
    
    next if $r[1] =~ /Crystal Structure/ ;
    next if $r[1] =~ /structure of/ ;
    next if $r[1] =~ /homolog/ ;
    next if $r[1] =~ /domain$/ ; 
    next if $r[1] =~ /fold$/ ;
    next if $r[1] =~ /motif$/ ;
    next if $r[1] =~ /uncharacterized protein/ ; 
    
    #plaural
    $r[1] =~ s/factors$/factor/ ;
    $r[1] =~ s/vesicles$/vesicle/ ;
    $r[1] =~ s/domains$/domain/;
    $r[1] =~ s/hydrolases$/hydrolase/;
    $r[1] =~ s/phosphatases$/phosphatase/ ;
    $r[1] =~ s/photoreceptors/photoreceptor/ ;
    $r[1] =~ s/intraradices/intraradix/ ;
    $r[1] =~ s/repeats/repeat/ ; 
    
    $r[1] =~ s/like$/like protein/ ;
    $r[1] =~ s/related$/related protein/ ;
    $r[1] =~ s/repeat$/repeat protein/ ;
    $r[1] =~ s/^related/protein related/ ;
    $r[1] =~ s/\(//gi ;
    $r[1] =~ s/\)//gi ;
    $r[1] =~ s/Tf2 155 kDa type \d+// ;

    

    $r[1] =~ s/COG complex component/conserved oligomeric golgi complex component/ ; 
    

    
    $r[1] =~ s/\s+$//gi ;



    
    # More filtering!
    next if $r[1] =~ 'protein related to TY4B- pseudo' ; 
    next if $r[1] =~ /meiotically up-regulated 152/ ;
    next if $r[1] eq 'DNA RNA' ; 

    if ( $r[1] =~ /binding$/ ) {
	$r[1] =~ s/binding$/binding protein/ ;
    }
    if ( $r[1] =~ /domain$/ ) {
	$r[1] =~ s/domain$/domain containing protein/ ;
    }

    unless ( $r[1] =~ /\w+/ ) {
	next ;
    }
    
    next unless $r[1] ; 
    
    #print "$r[0]\t$r[1]\n" ;
    $productDESC{$r[0]} = $r[1] ; 
}

close(IN) ; 
#exit ; 


open (IN, "$file") or die "oops!\n" ;

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

	next if $exclude{$gene} ; 

	my ($start,$end) = split /\./, $geneLocation { $gene } ; 

	if ( $geneStrand { $gene } eq '+' ) {
	    print "$start\t$end\tgene\n" ;
	}
	else {
	    print "$end\t$start\tgene\n" ; 
	}
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
		print "$exonEnd\t$exonStart" ;
		if ( $firstExon == 1 ) {
		    print "\tmRNA\n" ;
		    $firstExon = 0 ;
		}
		else {
		    print "\n" ;
		}
	    }
	}

	if ( $productDESC{$gene} ) {
	    print "\t\t\t\tproduct\t$productDESC{$gene}\n" ; 
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
		print "$exonEnd\t$exonStart" ;
		if ( $firstExon == 1 ) {
		    print "\tCDS\n" ;
		    $firstExon = 0 ;
		}
		else {
		    print "\n" ;
		}
	    }
	}

	if ( $productDESC{$gene} ) {
	    print "\t\t\t\tproduct\t$productDESC{$gene}\n" ;
	}
	print "\t\t\t\tprotein_id\tgnl|TsaiBRCASPNOKV1|$gene\n" ;
	print "\t\t\t\ttranscript_id\tgnl|TsaiBRCASPNOKV1|mrna.$gene\n";



    }

    


}
