#!/usr/bin/perl -w
use strict;



if (@ARGV != 4) {
    print "$0 gff1[braker1; exon] gff2[CDS] gff3[CDS] ref.fa \n" ; 

	exit ;
}

my $file = shift @ARGV;
my $file2 = shift @ARGV ;
my $file3 = shift @ARGV;

my $ref = shift @ARGV ; 

my %scaffolds = () ;     
my %ScaffoldGenes = () ; 
my %genestrand = () ; 
my %geneLocation = () ;
my %geneContent = () ; 


my %exonsFile1 = () ;
my %exonsFile2 = () ;
my %exonsFile3 = () ;


my %geneblock = () ; 

my %toTrain = () ; 


my %snapToTrain = () ; 
# SNAP minus
#Einit  368119 367817 MODEL1174
#    Exon  367767 367469 MODEL1174
#    Exon  367417 367243 MODEL1174
#    Exon  367184 366786 MODEL1174
#    Eterm  366738 366619 MODEL1174

# SNAP plus
#Einit  483263 483775 MODEL1136
#    Exon  483837 484093 MODEL1136
#    Exon  484142 484352 MODEL1136
#    Exon  484406 484830 MODEL1136
#    Exon  484886 485090 MODEL1136
#    Exon  485143 485292 MODEL1136
#    Exon  485375 485479 MODEL1136
#    Eterm  485537 485590 MODEL1136


open (IN, "$file") or die "oops!\n" ;
my $genename = ''  ;
my $geneloc = '' ; 
while (<IN>) {

    chomp; 
    my @r = split /\s+/, $_ ; 

    unless ( $scaffolds{ $r[0] } ) {
	$scaffolds{ $r[0] }++;
    }

    if ( $r[2] eq 'gene' && /Name=(\S+)$/) {
	$genename = $1 ;
	$geneloc = "$r[3].$r[4]" ; 
	$ScaffoldGenes { $r[0] } { $genename } ++ ;
	$geneLocation { $genename  } = "$r[0].$geneloc" ;
	$genestrand { $genename } = $r[6] ; 
	$geneContent { "$r[0].$geneloc" } ++ ; 
    }

    $geneblock{ $genename} .= "$_\n" ; 
    
    if ( $r[2] eq 'exon'  ) {
	$exonsFile1 { "$r[0].$geneloc" } .= "$r[3]$r[4]" ;

	$toTrain { "$r[0].$geneloc" } .= "$r[0]\tmanual\tCDS\t$r[3]\t$r[4]\t1000\t$r[6]\t3\ttranscript_ID \"$genename\"\n" ;

	$snapToTrain{ "$r[0].$geneloc" } .= "$r[3].$r[4] " ;
    }

    
}
close(IN) ; 

open (IN, "$file2") or die "oops!\n" ;
while (<IN>) {

    chomp;
    my @r = split /\s+/, $_ ;

    if ( $r[2] eq 'gene' ) {
	$geneloc = "$r[3].$r[4]" ;
	$geneContent { "$r[0].$geneloc" } ++ ;
    }
    if ( $r[2] eq 'CDS'  ) {
	$exonsFile2 { "$r[0].$geneloc" } .= "$r[3]$r[4]" ;
    }


}
close(IN) ;

open (IN, "$file3") or die "oops!\n" ;
while (<IN>) {

    chomp;
    my @r = split /\s+/, $_ ;

    if ( $r[2] eq 'gene' ) {
	$geneloc = "$r[3].$r[4]" ;
	$geneContent { "$r[0].$geneloc" } ++ ;
    }
    if ( $r[2] eq 'CDS'  ) {
	$exonsFile3 { "$r[0].$geneloc" } .= "$r[3]$r[4]" ;
    }


}
close(IN) ;


my $numExactModels = 0 ;

open OUT, ">", "$file.forAugustus.training" or die "daosdpaodoadpoaspda\n" ; 
open OUTSNAP, ">", "genome.ann" or die "daosdpaoda\n" ;
open OUTSNAP2, ">", "genome.scaffolds.list" or die "daodpasdoaopdpaopda\n" ;

my %snap_included_scaffold = () ; 

for my $scaffold (sort keys %scaffolds ) {


    for my $gene (sort keys %{ $ScaffoldGenes { $scaffold } } ) {
	my $locus = $geneLocation { $gene  } ; 
	my $strand = $genestrand { $gene } ; 
	my $numOverlap = $geneContent { $locus } ; 

	
	if ( $numOverlap == 3 ) {
	    #print "$gene\t$locus\n" ;

	    if ( $snap_included_scaffold{ $scaffold } ) {

	    }
	    else {
		$snap_included_scaffold{ $scaffold }++ ;
		print OUTSNAP ">$scaffold\n" ;
		print OUTSNAP2 "$scaffold\n" ; 
	    }

	    
	    if ( $exonsFile1{ $locus } eq $exonsFile2{ $locus } &&  $exonsFile1{ $locus } eq $exonsFile3{ $locus } ) {

		# Do something here!
		$numExactModels++ ;

		print OUT "$toTrain{ $locus }" ; 

		my @exons = split /\s+/, $snapToTrain{ $locus } ; 
		my $exonnum = @exons ; 

		#print "$exonnum $#exons\n" ; 
		
		if ( $exonnum == 1 ) {
		    foreach(@exons) {
			my ($left, $right) = split /\./, $_ ;
			
			if ( $strand eq '+' ) {
			    print OUTSNAP "Esngl $left $right $gene\n" ;
			}
			else {
			    print OUTSNAP "Esngl $right $left $gene\n" ; 
			}
		    }
		}
		else {

		    if ( $strand eq '+' ) {
			my ($startleft, $startright) = split /\./, $exons[0] ;
			print OUTSNAP "Einit $startleft $startright $gene\n" ; 

			if ( $exonnum > 2 ) {
			    for (my $i = 1 ; $i < $#exons ; $i++ ) {
				my ($left, $right) = split /\./, $exons[$i] ;
				print OUTSNAP "Exon $left $right $gene\n" ;
			    }
			}

			my ($endleft, $endright) = split /\./, $exons[$#exons] ;
			print OUTSNAP "Eterm $endleft $endright $gene\n" ;
			
		    }
		    else {
			my ($startright, $startleft) = split /\./, $exons[$#exons] ;
			print OUTSNAP "Einit $startleft $startright $gene\n" ;

			if ( $exonnum > 2 ) {
			    for (my $i = $#exons-1 ; $i > 0 ; $i-- ) {
				my ($right, $left) = split /\./, $exons[$i] ;
				print OUTSNAP "Exon $left $right $gene\n" ;
			    }
			}
			my ($endright, $endleft) = split /\./, $exons[0] ;
			print OUTSNAP "Eterm $endleft $endright $gene\n" ;

		    }
		
		}
		
	    }

	}
	
    }

}


print "total number of exact models: $numExactModels\n" ; 
print "$file.forAugustus.training geberated for augustus training!\n" ; 

system("fasta_include_subsets.pl $ref genome.scaffolds.list") ;
system("cp ref.fa.included.fa genome.dna") ; 
print "genome.ann and genome.dna produced!\n" ; 


