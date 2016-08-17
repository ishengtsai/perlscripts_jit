#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV != 3) {
	print "$0 fasta folder count\n\n" ;
	exit ;
}

my $filenameA = $ARGV[0];
my $folder = $ARGV[1] ;
my $bin = $ARGV[2] ;



my $count = 1 ;
my $tmp_count = 0 ;

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
			    
#			    print "$read_name\t" . length($read_seq) . "\n" ;
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

if ( -d "$folder") {
    print "Warning! folder $folder already exist... exiting!\n" ; 
    exit ; 
}
else {
mkdir "$folder"  ; 
}

for my $seqname  (sort keys %fasta ) {

    if ( $tmp_count == 0 ) {
	open OUT, ">", "$folder/$count.fa" or die "daodoapdosa\n" ; 
    }

    print OUT ">$seqname\n$fasta{$seqname}\n" ; 

    if ( $tmp_count == $bin) {
	close(OUT) ; 
	$tmp_count = 0 ; 
	$count++ ; 
	next ; 
    }

    $tmp_count++ ; 



}


print "all done! " . ($count ) . " files created in folder: $folder\n" ; 
