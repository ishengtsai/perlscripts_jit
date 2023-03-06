#!/usr/bin/perl -w
use strict;



if (@ARGV != 3) {
	print "$0 gff contigs.fa.len.txt species\n\n" ;

	exit ;
}

my $file = shift @ARGV;
my $contiglenfile = shift @ARGV ; 
my $species = shift @ARGV ; 
my $id = 0 ; 


print "start id: $id\n" ; 




open (IN, "$file") or die "oops!\n" ;

open OUT, ">", "$file.forPASA.gff" or die "ooops\n" ;



my @contig_order = () ; 

open (CON, "$contiglenfile") or die "ooops\n" ; 
while (<CON>) {
    chomp ; 
    my @r = split /\s+/, $_ ; 
    push(@contig_order, $r[0]) ; 
}
close(CON) ; 

my %gene_strand = () ;
my %gene_loc = () ;
my %gene_exons = () ;
my %gene_exon_num = () ;
my %gene_introns = () ;
my %gene_intron_num = () ;

my %gene_start = () ;
my %gene_stop  = () ;


my $genecount = $id ; 
my $transcriptcount = 0 ; 


## read in the cufflink annotations
while (<IN>) {
	

	next if /^\#/ ;
	next if /^\n/ ;

	chomp ;
	my @r = split /\s+/, $_ ;

	next unless $r[1] eq 'AUGUSTUS' ; 




	if ($r[2] eq 'gene' ) {
            $genecount++ ;

	}
	if ($r[2] eq 'transcript') {
	    $transcriptcount++ ; 

	    #my $idnum = sprintf("%07d", $genecount * 100) ; 
	    #my $transcriptnum = 1; 
	    
	    if ( $r[11] =~ /\"(.+)\"/ ) {
		$transcriptnum = $1 ; 
	    }
	    $id = "$species\_$idnum.$transcriptnum" ; 


	    $gene_strand{$id} = "$r[6]" ;
            $gene_loc{$r[0]}{$id} = "$r[3]\t$r[4]" ;
	    
	    #print "$_  $id $r[6]\n" ;
	}

	if ( $r[2] eq 'CDS' ) {
	    $gene_exon_num{$id}++ ;

	    my $exon_num = $gene_exon_num{$id} ;
	    $gene_exons{$id}{$exon_num} = "$r[3]\t$r[4]" ;

	}

	if ( $r[2] eq 'intron' ) {
	    $gene_intron_num{$id}++ ;

	    my $intron_num = $gene_intron_num{$id} ;
	    $gene_introns{$id}{$intron_num} = "$r[3]\t$r[4]" ;

	}

	#last;
}
close(IN) ;


my $gene_total = 0 ;
my $gene_valid = 0 ;

my %present = () ; 

foreach my $contig (@contig_order ) {

    for my $gene (sort keys  % {$gene_loc{$contig}} ) {

	#print "$gene\n" ;
	$gene_total++ ;

	if ( $gene_start{$gene} && $gene_stop{$gene} ) {
	    $gene_valid++ ;
	}
#	    print "$gene $gene_strand{$id}\n" ;
	
	my $gene_master_name ='' ; 

	if ( $gene =~ /(\S+)\.\d+/ ) {
	    $gene_master_name = $1 ; 
	}
	if ( $present{$gene_master_name} ) {

	}
	else {
	    
	    #print OUT "$contig\tbraker1\tgene\t$gene_loc{$contig}{$gene}\t.\t$gene_strand{$gene}\t.\tID=$gene_master_name\;Name=$gene_master_name\n" ;

	    # only one isoform
	    if ( $gene =~ /\.1$/ ) {

		print OUT "$contig\tbraker1\tgene\t$gene_loc{$contig}{$gene}\t.\t$gene_strand{$gene}\t.\tID=$gene_master_name\;Name=$gene_master_name\n" ;
		
		print OUT "$contig\tbraker1\tmRNA\t$gene_loc{$contig}{$gene}\t.\t$gene_strand{$gene}\t.\tID=$gene:mRNA\;Name=$gene:mRNA\;Parent=$gene_master_name\;\n" ;
		

		for (my $i = 1 ; $i < ($gene_exon_num{$gene}+1) ; $i++) {
		    
		    print OUT "$contig\tbraker1\tCDS\t$gene_exons{$gene}{$i}\t.\t$gene_strand{$gene}\t.\tID=$gene:CDS:$i\;Parent=$gene:mRNA\;\n" ;
		    print OUT "$contig\tbraker1\texon\t$gene_exons{$gene}{$i}\t.\t$gene_strand{$gene}\t.\tID=$gene:exon:$i\;Parent=$gene:mRNA\;\n" ;
		    
		}

		
        }


	}


	
    }

}



print "all done!!!\n" ;
print "$genecount total genes\n" ;
print "$transcriptcount total transcripts\n" ; 
print "$gene_valid has a both a start and stop\n" ;

my $idnum = sprintf("%07d", $genecount * 100) ;
$id = "$species\_$idnum" ;
print "last id: $id\n" ;








