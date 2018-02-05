#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV != 2) {
    print "$0 fasta renamed.file\n" ;
	exit ;
}

my $filenameA = $ARGV[0];
my $list = $ARGV[1] ; 

my %seqs = () ;
my %change = () ; 

open (IN, "$list") or die "oooooooooops\n" ; 
while (<IN>) {
    chomp; 

    if ( /(^\S+)\s+(\S+)/ ) {
	$change{$1} = "$2" ; 
    }

}



open (IN, "$filenameA") or die "oops!\n" ;
open OUT , ">","$filenameA.renamed.fa"or die "oooops\n" ;

	my $read_name = '' ;
	my $read_seq = '' ;

while (<IN>) {
    if (/^>(\S+)/) {
	$read_name = "$1" ;
	$read_seq = "" ;
	
	while (<IN>) {
	    
		    if (/^>(\S+)/) {
			
			$seqs{$read_name} = $read_seq ;
			
			$read_name = "$1" ;
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

$seqs{$read_name} =$read_seq ;

my $count = 1 ;


for my $seq_name (sort keys %seqs ) {
    
    my $seq_final_name = '' ;

    if ( $change{$seq_name} ) {
	$seq_final_name = "$change{$seq_name}" ;
    }
    elsif ( $seq_name =~ /Cluster/ ) {
	$seq_final_name = "$seq_name#Unknown" ;
    }
    elsif ( $seq_name =~ /^LINE\./) {
	$seq_final_name = "LINE.$count\#LINE" ;
    }
    elsif ( $seq_name =~ /^DDE/ ) {
	$seq_final_name= "DDE.$count\#DNA" ;
    }
    elsif ( $seq_name =~ /^MuDR/) {
	$seq_final_name= "MuDR.$count\#DNA" ;
    }
    elsif ( $seq_name =~ /^cacta/) {
	$seq_final_name= "cacta.$count\#DNA" ;
    }
    elsif ( $seq_name =~ /^P_element/) {
	$seq_final_name= "Pele.$count\#DNA" ;
    }
    elsif ( $seq_name =~ /^gypsy/) {
	$seq_final_name= "gypsy.$count\#LTR" ;
    }
    elsif ( $seq_name =~ /^hAT/) {
	$seq_final_name= "hAT.$count\#DNA" ;
    }
    elsif ( $seq_name =~ /^helitron/) {
	$seq_final_name= "heli.$count\#DNA" ;
    }
    elsif ( $seq_name =~ /^ISC1316/) {
	$seq_final_name= "ISC1316.$count\#DNA" ;
    }
    elsif ( $seq_name =~ /^ltr/ ) {
	$seq_final_name= "ltr.$count\#LTR" ;
    }
    elsif ( $seq_name =~ /^mariner/ ) {
        $seq_final_name= "mariner.$count\#DNA" ;
    }
    elsif ( $seq_name =~ /^scaffold/ ) {
        $seq_final_name= "ltr.$count\#LTR" ;
    }
    elsif ( $seq_name =~ /^TY1/ ) {
        $seq_final_name= "ty1.$count\#LTR" ;
    }
    elsif ( $seq_name =~ /^Crypton/ ) {
	$seq_final_name= "crypton\#DNA" ; 
    }
    elsif ( $seq_name =~ /^piggybac/ ) {
	$seq_final_name= "piggybac.$count\#DNA" ;
    }
    else {
	print "ooooops! $seq_name remained the same\n" ;
	$seq_final_name= $seq_name ;
    }


    print "$seq_final_name\t$seq_name\n" ;
    $count++ ;



    print OUT ">$seq_final_name\n$seqs{$seq_name}\n" ;




}
