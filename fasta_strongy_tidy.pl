#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';




if (@ARGV != 1) {
    print "$0 fasta\n" ; 
	exit ;
}

my $filenameA = $ARGV[0];


my %gene_present = () ; 


system("fasta2singleLine.pl $filenameA tmp.fa") ; 

open (IN, "tmp.fa") or die "oops!\n" ;

while (<IN>) {

    if (/>(\S+)\.t1/ ) {
	my $name = $1 ; 
	my $seq = <IN> ; chomp($seq) ; $seq =~ s/\*//gi ; 

	print ">$name.1\n$seq\n" ; 
	
    }
    elsif ( />(\S+\.1):mRNA/ ) {
	my $name = $1 ;
	my $seq= <IN> ; chomp($seq) ; $seq =~ s/\*//gi;

	print ">$name\n$seq\n" ;

    }
    


}
