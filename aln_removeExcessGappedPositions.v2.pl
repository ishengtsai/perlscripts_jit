#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV != 2) {
    print "$0 fasta amino_acid_cov\n" ;
	exit ;
}

my $filenameA = $ARGV[0];
my $cov = $ARGV[1] ;

my @seq_name = () ;
my @seq_seq = () ;


open (IN, "$filenameA") or die "oops!\n" ;

my $read_name = '' ;
my $read_seq = '' ;

while (<IN>) {
    if (/^>(\S+)/) {
	
	$read_name = $1 ;
	$read_seq = "" ;
	
	while (<IN>) {
	    
	    if (/^>(\S+)/) {
		
		#print "$read_name\t" . length($read_seq) . "\n" ;
		
		push (@seq_seq , $read_seq) ;
		push (@seq_name , $read_name) ;
		
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

if ( $read_seq && $read_seq ne $seq_seq[$#seq_seq] ) {
    push (@seq_seq , $read_seq) ;
    push (@seq_name , $read_name) ;
}


#print "$read_name\t" . length($read_seq) . "\n" ;
my $seq_count = length($read_seq)  ;
my $num_seqs = @seq_name ;



my @position_kept = () ; 

open ALN, ">", "$filenameA.excessGremoved.aln" or die "oooops\n" ; 
open CONS, ">", "$filenameA.cons.aln" or die "ooooooops\n" ; 
print CONS ">cons\n" ; 

for (my $i = 0 ; $i < $seq_count ; $i++ ) {


    my $aa_count = 0 ; 

    my $max_cov = 0 ; 
    my $aminoacid = '' ; 
    my %aminoacidcov = () ; 

    for (my $j = 0 ; $j < @seq_seq ; $j++) {
	my $base = substr($seq_seq[$j], $i, 1) ; 

	if ( $base ne '-' ) {
	    $aa_count++ ; 
	    $aminoacidcov{$base}++ ; 
	}
    }

    if ( $aa_count >= $cov ) {

	push(@position_kept, $i) ; 

        for my $base ( sort keys %aminoacidcov ) {

	    if ( $aminoacidcov{$base} >= $max_cov ) {
		$aminoacid = $base ; 
		$max_cov = $aminoacidcov{$base} ; 
	    }

	}	

	print CONS "$aminoacid" ; 

    }


    #print "pos $i: $aa_count\n" ; 
}

close(CONS) ; 



for (my $j = 0 ; $j < @seq_seq ; $j++) {

    print ALN ">$seq_name[$j]\n" ; 

    for (my $i = 0 ; $i < @position_kept ; $i++ ) {
	my $pos = $position_kept[$i] ; 
	
	my $base = substr($seq_seq[$j],$pos, 1) ;
	print ALN "$base" ; 
    }
    print ALN "\n" ; 


}

close(ALN) ; 

print "$filenameA.excessGremoved.aln produced!\n" ;
print "$filenameA.cons.aln produced \n" ; 




