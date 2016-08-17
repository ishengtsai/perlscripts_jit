#!/usr/bin/perl -w
use strict;



if (@ARGV != 1) {
	print "$0 fasta \n\n" ;
	print "Example usage:\n $0  gff \n\n" ;

	exit ;
}

my $fastafile = shift @ARGV ;


my $contig_name = '' ;




#open BED, ">", "$file.bed" or die "ooops\n" ; 

my %models = () ; 

open (IN, "$fastafile") or die "oops!\n" ;
open OUTFA, ">", "$fastafile.renamed.fasta" or die "dosaopdosapdopapdos\n" ; 
open OUT, ">", "$fastafile.gene.location" or die "ooops\n" ;

my $gene = '' ; 
my %present = () ; 
my $genepresent = 0 ; 

while (<IN>) {
    my @r = split /\s+/, $_ ; 

    if ( /^>(\S+)\.\d+:pep/ ) {

	my $scaff = '' ; 
	my $start = 0 ; 
	my $end = 0 ; 
	my $gene = $1 ; 

	if ( $r[2] =~ /chromosome:(\S+):(\S+):(\d+):(\d+):/ ) {
	    $scaff = $2 ; 
	    $start = $3 ; 
	    $end = $4; 
	}


	if ( $present{$gene} ) {
	    $genepresent = 1 ; 
	    next ; 
	}
	else {
	    $genepresent = 0 ; 
	}

	$models{"$scaff"}{"$start"} = "$gene $start $end" ;
	$present{$gene}++ ; 
	print OUTFA ">$gene\n" ; 
    }
    else {
	print OUTFA "$_" if $genepresent == 0 ; 
    }
}
close(IN); 








my $count = 1; 







for my $scaff (sort keys %models ) {
    
    for my $info ( sort { $a <=> $b } keys (%{ $models{$scaff} }) ) {
	
	my @r = split /\s+/, $models{$scaff}{$info} ; 

#print "$scaff\t@r\n" ; 
	my $countFormatted = sprintf("%05d", $count);
	
	print OUT "$r[0]\t$scaff\t$info\t$scaff....$countFormatted\t$r[2]\n" ;
	
	$count++ ;
    }

    
    
}



#print "all done!!!\n" ;
