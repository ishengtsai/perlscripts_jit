#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';




if (@ARGV != 2) {
	print "$0 singleline.fasta c_elegans.WS235.annotations.gff2\n\n" ;
	exit ;
}

my $filenameA = $ARGV[0];
my $filenameB = $ARGV[1];

my %gene_present = () ; 

open (IN, "$filenameA") or die "oops!\n" ;

	my $read_name = '' ;
	my $read_seq = '' ;

open OUT, ">", "$filenameA.nr.fa" or die "odpsodsss\n" ; 
open OUTGFF, ">", "$filenameB.reformatted.gff" or die "opsaosa\n" ; 
open OUTID, ">", "$filenameA.id.key" or die "dakdlakdkalskd\n" ; 

my %id = () ; 
my $proteinNO = 0 ; 

my %proteinfound = () ; 
my $proteinfoundNO = 0 ; 

while (<IN>) {

    if (/^>(\S+)\s+\S+\s+(\S+)/) {

	if ( $gene_present{$2} ) {
	    #print "redundant! $1 $2\n" ; 
	}
	else {
	    $gene_present{$2}++ ; 

	    $id{$1} = "$2" ; 
	    $proteinNO++ ; 

	    print OUT ">$1\n" ; 
	    my $seq = <IN> ; 
	    print OUT "$seq" ; 

	    print OUTID "$1\t$2\n" ; 
	}

    }

}

close(IN) ;



open (IN, "$filenameB") or die "oops!\n" ;

my %id_start = () ; 
my %id_end = () ; 
my %id_strand = () ; 
my %id_chr = () ; 

my %id_exons = () ; 


my @ids = () ; 

while (<IN>) {

    chomp ; 
    my @r = split /\s+/, $_ ; 
    next unless $r[1] eq 'curated' ;
    next unless $r[2] eq 'exon' ;

    #print "@r\n" ; 

    my $transcript = $r[9] ; 

    $transcript =~ s/\"//gi ; 

    if ( $id{$transcript} ) {
	
	#print "@r\t$transcript\n" ; 

        unless ( $id_start{$transcript} ) {
	    $id_start{$transcript} = "$r[3]" ; 
	    push(@ids, $transcript) ; 
	}
	$id_end{$transcript} = $r[4] ; 
	$id_strand{$transcript} = $r[6] ; 
	$id_chr{$transcript} = $r[0] ; 

	if ( $id_exons{$transcript} ) {
	    $id_exons{$transcript} .= ".$r[3]-$r[4]" ; 
	}
	else {
	    $id_exons{$transcript} .= "$r[3]-$r[4]" ;
	}
	

    }
    else {

	#print "$transcript not in final set!\n" ; 

    }


}




foreach my $gene ( @ids ) {

    if ( $id_start{$gene} ) {
	my $WBid = $id{$gene} ; 

	print OUTGFF "$id_chr{$gene}\twormbase\tgene\t$id_start{$gene}\t$id_end{$gene}\t.\t$id_strand{$gene}\t.\tID=$gene\;Name=$gene\n" ; 
	print OUTGFF "$id_chr{$gene}\twormbase\tmRNA\t$id_start{$gene}\t$id_end{$gene}\t.\t$id_strand{$gene}\t.\tID=$gene:mRNA\;Name=$gene:mRNA\;Parent=$gene\n" ;

	my @exons = split( /\./, $id_exons{$gene} ) ; 
	
	my $exon_num = 1 ; 
	foreach (@exons) {
	    my @exon = split /-/, $_ ; 
	    print OUTGFF "$id_chr{$gene}\twormbase\texon\t$exon[0]\t$exon[1]\t.\t$id_strand{$gene}\t.\tID=$gene:exon:$exon_num\;" ; 
	    print OUTGFF "Parent=$gene:mRNA\;\n" ; 
	    $exon_num++ ; 
	}


    }
    else {

	print "$gene not found!\n" ; 

    }



}

print "all done! all done!\n" ; 
