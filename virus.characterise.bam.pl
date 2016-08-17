#! /usr/bin/perl -w
#
#
# Copyright (C) 2009 by Pathogene Group, Sanger Center
#
# Author: JIT
# Description:
#               a script that map the Solexa reads back to the reference/contigs
#               and parition them based on either ends of the contigs
#
#
#




use strict;
use warnings;

# to print
local $" = "\t";


my $PI = `echo $$` ; chomp($PI) ;


#"


if (@ARGV != 2 ) {
    print "$0 schisto.sam virus.sam \n" ;
    exit;
}



my $bamraw = shift;
my $bam = shift ; 

print '------------------------------------------------' ;
print "\nauthor: JIT\n" ;
print "bam raw is: $bamraw\n" ; 
print "bam file is: $bam\n" ;
print '------------------------------------------------' . "\n\n";

my %reads = (); 

my %bothgood = () ; 
my %mapped = () ; 


open( IN, "$bamraw") or die "doapdopsa\n" ; 
while (<IN>) {
    chomp ;
    my $read1 = $_ ; 
    my @pair1 = split /\s+/, $_ ;

    my $read2 = <IN> ;
    chomp($read2) ; 
    my @pair2 = split /\s+/, $read2 ; 
    
    if ( $pair1[0] ne $pair2[0] ) {
	print "weird!!!! $pair1[0] and $pair2[0]\n" ; 
	exit ; 
    }

    my $map1 = 0 ; 
    my $map2 = 0 ; 

    while ( $pair1[5] =~ /(\d+)M/ ) {
	my $mapped = $1 ; 
	$map1 += $mapped ; 
	$pair1[5] =~ s/($mapped)M// ; 
    }
    while ( $pair2[5] =~ /(\d+)M/ ) {
	my $mapped = $1;
	$map2 += $mapped ;
	$pair2[5] =~ s/($mapped)M// ;
    }

    #$map1 = 100 if $pair1[5] eq '*' ; 
    #$map2 = 100 if $pair2[5] eq '*' ;

    #$map1 = 100 if $map1 >= 50 ;
    #$map2 = 100 if $map2 >= 50 ;    

    #print "$map1\t$map2\n" ; 

    # store softclipping score
    if ( $pair1[1] & 64) {
	#print "Reverse\n";
	$mapped{$pair1[0]}{'R'} = $map1 ; 
	$mapped{$pair1[0]}{'F'} = $map2 ;

	$reads{$pair1[0]}{'R'} = $read1 ; 
	$reads{$pair1[0]}{'F'} = $read2 ;
    }
    else {
	#print "Forward\n";
	$mapped{$pair1[0]}{'F'} = $map1 ;
        $mapped{$pair1[0]}{'R'} = $map2 ;

	$reads{$pair1[0]}{'F'} = $read1;
	$reads{$pair1[0]}{'R'} = $read2 ;

    }


}
close(IN) ; 



open( IN, "$bam" ) or die "Cannot open $bam\n";
print "Parsing out reads now...\n" ;

open OUT, ">", "$bamraw.final.filtered.reads" or die "daiodisoaid\n" ; 

my $total_reads = 0 ;
my $filtered_reads = 0 ; 

my %possible_pairs = () ; 

while (<IN>) {

    chomp ;
    my @r = split /\s+/, $_ ;


    my $map = 0 ;
    my $mappedinSchisto = 0 ; 
    my $mappedMateInSchisto = 0 ; 
    my $orientation ; 
    my $bothclipped = 0 ; 
    my $original_score = $r[5] ; 


    while ( $r[5] =~ /(\d+)M/ ) {
        my $mapped = $1 ;
        $map += $mapped ;
        $r[5] =~ s/($mapped)M// ;
    }
    $r[5] = $original_score ;


    if ($r[1] & 64) {
	$mappedinSchisto = $mapped{$r[0]}{'R'} ; 
	$mappedMateInSchisto = $mapped{$r[0]}{'F'} ;
	$orientation = 'R' ; 
    }
    else {
	$mappedinSchisto = $mapped{$r[0]}{'F'} ;
	$mappedMateInSchisto = $mapped{$r[0]}{'R'} ;
	$orientation = 'F' ;
    }
    
    
#    if ( $r[5] =~ /^\d+S.+\d+S$/ ) {
	# excluded these reads...
	

#	if ( $r[5] =~ /^\d+S(\d+)M\d+S$/ ) {
	    #print "here!\n" ; 
#	    if ( $1 >= 50 ) {
		#print "aha! $refclipping $1 $_\n" ; 
#	    }
#	    else {
#		next ; 
#	    }
#	}
#	else {
#	    next ; 
#	}

 #   }

    # allow 10bp overlap..
    if ( $map <= ( $mappedinSchisto - 10 )  ) {
    	next ; 
    }
    
    if ( $map >= 30  && $mappedMateInSchisto >= 30 ) {
	#unless ( $possible_pairs{$r[0]} ) {
	#    print OUT "\n" ; 
	#}
	
	
	#print "$_\t$orientation\t$map\t$refclipping\t$reads{$r[0]}{$orientation}\n" ;
	$filtered_reads++ ; 
	
	my @ref = split /\s+/, $reads{$r[0]}{$orientation} ; 
	
	my $reverseori ; 
	$reverseori = 'R' if $orientation eq 'F' ; 
	$reverseori = 'F' if $orientation eq 'R' ;
	my @refmate =  split /\s+/, $reads{$r[0]}{$reverseori} ;
	
	#modify output
	$orientation = 'S' if $orientation eq 'R' ; 
	
	print OUT "$map\t$mappedinSchisto\t$mappedMateInSchisto\t" ; 
	if ( $mappedinSchisto == 0 ) {
	    print OUT "SOLELY_VIRUS\t" ; 
	}
	else {
	    print OUT "OTHERS\t" ; 
	}

	if ( $r[9] eq $ref[9] ) {
	    print OUT "$r[0]\t$orientation\t$r[5]\t$ref[5]\t" ; 
	}
	else {
	    
	    #print "$r[0]\t$orientation\t$r[5]\tREVERSE\t$ref[5]\t"; 
	    my $cigarR = reversecigar($ref[5]) ; 	    
	    print OUT "$r[0]\t$orientation\t$r[5]\t$cigarR\t";
	    
	}
	
	print OUT "HIVitself: $r[1]\t$r[3]\t$r[4]\t$r[5]\tReadItself: $ref[1]\t$ref[2]\t$ref[3]\t$ref[4]\t$ref[5]\tMate: $refmate[1]\t$refmate[2]\t$refmate[3]\t$refmate[4]\t$refmate[5]\n" ; 
	$possible_pairs{$r[0]}++ ; 
	
    }



    $total_reads++ ; 
}
close(IN) ;


print "Total reads: $total_reads\n" ; 
print "Filtered reads: $filtered_reads\n" ; 


sub reversecigar {
    my $cigar = shift ; 
    my $cigarR = '' ; 

    if ( $cigar eq '*' ) {
	return $cigar ; 
    }

    while ( $cigar =~ /(\d+\D$)/ ) {
	my $block = $1 ; 
	$cigarR .= $block ; 
	$cigar =~ s/$block$// ; 
    }

    return $cigarR ; 
}
