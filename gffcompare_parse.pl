#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV != 1) {
    print "$0 gffcompareLogFile\n\n" ; 
	exit ;
}

my $filenameA = $ARGV[0];


open (IN, "$filenameA") or die "oops!\n" ;

my $transcript = 0 ; 

my %sen = () ;
my %pre = () ;
my %missed = () ;
my %novel = () ;

my $match_intron = 0 ;
my $match_transcript = 0 ;
my $match_loci = 0 ;
my $superloci = 0  ;


while (<IN>) {

    if ( /Query mRNAs :\s+(\d+)/ ) {
	#print "$1\n" ;
	$transcript = $1 ; 
    }
    elsif ( /Super-loci w\/ reference transcripts:\s+(\d+)/ ) {
	$superloci = $1 ; 
    }
    elsif ( /(\S+) level:\s+(\d+\.\d+).+\s+(\d+\.\d+)/ ) {
	#print "$1\t$2\t$3\n" ;
	$sen{$1} = $2 ;
	$pre{$1} = $3 ; 
    }
    elsif ( /Matching intron chains:\s+(\d+)/ ) {
	$match_intron = $1 ; 
    }
    elsif ( /Matching transcripts:\s+(\d+)/ ) {
	$match_transcript = $1 ; 
    }
    elsif ( /Matching loci:\s+(\d+)/ ) {
	$match_loci = $1 ;
    }
    elsif ( /Missed (\S+):\s+(.+)/ ) {
	my $value = $2 ;
	my $type = $1 ;
	$value =~ s/\s+//gi ;
	#print "$type\t$value\n" ;
	$missed{$type} = $value ; 
    }
    elsif ( /Novel (\S+):\s+(.+)/ ) {
	my $value = $2 ;
        my $type = $1 ;
        $value =~ s/\s+//gi ;
	#print "$type\t$value\n"	;
	$novel{$type} = $value	;
    }
      

}
close(IN) ; 

print "$transcript\t$sen{Base}\t$pre{Base}\t" . "$sen{Exon}\t$pre{Exon}\t$missed{exons}\t$novel{exons}\t" .  
    "$sen{Intron}\t$pre{Intron}\t$missed{introns}\t$novel{introns}\t" .
    "$sen{chain}\t$pre{chain}\t$match_intron\t" .
    "$sen{Transcript}\t$pre{Transcript}\t$match_transcript\t" .
    "$sen{Locus}\t$pre{Locus}\t$match_loci\t$missed{loci}\t$novel{loci}\t$superloci\n" ; 
    
    


