#! /usr/bin/perl -w
#
# File: revcompFastq.pl
# Time-stamp: <18-Feb-2009 17:10:33 tdo>
# $Id: $
#
# Copyright (C) 2009 by Pathogene Group, Sanger Center
#
# Author: Thomas Dan Otto
#
# Description:
#


use strict;

if ( @ARGV != 2 ) {
    print "$0 fasta seqnameToRevcomp \n" ; 
    exit ; 
}

my $name = shift;
my $seqname = shift ; 

open(IN,$name) or die "couldn't open $name: $!\n";


my $res;

open (F, "> $name.With$seqname.revcomp") or die "problem \n";





my $read_name = '' ;
my $read_seq = '' ;

while (<IN>) {
    if (/^>(\S+)/) {
	$read_name = $1 ;
	$read_seq = "" ;

	while (<IN>) {

	    if (/^>(\S+)/) {
		my $newseqname = $1 ; 
		

		if ( $read_name eq $seqname ) {
		    my $tmp = revcomp($read_seq) ;
		    print F ">$read_name\n$tmp\n" ;
		}
		else {
		    print F ">$read_name\n$read_seq\n" ;
		}

		
		$read_name = $newseqname ;
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

if ( $read_name eq $seqname ) {
    my $tmp = revcomp($read_seq) ;
    print F ">$read_name\n$tmp\n" ;
}
else {
    print F ">$read_name\n$read_seq\n" ;
}



sub revcomp {
  my $dna = shift;
  my $revcomp = reverse($dna);

  $revcomp =~ tr/ACGTacgt/TGCAtgca/;

  return $revcomp;
}

