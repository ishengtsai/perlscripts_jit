#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';




if (@ARGV != 3) {
    print "$0 Phellinus.varscan.variants.hetero.vcf.maf strain.list ref.window\n" ;
	exit ;
}

my $filenameA = $ARGV[0];
my $filenameB = $ARGV[1] ; 
my $bedfile = $ARGV[2] ; 

my @strain_list = () ; 

open (IN, "$filenameB") or die "oops!\n" ;
while (<IN>) {
    chomp ;
    push(@strain_list, $_) ; 
}
close(IN) ; 
    

foreach my $strain ( @strain_list ) {

open (IN, "$filenameA") or die "oops!\n" ;
open OUT, ">", "$strain.bed" or die "can't open file!\n" ; 

 while (<IN>) {
     
     chomp; 
     my @r = split /\s+/, $_ ; 
     next unless $r[2] eq $strain ;
     print OUT "$r[3]\t$r[4]\t$r[4]\n" ; 
     
     
 }
close(IN) ; 
close(OUT) ;

system("bedtools coverage -a $bedfile -b $strain.bed > $strain.coverage.bed") ; 
print " $strain.coverage.bed done!\n" ;

#last ; 

}
