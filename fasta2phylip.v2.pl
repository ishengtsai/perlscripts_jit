#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV != 1) {
    print "$0 fasta \n" ; 
    exit ;
}


my $filenameA = $ARGV[0] ; 
#my $treefile = $ARGV[1] ; 

my %fasta = () ; 
my $fasta_len = 0 ; 

#my $treecontent ;

#open (IN, "$treefile") or die "daodspadosapd\n" ;
#while (<IN>) {
#    $treecontent .= $_ ; 
#}
#close(IN) ; 

open (IN, "$filenameA") or die "oops!\n" ;

	my $read_name = '' ;
	my $read_seq = '' ;

	while (<IN>) {
	    if (/^>(\S+)/) {
		$read_name = $1 ;
		$read_seq = "" ;
		
		while (<IN>) {
		    
		    if (/^>(\S+)/) {
			$fasta_len = length($read_seq) ; 
			$fasta{$read_name} = $read_seq ; 
			
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

$fasta{$read_name} = $read_seq ;
#print "$read_name\t" . length($read_seq) . "\n" ;

open OUT, ">", "$filenameA.phylip" or die "ooops\n" ; 

open OUT1, ">", "$filenameA.1.phylip" or die "ooops\n" ;
open OUT2, ">", "$filenameA.2.phylip" or die "ooops\n" ;
open OUT3, ">", "$filenameA.3.phylip" or die "ooops\n" ;


my $numseq = keys %fasta;

$fasta_len = $fasta_len/3 ; 

print "print 1st base\n" ; 
print OUT "$numseq $fasta_len\n" ;
print OUT1 "$numseq $fasta_len\n" ;
print OUT2 "$numseq $fasta_len\n" ;
print OUT3 "$numseq $fasta_len\n" ;


foreach my $seqname (sort keys %fasta ) {    
    my $seqnamelen = length($seqname) ; 
    my $newseqname = $seqname ; 
    print OUT "$newseqname" . "  " ;
    print OUT1 "$newseqname" . "  " ;
    
    my $seq_orig = $fasta{$seqname} ;

    # print first base
    my @arr = split //, $seq_orig;

    for (my $i = 0 ; $i < @arr ; $i += 3 ) {
	print OUT "$arr[$i]" ;
	print OUT1 "$arr[$i]" ;
    }
    print OUT "\n" ; 
    print OUT1 "\n" ;    
}



print "print second base\n" ; 
print OUT "$numseq $fasta_len\n" ;


foreach my $seqname (sort keys %fasta ) {
    my $seqnamelen = length($seqname) ;
    my $newseqname = $seqname ;
    print OUT "$newseqname" . "  " ;
    print OUT2 "$newseqname" . "  " ;
    
    my $seq_orig = $fasta{$seqname} ;

    # print first base
    my @arr = split //, $seq_orig;

    for (my $i = 1 ; $i < @arr ; $i += 3 ) {
	print OUT "$arr[$i]" ;
	print OUT2 "$arr[$i]" ;
    }
    print OUT "\n" ;
    print OUT2 "\n" ;
}

print "print third base..\n" ; 

print OUT "$numseq $fasta_len\n" ;
foreach my $seqname (sort keys %fasta ) {
    my $seqnamelen = length($seqname) ;
    my $newseqname = $seqname ;
    print OUT "$newseqname" . "  " ;
    print OUT3 "$newseqname" . "  " ;

    my $seq_orig = $fasta{$seqname} ;

    # print first base
    my @arr = split //, $seq_orig;

    for (my $i = 2 ; $i < @arr ; $i += 3 ) {
	print OUT "$arr[$i]" ;
	print OUT3 "$arr[$i]" ;
    }
    print OUT "\n" ;
    print OUT3 "\n" ;
}






print "all done! $filenameA.phylip generated\n" ; 


