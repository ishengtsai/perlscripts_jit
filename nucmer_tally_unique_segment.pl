#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV != 2) {
	print "$0 fa.len.txt coords\n\n" ;
	exit ;
}

my $lenfile = shift ; 
my $filenameA = shift ; 

my %seq_len = () ;
my @seq_order = () ; 


#my @ratti_scaffolds = ( "Sratt_Chr1_000001", "Sratt_Chr2_000001", "Sratt_ChrX_000001", "Sratt_ChrX_000002", "Sratt_ChrX_000003", "Sratt_ChrX_000004", "Sratt_ChrX_000005", "Sratt_ChrX_000006", "Sratt_ChrX_000007", "Sratt_ChrX_000008" ) ;


my @ratti_scaffolds = ( "pathogen_SRAE_Chr1_000001", "pathogen_SRAE_Chr2_000001", "pathogen_SRAE_ChrX_000001", 
"pathogen_SRAE_ChrX_000002",
"pathogen_SRAE_ChrX_000003",
"pathogen_SRAE_ChrX_000004",
"pathogen_SRAE_ChrX_000005",
"pathogen_SRAE_ChrX_000006",
"pathogen_SRAE_ChrX_000007",
"pathogen_SRAE_ChrX_000008",
"pathogen_SRAE_ChrX_000009",
"pathogen_SRAE_ChrX_000010",
  ) ; 



open(IN, "$lenfile") or die "oops!\n" ;

while(<IN>) {
    chomp; 
    if ( /(\S+)\s+(\d+)/) {
	$seq_len{$1} = "$2" ;  
	push(@seq_order, $1) ; 
    }
}
close(IN) ; 


open (IN, "$filenameA") or die "oops!\n" ;

my %seq_match_segment = () ; 
my %seq_match_total = () ; 

while (<IN>) {
    chomp ;
    my @r = split /\s+/, $_ ;

    my $match = 0 ; 

    if ( $r[2] > $r[3] ) {
	$match = $r[2] - $r[3] + 1 ; 
    }
    else {
	$match = $r[3] - $r[2] + 1 ; 
    }

    $seq_match_segment{$r[12]}{$r[11]} += $match ; 
    $seq_match_total{$r[12]}+= $match ;
    
    
}
close(IN); 


print "seq.name\tseq.len\tmatch.total\t@ratti_scaffolds\n" ; 

foreach my $seq (@seq_order) {



    if ( $seq_match_total{$seq} ) {

	print "$seq\t$seq_len{$seq}\t$seq_match_total{$seq}\t" ; 
	
	
	foreach my $rattiseq (  @ratti_scaffolds  ) {
	    
	    if ( $seq_match_segment{$seq}{$rattiseq} ) {
		print "$seq_match_segment{$seq}{$rattiseq}\t" ; 
	    }
	    else {
		print "0\t" ; 
	    }
	    
	}
	print "\n" ; 
	
    }
    else {
	print "$seq\t$seq_len{$seq}\t0\t0\t0\t0\t0\t0\t0\t0\t0\t0\t0\t0\t0\n" ;  
    }




    #last ; 
}
