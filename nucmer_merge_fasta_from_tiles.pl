#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV != 4) {
	print "$0 fasta listfile gaplen outname\n\n" ;
	exit ;
}

my $filenameA = $ARGV[0];
my $listfile = $ARGV[1] ; 
my $gaplen = $ARGV[2] ; 
my $outname = $ARGV[3] ; 

my %fasta = () ; 

open OUT, ">", "$outname.fa" or die "dasdoiaidoaio\n" ;
open GFF, ">", "$outname.gff" or die "odsopapodoaopd\n" ; 
open LIST, ">", "$outname.list" or die "dalkdkasdlakls\n" ; 
open GAP, ">", "$outname.gaplist" or die "daiosdaoidaodoaisodao\n" ; 
open CIRCOS, ">", "$outname.circos.order" or die "dadalksdjalsdjalk\n" ; 

open (IN, "$filenameA") or die "oops!\n" ;


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


open (IN, "$listfile") or die "oops!\n" ;

my $mergefa ='' ;

my $seqleft = 1 ; 
while (<IN>) {

    chomp; 
    next unless /MAX/ ; 

    my @r = split /\s+/, $_ ; 

    my $seq = $fasta{$r[2]} ; 
    $seq = revcomp($seq) if $r[7] eq '-' ; 

    if ( $seqleft == 1 ) {
	$mergefa .= $seq ; 

	print CIRCOS "$r[2]\;" ; 

	my $seqright = length($mergefa) ; 
	print GFF "unknown\tscaffold\tscaffold\t$seqleft\t$seqright\t0\t$r[7]\t.\tcolor=9\;label=\"$r[2]\"\;\n" ;
	print LIST "$r[2]\t$seqleft\n" ; 
 
	$seqleft = $seqright ; 
    }
    else {
	my $gap = 'N' x $gaplen ; 
	$mergefa = "$mergefa$gap" ; 

	my $seqright = length($mergefa) ;
        print GFF "unknown\tGAP\tGAP\t$seqleft\t$seqright\t0\t$r[7]\t.\tcolor=4\;label=\"GAP\"\;\n"  ;
	print GAP "" . ($seqleft + ($gaplen / 2) ) . "\n" ; 
	$seqleft = $seqright ;

	print CIRCOS "$r[2]\;" ;

	$mergefa .= "$seq" ; 
	$seqright = length($mergefa) ;
	
	print GFF "unknown\tscaffold\tscaffold\t$seqleft\t$seqright\t0\t$r[7]\t.\tcolor=9\;label=\"$r[2]\"\;\n" ;
	print LIST "$r[2]\t$seqleft\n" ; 
	$seqleft = $seqright ;

    }




}
close(IN) ; 

open OUT, ">", "$outname.fa" or die "dasdoiaidoaio\n" ; 
print OUT ">$outname\n$mergefa\n" ; 





sub revcomp {
    my $dna = shift;
    my $revcomp = reverse($dna);

    $revcomp =~ tr/ACGTacgt/TGCAtgca/;

    return $revcomp;
}
