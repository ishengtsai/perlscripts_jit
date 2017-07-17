#!/usr/bin/perl -w
use strict;



if (@ARGV != 1) {
	print "$0 gff \n\n" ;
	print "Example usage:\n $0  gff \n\n" ;

	exit ;
}

my $file = shift @ARGV;
my $fastafile = shift @ARGV ;
my $contig_name = '' ;



open OUT, ">", "$file.gene.location" or die "ooops\n" ; 

#open BED, ">", "$file.bed" or die "ooops\n" ; 


open (IN, "$file") or die "oops!\n" ;

# gff

my $intron_start = '' ; 
my $count = 1; 



my %models = (); 
my %present = () ; 


# read in gff annotations
while (<IN>) {
	
#    ChLG10  BeetleBase      gene    5620    15166   .       -       .       ID=gene:TC012949;biotype=protein_coding;description=Putative uncharacterized protein  [Source:UniProtKB/TrEMBL%3BAcc:D6X3E3];gene_id=TC012949;logic_name=beetlebase
#	ChLG10  BeetleBase      mRNA    5620    15166   .       -       .       ID=transcript:TC012949-RA;Parent=gene:TC012949;biotype=protein_coding;transcript_id=TC012949-RA
#	ChLG10  BeetleBase      exon    5620    6221    .       -       .       Parent=transcript:TC012949-RA;Name=TC012949-E3;constitutive=1;ensembl_end_phase=0;ensembl_phase=1;exon_id=TC012949-E3;rank=3
#	ChLG10  BeetleBase      exon    6845    7140    .       -       .       Parent=transcript:TC012949-RA;Name=TC012949-E2;constitutive=1;ensembl_end_phase=1;ensembl_phase=2;exon_id=TC012949-E2;rank=2
#	ChLG10  BeetleBase      exon    14913   15166   .       -       .       Parent=transcript:TC012949-RA;Name=TC012949-E1;constitutive=1;ensembl_end_phase=2;ensembl_phase=0;exon_id=TC012949-E1;rank=1

    next if /^\#/ ; 
    
    s/\#/\./gi ; 
    chomp ;
    my @r = split /\s+/, $_ ;

	#updated: for parsing the RATT event 
	$r[8] =~ s/\"//gi ; 

	

	
	if ( $r[2] eq 'mRNA' ) {

	    if ( $r[8] =~ /ID=transcript:(\S+)-RA\;Parent/) {

		my $gene = $1 . "-PA" ; 

		#print "$gene\n" ; 
		
		if ( $models{"$r[0]"}{"$r[3]"} ) {
		    print "$r[0] $r[3] already a model\n" ; 
		}
		else {
		    if ( $present{$gene} ) {
			print "$gene already printed\n" ; 
		    }
		    else {
			$models{"$r[0]"}{"$r[3]"} = "$gene $r[3] $r[4]" ; 
			$present{$gene}++ ;
		    }
		}

	    }


	}
	    



	#last;
}
close(IN) ;




for my $scaff (sort keys %models ) {

    my $previous_coord = 0 ; 
    my $gene_in_scaff = 1 ; 

    for my $info ( sort { $a <=> $b } keys (%{ $models{$scaff} }) ) {
	
	my @r = split /\s+/, $models{$scaff}{$info} ; 

#print "$scaff\t@r\n" ; 
	my $countFormatted = sprintf("%05d", $count);

	$scaff =~ s/\#/\./gi ; 
	
	print OUT "$r[0]\t$scaff\t$info\t$scaff....$countFormatted\t$r[2]\t$gene_in_scaff\n" ;
	
	#if ( $gene_in_scaff != 1 ) {
	#    print INTERGENE "" . ( $info - $previous_coord - 1) . "\n" ; 

	#}

	$count++ ;
	$gene_in_scaff++ ; 
	$previous_coord = $r[2] ; 
    }

    
    
}



print "all done!!! $file.gene.location  produced\n" ;
