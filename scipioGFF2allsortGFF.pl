#!/usr/bin/perl -w
use strict;



my $PI = `echo $$` ; chomp($PI) ;


if (@ARGV != 2) {
    print "$0 scipio_gff color.num\n" ;

	exit ;
}

my $file = shift @ARGV;
my $colour = shift @ARGV ; 

open (IN, "$file") or die "oops!\n" ;

open OUT, ">", "$file.artemis.gff" or die "pppp\n" ;
open OUT2, ">", "$file.augustus.gff" or die "ooooops\n" ;


my %gene_exons = () ;
my %gene_strand = () ;
my %gene_loc = () ;

my %gene_start = () ;
my %gene_end = () ;

## read in the cufflink annotations
while (<IN>) {

    next if /^\#/ ; 
    next if /^\n/ ; 

    chomp ;
    my @r = split /\s+/, $_ ;

# from:
#    7180000833350   Scipio  protein_match   1279146 1279278 0.912   +       0       ID=1590;Query=B0035.10 1 44;Mismatches=32 33
#	7180000833350   Scipio  protein_match   1279330 1279478 0.912   +       2       ID=1590;Query=B0035.10 45 94;Mismatches=65 66 88 91
#	7180000833350   Scipio  protein_match   1279537 1279662 0.912   +       0       ID=1590;Query=B0035.10 95 136

    my $gene = '' ;

    if ($r[8] =~ /Query=(\S+)/ ) {
	$gene = $1 ;
    }

    # location ;
    $gene_loc{$r[0]}{$gene}++ ;

    # strand ;
    $gene_strand{$gene} = "$r[6]" ;

    # exon ;
    if ( $gene_exons{$gene} ) {
	$gene_exons{$gene} .= "\t$r[3]-$r[4]" ;
    }
    else {
	$gene_exons{$gene} = "$r[3]-$r[4]" ;
    }
    
    # gene_start
    if ( $gene_start{$gene} ) {

	if ( $gene_start{$gene} > $r[3] ) {
	    $gene_start{$gene} = $r[3] ; 
	}
	
	if ( $gene_end{$gene} < $r[4] ) {
	    $gene_end{$gene} = $r[4]  ; 
	}


    }
    else {
	$gene_start{$gene} = $r[3] ;
	$gene_end{$gene} = $r[4]  ;
    }

}
close(IN) ;



# now print...

mkdir "$file.forCuration.$PI" ;
print "\n\n\nfolder $file.forCuration.$PI created\n\n\n" ; 


for my $chr (sort keys %gene_loc ) {

    open OUT_ARTEMIS, ">", "$file.forCuration.$PI/$file.$chr.gff" or die "ooops\n" ;

    for my $gene (sort keys % { $gene_loc{$chr} } ) {

#	print "$chr\t$gene\n" ;

	if ( ( $gene_end{$gene} - $gene_start{$gene} ) > 2000000 ) {
	    print "skip $gene because it's 2Mb length!\n" ;
	    next ;
	}
	
	print OUT "$chr\tscipio\tgene\t$gene_start{$gene}\t$gene_end{$gene}\t1000\t$gene_strand{$gene}\t.\tID=$gene\;Name=$gene\n" ;
	print OUT "$chr\tscipio\tmRNA\t$gene_start{$gene}\t$gene_end{$gene}\t.\t$gene_strand{$gene}\t.\tID=$gene:mRNA\;Parent=$gene\n" ;

        print OUT_ARTEMIS "$chr\tscipio\tgene\t$gene_start{$gene}\t$gene_end{$gene}\t1000\t$gene_strand{$gene}\t.\tID=$gene\;Name=$gene\n" ;
        print OUT_ARTEMIS "$chr\tscipio\tmRNA\t$gene_start{$gene}\t$gene_end{$gene}\t.\t$gene_strand{$gene}\t.\tID=$gene:mRNA\;Parent=$gene\n" ;


	my @exons = split /\s+/, $gene_exons{$gene} ; 
	
#	print "@exons\n" ;

	for (my $i = 0 ; $i < @exons; $i++ ) {

	    my @exon = split /-/ , $exons[$i] ; 

	#    print "$exon[0]\t$exon[1]\n" ;

	    #print OUT "$chr\tscipio\texon\t$exon[0]\t$exon[1]\t.\t$gene_strand{$gene}\t.\tID=$gene:exon:" . ($i+1) . "\;Parent=$gene:mRNA\;\n" ;
	    print OUT "$chr\tscipio\tCDS\t$exon[0]\t$exon[1]\t.\t$gene_strand{$gene}\t.\tID=$gene:CDS:" .($i+1) . "\;Parent=$gene:mRNA\;\n" ;

	    print OUT_ARTEMIS "$chr\tscipio\tCDS\t$exon[0]\t$exon[1]\t.\t$gene_strand{$gene}\t.\tID=$gene:CDS:" .($i+1) . "\;Parent=$gene:mRNA\;color=$colour\;\n" ;
	    print OUT2 "$chr\tScipio\tCDS\t$exon[0]\t$exon[1]\t.\t$gene_strand{$gene}\t.\ttranscript_id \"$gene\"\n" ;

	}

    }

}

print "scipio gff converted to view in artemis > $file.artemis.gff\n" ;
