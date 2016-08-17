#!/usr/bin/perl -w
use strict;



if (@ARGV != 2) {
	print "$0 coords lastSp34.scaffold.number\n\n" ;
	print "will parse out genes with smaller scaffolds\n" ;
	exit ;
}

my $file = shift @ARGV;
my $lastscaff = shift @ARGV ; 

my $count = 10 ; 

open OUT1, ">", "$file.singlecopy.circos.chr1" or die "ooops\n" ; 
open OUT2, ">", "$file.singlecopy.circos.chr2" or die "ooops\n" ;
open OUT3, ">", "$file.singlecopy.circos.chr3" or die "ooops\n" ;
open OUT4, ">", "$file.singlecopy.circos.chr4" or die "ooops\n" ;
open OUT5, ">", "$file.singlecopy.circos.chr5" or die "ooops\n" ;
open OUTX, ">", "$file.singlecopy.circos.chrX" or die "ooops\n" ;





## read the fastas
open (IN, "$file") or die "oops!\n" ;
while (<IN>) {
	

    chomp ; 
    my @r = split /\s+/, $_ ; 

    if ( $r[1] =~ /Sp34.scaff0*(\d+)/ ) {
	my $scaffnum = $1 ; 

	#print "$scaffnum! $lastscaff\n" ; 

	next unless $scaffnum <= $lastscaff ; 
    }

    if ( $r[4] eq 'CHROMOSOME_I' ) {
	print OUT1 "$r[1] $r[2] " . ($r[2]+1) . " $r[4] $r[5] " . ($r[5]+1) . "\n" ;
	
    }    
    elsif ( $r[4] eq 'CHROMOSOME_II' ) {
        #print OUT2 "segdup$count $r[1] $r[2] " . ($r[2]+1) . " \n" ;
        #print OUT2 "segdup$count $r[4] $r[5] " . ($r[5]+1) . " \n" ;
	print OUT2 "$r[1] $r[2] " . ($r[2]+1) . " $r[4] $r[5] " . ($r[5]+1) . "\n" ;
    }
    elsif ( $r[4] eq 'CHROMOSOME_III' ) {
	print OUT3 "$r[1] $r[2] " . ($r[2]+1) . " $r[4] $r[5] " . ($r[5]+1) . "\n" ;

    }
    elsif ( $r[4] eq 'CHROMOSOME_IV' ) {
        #print OUT4 "segdup$count $r[1] $r[2] " . ($r[2]+1) . " \n" ;
        #print OUT4 "segdup$count $r[4] $r[5] " . ($r[5]+1) . " \n" ;
	print OUT4 "$r[1] $r[2] " . ($r[2]+1) . " $r[4] $r[5] " . ($r[5]+1) . "\n" ;
    }
    elsif ( $r[4] eq 'CHROMOSOME_V' ) {
	print OUT5 "$r[1] $r[2] " . ($r[2]+1) . " $r[4] $r[5] " . ($r[5]+1) . "\n" ;

    }
    elsif ( $r[4] eq 'CHROMOSOME_X' ) {
	print OUTX "$r[1] $r[2] " . ($r[2]+1) . " $r[4] $r[5] " . ($r[5]+1) . "\n" ;
	#print OUTX "segdup$count $r[1] $r[2] " . ($r[2]+1) . " \n" ;
	#print OUTX "segdup$count $r[4] $r[5] " . ($r[5]+1) . " \n" ;
    }


    $count += 10 ; 

}

