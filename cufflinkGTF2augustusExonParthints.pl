#!/usr/bin/perl -w
use strict;



if (@ARGV != 1) {
    print "$0 merged.gtf \n" ; 
	exit ;
}

my $filenameA = shift @ARGV;
my $out = "$filenameA.augustusexonpart.gff" ; 


open (IN, "$filenameA") or die "oops!\n" ;
open OUT, ">" , "$out" or die "oops out!\n" ;




#contig03182     Cufflinks       exon    6       233     .       -       .       gene_id "XLOC_000131"; transcript_id "TCONS_00000132"; exon_number "1"; oId "CUFF.147.2"; tss_id "TSS131";
#contig03182     Cufflinks       exon    503     611     .       -       .       gene_id "XLOC_000131"; transcript_id "TCONS_00000132"; exon_number "2"; oId "CUFF.147.2"; tss_id "TSS131";
#contig03182     Cufflinks       exon    681     771     .       -       .       gene_id "XLOC_000131"; transcript_id "TCONS_00000132"; exon_number "3"; oId "CUFF.147.2"; tss_id "TSS131";
#contig03182     Cufflinks       exon    854     1000    .       -       .       gene_id "XLOC_000131"; transcript_id "TCONS_00000132"; exon_number "4"; oId "CUFF.147.2"; tss_id "TSS131";
#contig03182     Cufflinks       exon    1090    1273    .       -       .       gene_id "XLOC_000131"; transcript_id "TCONS_00000132"; exon_number "5"; oId "CUFF.147.2"; tss_id "TSS131";
#contig03182     Cufflinks       exon    6       233     .       -       .       gene_id "XLOC_000131"; transcript_id "TCONS_00000131"; exon_number "1"; oId "CUFF.147.1"; tss_id "TSS131";
#contig03182     Cufflinks       exon    503     587     .       -       .       gene_id "XLOC_000131"; transcript_id "TCONS_00000131"; exon_number "2"; oId "CUFF.147.1"; tss_id "TSS131";
#contig03182     Cufflinks       exon    681     771     .       -       .       gene_id "XLOC_000131"; transcript_id "TCONS_00000131"; exon_number "3"; oId "CUFF.147.1"; tss_id "TSS131";
#contig03182     Cufflinks       exon    854     1000    .       -       .       gene_id "XLOC_000131"; transcript_id "TCONS_00000131"; exon_number "4"; oId "CUFF.147.1"; tss_id "TSS131";
#contig03182     Cufflinks       exon    1090    1273    .       -       .       gene_id "XLOC_000131"; transcript_id "TCONS_00000131"; exon_number "5"; oId "CUFF.147.1"; tss_id "TSS131";


my $previous_id = '' ; 
my $gene_id = '' ; 

my %genefound = () ; 

while (<IN>) {


    chomp ;
    my @line = split /\s+/ , $_ ;
    $line[11] =~ s/"//g ;  
    $line[11] =~ s/\;//g ;
    $line[13] =~ s/"//g ;
    $line[13] =~ s/\;//g ;
    
    print OUT "$line[0]\tb2h\tep\t$line[3]\t$line[4]\t$line[5]\t$line[6]\t$line[7]\tgrp=$line[11]\;pri=4\;src=W\n" ; 
    

}
close(IN) ; 

print "done! $out successfully produced \n" ; 
