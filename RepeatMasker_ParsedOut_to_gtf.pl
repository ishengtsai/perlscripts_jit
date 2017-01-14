#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV != 1) {
    print "$0 ref.fa.cat.out \n" ;
    exit ;
}

my $filenameA = shift @ARGV;
my $out = "$filenameA.gtf" ;

my $offset = 50 ;


open (IN, "$filenameA") or die "oops!\n" ;

open OUT, ">" , "$out" or die "oops out!\n" ;








# skip first three lines
my $tmp = <IN> ;
$tmp = <IN> ;
$tmp = <IN> ;


my $seq_num = 1 ; 

while (<IN>) {

    #print "$_" ; 
    
    next if /Unknown/ ; 
    next if /Simple_repeat/ ;

    s/\//./gi ; 
    s/^\s+// ;
    chomp; 
    my @r = split /\s+/, $_ ; 

    $r[8] =~ s/C/\-/ ; 
    
    #PNOK.scaff0001.C        annotation      exon    2800    3159    .       -       .       gene_id "PNOK_0000100"; transcript_id "PNOK_0000100.1:mRNA"; exon_number "1";

    my $gene = "$r[9].$r[10].$seq_num" ;
    $seq_num++ ; 
    
    print OUT "$r[4]\trepeat\texon\t$r[5]\t$r[6]\t.\t$r[8]\t.\tgene_id \"$gene\"\; transcript_id \"$gene\:mRNA\"\; exon_number \"1\"\;\n"  ;
    
    
}
close(IN) ; 
