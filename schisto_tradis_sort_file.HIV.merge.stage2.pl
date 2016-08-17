#!/usr/bin/perl -w
use strict;



if (@ARGV != 2) {
    print "$0 hiv.sam schisto.hiv.merge.sam \n" ; 


	exit ;
}
my $hivfile = shift @ARGV ; 
my $schistofile = shift @ARGV ; 

my $total = 0 ; 
my $unmapped = 0 ; 
my $duplicates = 0 ; 
my $good = 0 ; 
my $others = 0 ; 
my $overhang = 0 ; 


my %virus_mapping = () ; 

open ( VIRUS, "$hivfile") or die "daodpoadpadpo\n" ; 
while (<VIRUS>) {
    next if /\#/ ;
    next if /\@/ ;
    my @READ = split /\s+/, $_ ;

    if ( $READ[1] == 0 ) {
	$virus_mapping{$READ[0]} = "$READ[3]" ; 
    }


}
close(VIRUS) ; 


my $filtered = 0 ;
my $overhangthreeEnd = 0 ; 

open (SCHISTO, "$schistofile") or die "Daosdapda\n" ; 
open DIST, ">", "$schistofile.overhang.distribution" or die "dasoidadiao\n" ; 
open OUT, ">", "$schistofile.filtered.sam" or die "daodpadoa\n" ; 
open OVERHANGFA, ">", "$schistofile.overhang.5end.fa" or die "daodpaodops\n" ; 
open OVERHANGFA2, ">", "$schistofile.overhang.3end.fa" or die "daodpaodops\n" ;
open GFF, ">", "$schistofile.integration.gff" or die "daosdpoaodapo\n" ; 


while (<SCHISTO>) {
    next if /^\#/ ; 
    next if /^\@/ ; 

    chomp ; 
    my @READ = split /\s+/, $_ ; 
    $total++ ; 



    if ( $READ[4] <= 30 ) {
	next ; 
    } 

    #remove duplicate
    if ( $READ[1] > 1000 ) {
	$duplicates++ ; 
	next ; 
    }



    local $" = "\t";
    #print "@READ\n" ;
    $READ[5] =~ modifycigar($READ[5]) ; 
 
    my $map = $1 ; 
    
    if ( $READ[5] =~ /(\d+)M(\d+)S$/ ) {
	$overhangthreeEnd++ ; 

	if ( $2 > 30 ) {
	    my $overhanglen = $1 ;
	    my $subfa = substr( $READ[9], $overhanglen) ;
	    print OVERHANGFA2 ">$overhangthreeEnd\n$subfa\n" ;
	}
    }


    if ( $READ[5] =~ /^(\d+)S(\d+)M/ ) {
	$map = $2 ; 
	next if $map < 30 ; 

	if ( $1 < 10 ) {
	    $good++ ; 
	    print DIST "$1\t$2\n" ;
	}
	else {
	    print DIST "$1\t$2\n" ; 
	    $overhang++ ; 

	    if ( $1 > 30 ) {
		my $overhanglen = $1 ; 
		#print "@READ\n" ;
		my $subfa = substr( $READ[9], 0, $overhanglen) ; 
		print OVERHANGFA ">$overhang\n$subfa\n" ; 
	    }

	}
    }
    elsif ( $READ[5] =~ /^(\d+)M/ ) {
	$map = $1 ;
	next if $map < 30 ; 

	$good++ ; 
    }
    else {
	$others++ ; 
    }

    #if ( $READ[0] eq 'MS7_14076:0::1:1101:10669:5934:' ) {
    #	print "yes!\n" ; 
    #}
    
    my $strand = '+' ; 
    if ( $READ[1] == 16 ) {
	$strand = '-' ; 
    }

    if ( $virus_mapping{$READ[0]} ) {

	if ( $virus_mapping{$READ[0]} >= 498 && $virus_mapping{$READ[0]} <= 698 ) {
	    print OUT "@READ\n" ; 
	    print GFF "$READ[2]\tradis\tintegration\t$READ[3]\t$READ[3]\t.\t$strand\t.\tNoteHere\n" ; 
	    $filtered++ ; 
	}
	elsif ( $virus_mapping{$READ[0]} >= 9573 && $virus_mapping{$READ[0]} <= 9773 ) {
	    print OUT "@READ\n" ; 
	    print GFF "$READ[2]\tradis\tintegration\t$READ[3]\t$READ[3]\t.\t$strand\t.\tNoteHere\n" ;
            $filtered++;
	}

	
    }




}
close(VIRUS) ; 


print "Total: $total\n" ; 
print "Good: $good\n" ; 
print "Overhang: $overhang\n" ; 
print "Final filtered $filtered\n" ; 
print "Others: $others\n" ; 



sub modifycigar {

    my $cigar = shift ; 
    $cigar =~ s/\d+D//gi ; 
    $cigar =~ s/I/M/gi ; 

    if ( $cigar =~ /^\d+M\d+S$/ ) {
	return $cigar ; 
    }

    while ( $cigar =~ /(\d+)M(\d+)M/ ) {
	my $total = $1 + $2 ; 
	my $replace = $total . "M" ; 
	$cigar =~ s/\d+M\d+M/$replace/ ; 
    }
    while ( $cigar =~ /(\d+)S(\d+)M/ ) {
	my $total = $1 + $2 ; 
	my $replace = $total . "M" ; 
	$cigar =~ s/\d+S\d+M/$replace/ ; 
    }

    if ( $cigar =~ /^\d+M\d+S/ || $cigar=~ /^\d+M$/ ) {

    }
    else {
	print "erm!!! $cigar\n" ; 
	exit ; 
    }

    return $cigar ; 
}



