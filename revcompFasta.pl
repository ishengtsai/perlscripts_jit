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

if ( @ARGV != 1 ) {
    print "$0 fasta \n" ; 
    exit ; 
}

my $name = shift;

open(IN,$name) or die "couldn't open $name: $!\n";


my $res;

open (F, "> $name.revcomp") or die "problem \n";

while (<IN>) {


    if ( /^>/ ) {
	print F "$_" ;
    }
    else {
	chomp; 
	my $tmp = revcomp($_) ;
	print F "$tmp\n" ;
    }


}



sub revcomp {
  my $dna = shift;
  my $revcomp = reverse($dna);

  $revcomp =~ tr/ACGTacgt/TGCAtgca/;

  return $revcomp;
}

