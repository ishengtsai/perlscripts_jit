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


			    
			    
			    $assembly{$read_name} = $read_seq ; 
			    


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


$assembly{"Segkk132"} = substr( $assembly{"Segkk132"} , 0, 7002) ; 
$assembly{"Segkk132"} = revcomp($assembly{"Segkk132"}) ; 

$assembly{"Segkk135"} = substr($assembly{"Segkk135"}, 0, 2696288) . $assembly{"Segkk132"} ;




open OUT, ">", "$filenameA.mergedManually.fa" or die "doasdpaopds\n" ; 

for my $name (sort keys %assembly ) {

    if ( $name ne "Segkk132" ) {
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
