#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV != 4) {
    print "$0 list fasta minlen domain\n" ; 
    exit ;
}

my $filenameA = $ARGV[1];
my $list = $ARGV[0] ; 
my $minlen = $ARGV[2] ; 
my $domainname = $ARGV[3] ; 

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


my %present = () ; 

open OUT, ">", "$filenameA.$domainname.fa" or die "ooops\n" ; 

open (IN, "$list") or die "oooops\n" ; 

while (<IN>) {

    chomp ; 
    next if /^\#/ ; 
    next unless /^\S+/ ; 
    my @r = split /\s+/, $_ ; 

    if ( $r[6] ne $domainname ) {
	next ; 
    }

    if ( $present{$r[0]} ) {
	print "$r[0] already included!\n" ;
	next ; 
    }

    if ( $r[4]- $r[3] < $minlen ) {
	print "too short: $_\n" ; 
	next; 
    }
    if ( $r[12] >= "0.001" ) {
	print "not significant enough $_\n" ; 
	next ; 
    }


    $present{$r[0]}++ ; 

    my $domainseq = substr($fasta{$r[0]}, $r[3]-1, ($r[4]-$r[3]+1) ) ; 

    print OUT ">$r[0]\n$domainseq\n" ; 


}
close(IN) ; 


print "all done! $filenameA.$domainname.fa\n" ; 


