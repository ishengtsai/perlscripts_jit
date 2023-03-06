#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV != 2) {
	print "$0 fasta min_len\n\n" ;
	exit ;
}

my $filenameA = $ARGV[0];
my $minlen = $ARGV[1]; 

open OUT, ">", "$filenameA.min$minlen.fa" or die "dsoadpadosap\n" ; 
open OUT2, ">", "$filenameA.min$minlen.fa.names" or die "doasdpaosd\n" ; 


open (IN, "$filenameA") or die "oops!\n" ;

	my $read_name = '' ;
	my $read_seq = '' ;

	while (<IN>) {
	    if (/^>(\S+)/) {
		$read_name = $1 ;
		$read_seq = "" ;
		
		while (<IN>) {

			if (/^>(\S+)/) {
			    my $seq_new_name = $1 ; 
			    my @seqs = split /\*/, $read_seq ;
			    my $count = 1 ; 

			    my $transcriptlen = 0 ;
			    my $tobeadded = 0 ; 
			    for (my $i = 0 ; $i < @seqs ; $i++ ) {
				my $copylen = 0 ; 
				if ( $seqs[$i] ) {
				    $copylen = length($seqs[$i])
				}
				if ( $copylen >= $minlen ) {
				    print OUT ">$read_name.section$count.$copylen.$transcriptlen-" . ( $transcriptlen + $copylen * 3 )  . "\n" ;
				    print OUT "$seqs[$i]\n" ;

				    if ( $read_name =~ /^(.+)\.(\d+)-(\d+)_(\d+)/ ) {
					print OUT2 "$1\t$2\t$3\t$count\t$4\t$copylen\t$read_name\n" ; 
				    }
				    
				    $count++ ; 
				}
				$tobeadded = $copylen * 3 ; 
				$transcriptlen += 3 ;
				$transcriptlen += $tobeadded  ; 
			    }


			    
			    $read_name = $seq_new_name ;
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

my @seqs = split /\*/, $read_seq ;
my $count =1 ;

for(my $i = 0 ; $i < @seqs ; $i++ ) {
    my $copylen = length($seqs[$i]) ;
    if ( $copylen >= $minlen ) {
	print OUT ">$read_name.section$count.$copylen\n" ;
	print OUT "$seqs[$i]\n" ;

	if ( $read_name =~ /^(\d+)-(\d+)/ ) {
	    print OUT2 "" . ($1 + 1) . "\t$2\n" ;
	}
	
	$count++ ;
    }
}


print "\n" ; 
