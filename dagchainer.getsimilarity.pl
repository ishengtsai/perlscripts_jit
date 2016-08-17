#!/usr/bin/perl -w
use strict;







if (@ARGV != 2) {
    print "$0 fasta dagchainer.input.filtered.aligncoords\n" ; 
	exit ;
}

my $filenameA = shift ; 
my $dagfile = shift ; 

open (IN, $filenameA) or die "can't open $filenameA\n" ; 
my %fasta = () ; 

my $read_name = '' ;
my $read_seq = '' ;

while (<IN>) {
            if (/^>(\S+)/) {
                $read_name = $1 ;
                $read_seq = "" ;

                while (<IN>) {

		    if (/^>(\S+)/) {
			$fasta{$read_name} = $read_seq ; 
			$read_name = $1 ;
			$read_seq = "" ;
		    }
		    else {
			chomp ;
			$read_seq .= $_ ;
		    }


                }

            }
}

close(IN) ;

$fasta{$read_name} = $read_seq ;

open (IN, $dagfile) or die "can't open $filenameA\n" ;

while (<IN>) {

    chomp ;
    if (/^\#/ ) {
	print "$_\n" ;
	next ; 
    }
    my @r = split /\s+/, $_ ; 

    my $gene1 = $r[1] ; 
    my $gene2 = $r[5] ; 

    print "$_\t" ; 

    if ( $fasta{$gene1} && $fasta{$gene2} ) {

	open TMP, ">", "tmp.fa" or die "ooops!\n" ;
	print TMP ">$gene1\n$fasta{$gene1}\n" ;
	print TMP ">$gene2\n$fasta{$gene2}\n" ;
	close(TMP) ;

	# alignment
	system("mafft --maxiterate 1000 --localpair tmp.fa > tmp.aln") ;
	system("fasta2singleLine_IMAGE.pl tmp.aln tmp.SL.aln") ;

	open (ALN, "tmp.SL.aln") or die "ooops!\n" ;
	my $tmp = <ALN> ;
	my $aln1 = <ALN> ;
	chomp($aln1) ;
	$tmp = <ALN> ;
	my $aln2= <ALN> ;
	chomp($aln2) ;
	close(ALN) ;

	my $same = 0 ;
	my $bothnucleotide = 0 ;
	for (my $i = 0 ; $i < length($aln1) ; $i++ ) {
	    my $base1 = substr($aln1, $i, 1) ;
	    my $base2 = substr($aln2, $i, 1) ;

	    if ( $base1 eq '-'  || $base2  eq '-' ) {
		next ;
	    }



	    $same++ if $base1 eq $base2 ;
	    $bothnucleotide++ ;


	}

	my $similarity = sprintf ("%.3f", $same / $bothnucleotide ) ;
	my $similarity_gap = sprintf ("%.3f", $same /length($aln1) ) ;
	
	print "" . (length($fasta{$gene1}) ). "\t". (length($fasta{$gene2}) )  . "\t$same\t$bothnucleotide\t" . (length($aln1)) . "\t$similarity\t$similarity_gap\n" ;


    }
    else {
	print "\tNA\tNA\tNA\tNA\tNA\tNA\tNA\n" ;

    }


}
close(IN) ; 
