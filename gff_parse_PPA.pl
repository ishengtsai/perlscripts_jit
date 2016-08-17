#!/usr/bin/perl -w
use strict;



if (@ARGV != 2) {
    print "$0 BMA.fa gff \n" ;
	print "Example usage:\n $0 BMA.fa gff \n" ;

	exit ;
}
my $fasfile = shift @ARGV ; 
my $file = shift @ARGV;


my %fasta = () ; 
open(IN, "$fasfile") or die "daodsiaosid\n" ; 
while (<IN>) {

    chomp; 
    if ( />(\S+)/ ) {
	$fasta{$1}++ ; 
    }


}
close(IN) ; 

open (IN, "$file") or die "oops!\n" ;

my $exon_num = 0  ;
my $gene = '' ; 
  

my %gene_start = () ; 
my %gene_end = () ; 
my %gene_strand = () ; 
my %gene_exons = () ; 

my %scaffolds = () ; 


while (<IN>) {
    next if /\#/ ; 

    my @r = split /\s+/, $_ ; 

#    next unless $r[1] eq 'Coding_transcript' ;
#    next unless $r[2] eq 'coding_exon' ; 

    next unless $r[1] eq 'curated' ; 
    next unless $r[2] eq 'coding_exon' ; 

    $r[9] =~ s/\"//gi ; 
    $gene = $r[9] ; 

    #if ( $r[9] ) {
#
 #   }
  #  else {
	#print "wierd: $_" ; 
	#exit ; 
    #}

    next unless $fasta{$gene} ;

#	print "$_" ; 

	if ( $gene_start{$gene} ) {
	    $gene_start{$gene} = $r[3] if  $r[3] < $gene_start{$gene} ;
	}
	else {
	    $gene_start{$gene} = $r[3] ; 
	}

	if ( $gene_end{$gene} ) {
	    $gene_end{$gene} = $r[4]  if  $r[4] > $gene_end{$gene} ; 
	}
	else {
	    $gene_end{$gene} = $r[4] ; 
	}

	$scaffolds{$r[0]}{$gene}++ ; 
	$gene_strand{$gene} = $r[6] ; 
	$gene_exons{$gene} .= "$_" ; 





}
close(IN); 


for my $scaff (sort { $a cmp $b } keys %scaffolds ) {

    for my $geneinscaff (sort { $a cmp $b } keys %{ $scaffolds{$scaff} } ) {
	my $strand = $gene_strand{$geneinscaff} ; 

	#print "strand: $strand\n" ; 

	print "$scaff\twormbase\tgene\t$gene_start{$geneinscaff}\t$gene_end{$geneinscaff}\t.\t$strand\t.\tID=$geneinscaff\;Name=$geneinscaff\n" ; 
	print "$scaff\twormbase\tmRNA\t$gene_start{$geneinscaff}\t$gene_end{$geneinscaff}\t.\t$strand\t.\tID=$geneinscaff:mRNA\;Name=$geneinscaff:mRNA\;Parent=$geneinscaff\n" ;
	

	my @exons = split /\n/, $gene_exons{$geneinscaff} ; 

	my $isreverse = 0 ; 

	if ( @exons > 1 ) {

	    my $exon1start = 0 ; 
	    my $exon2start = 0 ; 


	    if ( $exons[0] =~ /exon\s+(\d+)\s+/ ) {
		$exon1start = $1 ; 
	    }
	    if ( $exons[1] =~ /exon\s+(\d+)\s+/) {
		$exon2start = $1 ;
	    }

	    $isreverse = 1 if $exon1start > $exon2start ; 

	}



	if ( $isreverse == 1 ) {
	    my @reversedExons = reverse(@exons) ;
             @exons = @reversedExons ;
	}

	my $exonnum = 1 ; 
	foreach (@exons) {
	    my @r = split /\s+/, $_ ; 

	    print "$scaff\twormbase\texon\t$r[3]\t$r[4]\t.\t$strand\t.\tID=$geneinscaff:exon:$exonnum\;Parent=$geneinscaff:mRNA\n" ; 
	    $exonnum++ ; 
	}
	


	


    } 


}
