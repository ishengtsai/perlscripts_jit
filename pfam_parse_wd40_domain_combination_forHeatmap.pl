#!/usr/bin/perl -w
use strict;

my $largest = 0;
my $contig = '';


if (@ARGV != 1) {
    print "$0 pfam30.pergene.list \n" ; 
    exit ;
}

my $file = shift ;
my $faFile = shift ; 

my %fastas = () ; 


open (IN, "$file") or die "can't openfile: $!\n" ;

my %NACHTterms = ();
my %domaintermsTotal = () ; 

my %species = () ; 

my %species_NACHT = () ; 



while (<IN>) {

    chomp;
    my @r = split /\t/, $_ ;
    next unless /PNOK/ ; 
    

    if ( $r[2] =~ /WD40/ ) {

    }
    #elsif (  $r[2] =~ /NACHT/  ) {

    #}
    #elsif ( $r[2] =~ /^C2/i ) {

    #}
    else {
	next ; 
    }
    
    
    my $domainline = $r[2] ;
    my $nachtSeqName = '' ;
    my $nachtSeq = '' ; 
    
    #if ( /(\d+)-(\d+):NACHT/ ) {
#	my $start = $1 - 1 ;
#	my $domainLen = $2 - $1 + 1 ;

#	$species_NACHT{$r[0]}++ ;
#	$nachtSeqName = ">$r[0].$species_NACHT{$r[0]}.$1.$2." ;
#	$nachtSeq = substr ( $fastas{$r[1]}, $start, $domainLen ) ; 
#    }


    
    
    $domainline =~ s/\d+-\d+\://gi ;



    
    my $originaldomainline = $domainline ;
    my $WD40count = 0 ; 
    while ($originaldomainline =~ /WD40/g) { $WD40count++ }


    
    
    if ( $domainline =~ /,WD40/ ) {
	$domainline =~ s/,WD40//gi ;
	$domainline .= ".WD40+" ; 
    }

    if ( $domainline eq 'WD40.WD40+' ) {
        $domainline = "WD40+" ;
    }   
    
    if ( $domainline =~ /,TPR/ ) {
	$domainline =~ s/,TPR_\d+//gi ;
	$domainline .= ".TPR+" ;
    }

    if ( $domainline =~ /,Ank/ ) {
	$domainline =~ s/,Ank_\d+//gi ;
	$domainline .= ".Ank+" ;
    }
    
    #print "$r[0]\t$domainline\n" ; 
    
    $NACHTterms{$domainline}{$r[0]}++ ; 
    $domaintermsTotal{$domainline}++ ; 

    $domainline =~ s/,/./gi ; 
    $nachtSeqName .= "$domainline" ;

    

    print "$r[0]\t$r[1]\t$domainline\n" ; 
    


    
    
}






