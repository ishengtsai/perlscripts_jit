#!/usr/bin/perl -w
use strict;
#use diagnostics;



my $largest = 0;
my $contig = '';


if (@ARGV != 2) {
    print "$0 mitoZ_Mol.sc.fasta summary.txt.bed \n" ; 
    exit ;
}


my $filenameA = $ARGV[0] ;
my $filenameB = $ARGV[1] ;
my $marker = $ARGV[2] ; 


my %fasta = () ;
my %fasta_subject = () ;

my $fasta_len = 0 ; 



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


open (IN, "$filenameB") or die "oops!\n" ;

while (<IN>) {
    chomp;
    my @r = split /\s+/, $_ ;

    print "gene: $r[4]\n" ;
    open (SEQ, "$r[4].mod.seq") or die "can't open $r[4].mod.seq" ;
    my $seq = <SEQ> ;
    chomp($seq);

    if ( $r[3] eq '-' ) {
	print "seq revomp!\n" ; 
	$seq = revcomp($seq) ; 
    }

    
    close(SEQ) ; 
    
    if ( $fasta{$r[0]} =~ /N+/g ) {
	my $pos = pos($fasta{$r[0]}) ;

	print "$r[4] position at $pos\n" ; 

	$fasta{$r[0]} =~ s/N+/$seq/ ; 
	
    }

    print "$fasta{$r[0]}\n\n\n" ; 

    print "\n\n" ; 
}
close(IN); 


open OUT, ">", "$filenameA.mod.fa" or die "doaspdoaopsdpoa\n" ;

for my $seqname (sort keys %fasta) {
    print OUT ">$seqname\n$fasta{$seqname}\n" ; 
}

print "done! $filenameA.mod.fa produced!\n" ; 


sub revcomp {
  my $dna = shift;
  my $revcomp = reverse($dna);

  $revcomp =~ tr/ACGTacgt/TGCAtgca/;

  return $revcomp;
}
