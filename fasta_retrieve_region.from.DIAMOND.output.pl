#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV < 2) {
	print "fasta_retrieve_region.pl fasta RegionfileFromDIAMOND\n\n" ;
	exit ;
}

my $filenameA = shift @ARGV;

my $regionFile = shift @ARGV;

my @regions = () ;

open (IN, "$regionFile") or die "oops!\n" ;
while (<IN>) {
    my @r = split /\s+/, $_ ;

    push(@regions, "$r[0]\:$r[1]\:$r[6]-$r[7]") ; 

}
close(IN) ; 




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



foreach my $region (@regions) {

    my $contig_name ; my $gene ; my $start ; my $end ; 
    
    if ( $region =~ /(\S+)\:(\S+)\:(\d+)-(\d+)/ ) {
	$contig_name = $1 ;
	$gene = $2 ; 
	$start = $3 ;
	$end = $4 ;
    }

    if ( -d $gene ) {

    }
    else {
	mkdir ($gene) ; 
    }

    open OUT,">", "$gene/diamond.$contig_name.$gene.$start.$end.nuc.fa" or die "dasdiaodsias\n" ;
    print OUT ">$contig_name.$gene.$start.$end\n" ;

    print "$region done!\n" ; 
    
    if ($start > $end ) {
	$region = substr($contig_seq{$contig_name}, ($end-1), ($start-$end+1) ) ;
	$region = revcomp($region) ; 
    }
    else {
	$region = substr($contig_seq{$contig_name}, ($start-1), ($end-$start+1) ) ;

    }

    print OUT "$region\n" ; 
    close (OUT) ; 
}
    

sub revcomp {
  my $dna = shift;
  my $revcomp = reverse($dna);

  $revcomp =~ tr/ACGTacgt/TGCAtgca/;

  return $revcomp;
}

