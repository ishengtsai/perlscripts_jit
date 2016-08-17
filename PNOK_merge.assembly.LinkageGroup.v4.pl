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

$assembly{"PNOK.scaff0005.O"} = substr($assembly{"PNO7.scaff0004"}, 0, 3743) . substr($assembly{"PNOK.scaff0005.O"}, 17530) ;
$assembly{"PNOK.scaff0007.O"} = substr($assembly{"PNO7.scaff0009"}, 0, 37140) . $assembly{"PNOK.scaff0007.O"} ; 
#$assembly{"PNOK.scaff0006"} = substr( $assembly{"PNOK.scaff0006"} , 0 ,2506972) . substr($assembly{"PNO7.scaff0006"} , 2067624) ;


open OUT, ">", "$filenameA.mergedManually.fa" or die "doasdpaopds\n" ; 

for my $name (sort keys %assembly ) {
    if ( $name =~ /PNOK/ ) {
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
