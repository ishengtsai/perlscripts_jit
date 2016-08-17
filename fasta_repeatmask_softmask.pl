#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV != 2) {
	print "$0 fasta Repeatmasker.cat \n\n" ;
	exit ;
}

my $filenameA = $ARGV[0];
my $repeatfile = $ARGV[1] ; 

my %fasta = () ; 

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
			    
			    #print "$read_name\t" . length($read_seq) . "\n" ;
			    
			    $fasta{$read_name} = $read_seq ; 
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
$fasta{$read_name} = $read_seq ;

print "fasta read... softmasking now\n" ; 
open (IN, "$repeatfile") or die "oops!\n" ;
while (<IN>) {
    next if /^\s+SW/ ; 
    next if /^\n/ ; 
    next if /^score/ ; 

    my @r = split /\s+/, $_ ; 
    shift @r ; 
    #print "$r[1]\n" ; 

    my $seq = $fasta{$r[4]}  ;
    my $start = $r[5] - 1 ; 
    my $seqlen = $r[6]-$r[5]+1  ; 
    my $seq2 = substr $seq, $start, $seqlen ; 
    substr $seq, $start, $seqlen , lc($seq2) ; 

    $fasta{$read_name} = $seq ; 

}
close(IN) ; 

open OUT, ">", "$filenameA.softmasked.fa" or die "odaposdopaopdsa\n" ; 

for (sort keys %fasta) {
    print OUT ">$_\n$fasta{$_}\n"
}

print "all done! $filenameA.softmasked.fa generated\n" ; 
