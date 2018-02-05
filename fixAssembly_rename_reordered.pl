#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV != 4) {
    print "$0 list fasta prefix exclude.list\n" ; 
    exit ;
}


my $list = $ARGV[0] ;
my $filenameA = $ARGV[1] ; 
my $prefix = $ARGV[2] ;
my $excludefile = $ARGV[3] ; 

my %exclude = () ; 
open (IN, "$excludefile") or die "oops!\n" ;
while (<IN>) {
    chomp; 

    if ( /(^\S+)/ ) {
	$exclude{$1}++ ; 
    }
}


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
			    my $seq = uc($_) ; 
			    $read_seq .= $seq ;
			}


		}

	    }
	}

close(IN) ;

$fasta{$read_name} = $read_seq ;
#print "$read_name\t" . length($read_seq) . "\n" ;

open OUT, ">", "$prefix.fa" or die "ooops\n" ; 

open (IN, "$list") or die "oooops\n" ; 

my $count = 1 ; 

while (<IN>) {

    chomp ; 
    my @r = split /\s+/, $_ ; 

    my $result = sprintf("%04d", $count);

    if ( $exclude{$r[0]} ) {
    
    }
    elsif ( $r[0] =~ /mitochon/ ) {
	print OUT ">$prefix\_MtDNA\n$fasta{$r[0]}\n" ;
    }
    elsif ( $r[0] =~ /MtDNA/ ) {
	print OUT ">$prefix\_MtDNA\n$fasta{$r[0]}\n" ;
    }
    else {
	print OUT ">$prefix.scaff$result\n$fasta{$r[0]}\n" ; 
	$count++ ; 
    }
}
close(IN) ; 


print "all done! $prefix.fa generated\n" ; 


