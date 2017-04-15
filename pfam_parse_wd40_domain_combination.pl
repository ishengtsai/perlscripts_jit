#!/usr/bin/perl -w
use strict;

my $largest = 0;
my $contig = '';


if (@ARGV != 2) {
    print "$0 pfam30.pergene.list merged.fasta \n" ; 
    exit ;
}

my $file = shift ;
my $faFile = shift ; 

my %fastas = () ; 

open (IN, "$faFile") or die "oops!\n" ;

my $read_name = '' ;
my $read_seq = '' ;

while (<IN>) {
    if (/^>(\S+)/) {
	$read_name = $1 ;
	$read_seq = "" ;

	while (<IN>) {
	    if (/^>(\S+)/) {
		$fastas{$read_name} = $read_seq ; 
		#print "$read_name\t" . length($read_seq) . "\n" ;

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
#print "$read_name\t" . length($read_seq) . "\n" ;
$fastas{$read_name} = $read_seq ;


open OUT, ">", "$file.WD40.combination" or die "oooop!\n" ;
open OUT2, ">", "$file.NACHT.domain.fasta" or die "oooop!\n" ;
open OUT3, ">", "$file.NACHT.domain.fasta.info" or die "dsaodpsaod\n" ; 
open (IN, "$file") or die "can't openfile: $!\n" ;

my %NACHTterms = ();
my %domaintermsTotal = () ; 

my %species = () ; 

my %species_NACHT = () ; 



while (<IN>) {

    chomp;
    my @r = split /\t/, $_ ;
    $species{$r[0]}++ ; 


    if (  $r[2] =~ /NACHT/  ) {

    }
    elsif ( $r[2] =~ /WD40/ ) {

    }
    elsif ( $r[2] =~ /^C2/i ) {

    }
    else {
	next ; 
    }
    
    
    my $domainline = $r[2] ;
    my $nachtSeqName = '' ;
    my $nachtSeq = '' ; 
    
    if ( /(\d+)-(\d+):NACHT/ ) {
	my $start = $1 - 1 ;
	my $domainLen = $2 - $1 + 1 ;

	$species_NACHT{$r[0]}++ ;
	$nachtSeqName = ">$r[0].$species_NACHT{$r[0]}.$1.$2." ;
	$nachtSeq = substr ( $fastas{$r[1]}, $start, $domainLen ) ; 
    }


    
    
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

    if ( $nachtSeqName =~ /NACHT/ ) {
	print OUT3 "$nachtSeqName\t$r[0]\t$domainline\t$originaldomainline\n" ; 
	print OUT2 "$nachtSeqName\n$nachtSeq\n" ;
	print "$r[0]\t$domainline\t$WD40count\n" ; 
    }


    
    
}

my @speciesNames = keys %species ;



print OUT "domain\t@speciesNames\n" ; 

for my $domain (sort keys %NACHTterms ) {
    #print "$domain\n" ; 
    
    # domain combination more than 1 species
    if ( keys % {  $NACHTterms{$domain} } > 1 && $domaintermsTotal{$domain} >= 10 ) {
	print OUT "$domain" ;

	foreach my $speciesName ( @speciesNames ) {
	    if ( $NACHTterms{$domain}{$speciesName} ) {
		print OUT "\t$NACHTterms{$domain}{$speciesName}" ; 
	    }
	    else {
		print OUT "\t0" ; 
	    }
	}

	print OUT "\n" ; 
    }

}



print "all done! $file.NACHT.combination and $file.NACHT.domain.fasta produced\n" ; 
