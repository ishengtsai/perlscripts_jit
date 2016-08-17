#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV != 1) {
	print "$0 fasta\n\n" ;
	exit ;
}

my $filenameA = $ARGV[0];

my %assembly = () ; 

open (IN, "$filenameA") or die "oops!\n" ;

	my $read_name = '' ;
	my $read_seq = '' ;

	while (<IN>) {
	    if (/^>(\S+)/) {
		$read_name = $1 ;
		$read_seq = "" ;
		$read_name =~ s/\#/\./gi ; 
		
		while (<IN>) {

			if (/^>(\S+)/) {
			    
			    print "$read_name\n" ; 

			    if ( $read_name eq 'scaffold7' ) {
				# new coords
                                #1666    4332    2334823 2337488 2667    2666    91.64   5427924 2367768 0.05    0.11    scaffold1       scaffold7


				my $RVseq = revcomp($read_seq) ;
				my $newseq = substr($RVseq, 0, 2337488) ; 

				my $newseq2 = substr($assembly{"scaffold1"}, 4333) ; 

				my $mergedSeq = $newseq . $newseq2 ; 
				$assembly{"scaffold1"} = $mergedSeq ; 
			    }
			    else {
			    
				$assembly{$read_name} = $read_seq ; 

			    }


			    $read_name = $1 ;
			    $read_seq = "" ;
			    $read_name =~ s/\#/\./gi ;


			}
			else {
			    chomp ;
			    $read_seq .= $_ ;
			}


		}

	    }
	}

close(IN) ;

$assembly{$read_name} = $read_seq ;
print "$read_name\n\n\n" ;

open OUT, ">", "$filenameA.mergedManually.fa" or die "doasdpaopds\n" ; 

for my $name (sort keys %assembly ) {
    print OUT ">$name\n" ; 
    print OUT "$assembly{$name}\n" ; 
}

print "$filenameA.mergedManually.fa printed!\n" ; 


sub revcomp {
    my $dna = shift;
    my $revcomp = reverse($dna);

    $revcomp =~ tr/ACGTacgt/TGCAtgca/;

    return $revcomp;
}
