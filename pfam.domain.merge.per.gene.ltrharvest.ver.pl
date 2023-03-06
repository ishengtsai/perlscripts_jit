#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV != 1) {
    print "$0 file \n" ; 
    exit ;
}

my $list = $ARGV[0] ; 

my %genes = () ; 


my %found_domains = () ; 

open (IN, "$list") or die "oooops\n" ; 

while (<IN>) {
    next if /^\#/ ; 
    next unless /^\S+/ ; 

    chomp ; 
    my @r = split /\s+/, $_ ; 

    if ( $r[0] =~ /(^.+)_(\d+)\./ ) {
	my $seq = $1 ;
	my $strand = '+' ;
	$strand = '-' if $2 > 3;
	$r[0] = "$seq\t$strand" ; 
    }
    
    #$genes{$r[0]}{$r[3]} = "$r[4]:$r[6]" ;
    $genes{$r[0]}{$r[3]} = "$r[6]" ;
    $found_domains{$r[6]}++ ; 
}
close(IN) ; 


for my $gene (sort keys %genes )  {
    #print "$gene\t" ; 
    
    my $count = 0 ;
    
    my $domaincombined = '' ;
    
    for my $domainstart ( sort {$a<=>$b} keys % { $genes{$gene} } ) {
	if ( $count == 0 ) {
	    #print "$genes{$gene}{$domainstart}" ;
	    $domaincombined = "$genes{$gene}{$domainstart}" ; 
	}
	else {
	    #print ",$genes{$gene}{$domainstart}" ;
	    $domaincombined .= ",$genes{$gene}{$domainstart}" ;
	}

	$count++ ; 
    }

    my $presencerepeat = 0 ;
    $presencerepeat = 1 if $domaincombined =~ /rt/ ;
    $presencerepeat = 1 if $domaincombined =~ /gag/ ;
    $presencerepeat = 1 if $domaincombined =~ /Retrotran/ ;
    $presencerepeat = 1 if $domaincombined =~ /rve/ ;
    $presencerepeat = 1 if $domaincombined =~ /RVP/ ;
    $presencerepeat = 1 if $domaincombined =~ /RVT/ ;
    $presencerepeat = 1 if $domaincombined =~ /gag_pre-integrs/ ; 

    if ( $presencerepeat == 1) {
	if ( $gene =~ /(^\S+)\.(\d+)-(\d+)\t([-+])/ ) {
	    print "$1\tLTRharvest.checked\tLTR_retrotransposon\t" . ($2+1) . "\t$3\t.\t$4\t.\t$domaincombined\n" ; 
	}
	

    }
    
    #print "\n" ; 
}



for my $domain (sort keys %found_domains ) {
    print "\#\t$domain\t$found_domains{$domain}\n" ; 
}

