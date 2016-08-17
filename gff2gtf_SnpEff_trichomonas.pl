#!/usr/bin/perl -w
use strict;



if (@ARGV != 1) {
    print "$0 gff \n" ; 
	print "Example usage:\n $0  gff\n\n" ;
	exit ;
}

my $file = shift @ARGV;

open (IN, "$file") or die "oops!\n" ;
open OUT, ">", "$file.snpEff.gtf" or die "oooops\n" ; 





## read in the trichoDB
while (<IN>) {
    if ( /^\#\#FASTA/ ) {
	print "all records searched\n" ; 
	last ; 
    }

 
	chomp ;
	my @r = split /\s+/, $_ ;
	

        unless ($r[1]) {
	    print "erm $_\n" ; 
	    exit ; 
	}

	next unless $r[1] eq 'EuPathDB' ; 
	next if $r[2] eq 'supercontig' ; 

	my $gene = $1 ; 

	if ( $r[2] eq 'gene' && $r[8] =~ /ID=(\S+);Name/) {
	    print OUT "$r[0]\tprotein_coding\t$r[2]\t$r[3]\t$r[4]\t$r[5]\t$r[6]\t$r[7]\tgene_id \"$1\"\; gene_name \"$1\"\; gene_source \"TrichDB\"\; gene_biotype \"protein_coding\"\;\n" ; 
	}
	elsif ( $r[2] eq 'mRNA' && $r[8] =~ /ID=(\S+)-\d+\;Name/) {
	    my $mRNA = $1 ; 
	    my $gene ;
	    if ( $mRNA =~ /rna_(\S+)/ ) {
		$gene = $1 ; 
	    }

            print OUT "$r[0]\tprotein_coding\ttranscript\t$r[3]\t$r[4]\t$r[5]\t$r[6]\t$r[7]\tgene_id \"$gene\"\; transcript_id \"$mRNA\"\; gene_name \"$gene\"\; gene_source \"TrichDB\"\; transcript_name \"$mRNA\"\; gene_biotype \"protein_coding\"\;\n" ;
        }
	elsif ( $r[2] eq 'exon' && $r[8] =~ /ID=exon_(\S+)\-(\d+)\;Name/) {
	    my $gene = $1 ; 
	    my $exonnum = $2 ;
	    my $exonname = "exon_$gene" ; 
	    my $mRNA = "rna_$gene" ; 


	    print OUT "$r[0]\tprotein_coding\texon\t$r[3]\t$r[4]\t$r[5]\t$r[6]\t$r[7]\tgene_id \"$gene\"\; transcript_id \"$mRNA\"\; exon_number \"$exonnum\"\; " . 
		"gene_name \"$gene\"\; transcript_name \"$mRNA\"\; gene_biotype \"protein_coding\"\;\n" ;

	}
	elsif ( $r[2] eq 'CDS' ) {
	    next ; 
	}
	elsif ( $r[2] eq 'tRNA' ) {
	    next ; 
	}
	elsif ($r[2] eq 'rRNA') {
            next ;
	}
	else {

	    print "Oops $_\n" ; 
	    exit ; 
	}
}

print "all done! $file.snpEff.gtf generated\n" ; 
