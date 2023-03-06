#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV != 4) {
	print "$0 fasta species1 species2 \n\n" ;
	exit ;
}

my $filenameA = $ARGV[0];
my $species1 = $ARGV[1] ;
my $species2 = $ARGV[2] ;
my $numStopcodons = $ARGV[3] ; 

my %fasta = () ; 

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

print "$species1\n" ; 
#print "$fasta{$species1}\n" ;

print "$species2\n" ; 
#print "$fasta{$species2}\n" ;


my $species1fasta = $fasta{$species1} ;
my $species2fasta = $fasta{$species2} ;
my $totalbase = 0 ; 
my $diff = 0 ; 

for (my $i = 2 ; $i < length($species1fasta) ; $i += 3 ) {

    
    
    
    my $base1 = substr($species1fasta, $i, 1 ) ;
    my $base2 =	substr($species2fasta, $i, 1 ) ;

    if ($base1 eq '-' && $base2 eq '-' ) {
	next ; 
    }
    $totalbase++ ;


    $diff++ if $base1 ne $base2 ; 
    #print "$base1\t$base2\n" ;

}

print "total: $totalbase \n" ;
print "total minus stop codons: " . ($totalbase - $numStopcodons) . "\n" ; 
print "diff: $diff\n" ; 


