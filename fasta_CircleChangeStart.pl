#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV != 5) {
	print "$0 fasta contig_name coord strand new_contig_name \n\n" ;
	exit ;
}

my $filenameA = shift @ARGV;
my $contig_name = shift @ARGV;
my $start = shift @ARGV;

# change to + or -
my $NeedRevcomp = shift @ARGV ;


my $newContigName = shift @ARGV ; 



my %contig_seq = () ;

open (IN, "$filenameA") or die "oops!\n" ;
	my $read_name = '' ;
	my $read_seq = '' ;

	while (<IN>) {
	    if (/^>(\S+)/) {
		$read_name = $1 ;
		$read_seq = "" ;
		
		while (<IN>) {

			if (/^>(\S+)/) {
			    
				$contig_seq{$read_name} = $read_seq ;

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
$contig_seq{$read_name} = $read_seq ;


print ">$newContigName\n" ; 

if ( $NeedRevcomp eq '+' ) {


    my $region1 = uc(substr($contig_seq{$contig_name}, ($start-1) )) ;
    my $region2 = uc(substr($contig_seq{$contig_name}, 0, $start-1))  ;
    
    print "$region1$region2\n" ; 
}
else {

    my $region1 = revcomp(uc(substr($contig_seq{$contig_name}, 0, $start ))) ;
    my $region2 = revcomp(uc(substr($contig_seq{$contig_name}, $start)))  ;

    
    
    print "$region1$region2\n" ;


}




sub revcomp {
  my $dna = shift;
  my $revcomp = reverse($dna);

  $revcomp =~ tr/ACGTacgt/TGCAtgca/;

  return $revcomp;
}

