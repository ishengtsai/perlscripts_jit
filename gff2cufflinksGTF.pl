#!/usr/bin/perl -w
use strict;



if (@ARGV != 1) {
    print "$0 gff \n" ; 

	exit ;
}

my $file = shift @ARGV;


## read the fastas
open (IN, "$file") or die "oops!\n" ;

while (<IN>) {

    chomp; 
    my @r = split /\s+/, $_ ; 

    if ( $r[2] eq 'exon' && $r[8] =~ /ID=\S+:exon:(\d+)\;Parent=(\S+:mRNA)\;/ ) {
	my $gene = $2 ; 
	my $mRNA = $2 ;
	my $exon = $1 ;

	$gene =~ s/\.\d+:mRNA//gi ; 



	print "$r[0]\t$r[1]\t$r[2]\t$r[3]\t$r[4]\t$r[5]\t$r[6]\t$r[7]\tgene_id \"$gene\" transcript_id \"$mRNA\" exon_number \"$exon\"\n" ; 
    }


}
close(IN) ; 
