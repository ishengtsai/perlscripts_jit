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

			    if ( $read_name eq 'PNOK.scaff0008.O.1.976519' ) {
				# new coords
				# 7131     9366  |  1676879  1679120  |     2236     2242  |    85.37  | PNOK.scaff0008.O.1.976519    PNOK.scaff0005.O.1.1679120



				my $newseq = substr($read_seq, 9368) ; 

				my $newseq2 = $assembly{"PNOK.scaff0005.O.1.1679120"} ; 

				my $mergedSeq = $newseq2 . $newseq ; 
				$assembly{"newScaff"} = $mergedSeq ; 
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
    if ( $name eq "newScaff" ) {
	print OUT ">$name\n" ; 
	print OUT "$assembly{$name}\n" ; 
    }
}

print "$filenameA.mergedManually.fa printed!\n" ; 


sub revcomp {
    my $dna = shift;
    my $revcomp = reverse($dna);

    $revcomp =~ tr/ACGTacgt/TGCAtgca/;

    return $revcomp;
}
