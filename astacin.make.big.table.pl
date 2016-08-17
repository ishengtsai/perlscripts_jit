#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV != 5) {
    print "$0 list exon.list signalpeptidefile domain.fullcombination.file fpkm.easytable\n" ;  
	exit ;
}

my $listfile = shift ; 
my $exonfile = shift ;
my $signalpeptidefile = shift ; 
my $domainfile = shift ; 
my $fpkmfile = shift ; 


my @listorder = () ; 
my %list = (); 
my %listcluster = () ; 

open (IN, "$listfile") or die "oops!\n" ;
while (<IN>) {
    chomp; 
    my @r = split /\s+/, $_ ; 
    push(@listorder, $r[0] ) ;
    $list{$_}++ ; 
    $listcluster{$r[0]} = "$r[1]" ; 
}
close(IN) ; 

my %exons = ();  

open (IN, "$exonfile") or die "diaodsiad\n" ; 
while (<IN>) {
    chomp; 
    next if /^\#/ ; 
    my @r = split /\s+/, $_  ; 
    $exons{$r[0]} = $r[1] ; 
}
close(IN); 

my %signalP = () ; 

open (IN, "$signalpeptidefile") or die "diaodsiaadsdsad\n" ;
while (<IN>) {
    chomp; 
    next if /^\#/ ;
    $signalP{$_}++; 
}
close(IN) ; 


my %domains = () ; 

open (IN, "$domainfile") or die "daidioaiodsaoidioa\n" ; 

while (<IN>) {
    chomp; 
    my @r = split /\s+/, $_ ; 
    $domains{$r[0]} = $r[1] ; 
}
close(IN) ; 


my %fpkm = () ; 

open(IN, "$fpkmfile") or die "daidoaosidaiodoiiaodio\n" ; 
while (<IN>) {

    chomp; 
    next if /^tracking/ ; 

    my @r = split /\s+/, $_ ; 
    my $name = shift @r ; 

    #print "@r" ;

    $fpkm{$name} = "@r"  ; 


}
close(IN) ; 


for my $gene ( @listorder ) {
    
    print "$gene\t$listcluster{$gene}\t" ; 

    if ( $exons{$gene} ) {
	print "$exons{$gene}\t" ; 
    }
    else {
	print "wierd!\t" ; 
    }

    if ( $signalP{$gene} ) {
	print "Y\t" ; 
    }
    else {
	print "N\t" ; 
    }

    if ( $domains{$gene} ) {
	print "$domains{$gene}\t" ; 
    }
    else {
	print "wierd!\t" ; 
    }

    if ( $fpkm{$gene} ) {
	print "$fpkm{$gene}" ; 
    }
    else {
	print "NA " x 24 ; 

    }

    print "\n" ; 

}

