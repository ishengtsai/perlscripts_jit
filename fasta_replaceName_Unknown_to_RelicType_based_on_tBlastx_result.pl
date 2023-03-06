#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';




if (@ARGV != 2) {
    print "$0 fasta blastoutput \n" ;
	exit ;
}

my $filenameA = $ARGV[0];
my $filenameB = $ARGV[1] ; 

open (IN, "$filenameB") or die "oops!\n" ;

my %change = () ; 

while (<IN>) {
    chomp ;
    next if /^\#/ ;
    my @r = split /\s+/ ;

    if ( $r[0] =~ /(.+)\#(.+)/ ) {
	my $seq = $1 ;
	my $type = $2 ;
	my $newtype = '' ; 

	$newtype = $r[1] ;
	$newtype =~ s/\/.+$// ;
	$newtype .= ".Relic" ; 


	print "$r[0] ---> $seq\#$newtype\n" ;

	if ( $change{$r[0]} ) {
	    print "oops! $r[0] already changed!\n"; 
	}
	else{
	    $change{$r[0]} = "$seq\#$newtype" ; 
	}
    }
    
}



open OUT, ">", "$filenameA.Unknown.changed.fa" ;

open (IN, "$filenameA") or die "oops!\n" ;

my $count = 1 ; 

	while (<IN>) {


	    if (/^>(\S+)/) {
		my $seqname = $1 ; 

		if ( $change{$seqname} ) {
		    print OUT ">$change{$seqname}\n" ; 
		}
		else {
		    print OUT ">$seqname\n" ;

		}
	    }
	    else {
		chomp; 
		if ( $_ eq '' ) {
		
		}
		else {
		    print OUT "$_\n" ;
		}
	    }

	}

close(IN) ;




print "all done!\n $filenameA.Unknown.changed.fa produced!\n" ; 
