#! /usr/bin/perl -w
#
# File: sam2fastq.pl
# Time-stamp: <01-Sep-2011 16:35:57 tdo>
# $Id: $
#
# Copyright (C) 2009 by Pathogene Group, Sanger Center
#
# Author: Thomas Dan Otto
#
# Description:
#

use strict;
my $resultname=shift;
if ((!(defined($resultname)))) {
  die "$0 Please defined resultname\n";
  
}
open F, ">".$resultname.".UM_1.fastq" or die "problesm";
open R, ">".$resultname.".UM_2.fastq" or die "problesm";

# get's the input from a awk command.


my %seenMate;

my @ar;
my $res1='';
my $res2='';

my $count=0;
while (<STDIN>) {
  chomp;
  
  @ar =split(/\t/);
  $ar[0] =~ s/\.R$//g;
  $ar[0] =~ s/\.F$//g;
  $ar[0] =~ s/\/\d$//g;

  $ar[0] =~ s/a$//g ; 
  $ar[0] =~ s/b$//g ; 
  
  if ( $ar[1] == 77 || $ar[1] == 141 ) {

  }
  else {
      next ; 
  }

  if (defined($seenMate{$ar[0]})) {
	### first mate
	my $tmp=getfastq(\@ar);
	
	if ($ar[1] & 0x0040) {
	  $res1.=$tmp;
	  $res2.=$seenMate{$ar[0]}
	}
	else {
	  $res1.=$seenMate{$ar[0]};
	  $res2.=$tmp;
	}
	delete($seenMate{$ar[0]});
	
	$count++;
	if (($count%100000)==0) {
	  print F $res1;
	  $res1='';
	  print R $res2;
	  $res2='';
	  
	}
	
  }
  else {
	$seenMate{$ar[0]}=getfastq(\@ar)
  }
}
print F $res1;
print R $res2;
close(F);
close(R);

#print $res;

#open F, ">".$resultname."SE.fastq" or die "problesm";
#foreach my $r (keys %seenMate) {
#  print F "$seenMate{$r}";
#}
#close(F);


sub revcomp{
  my $str = (shift);
  $str =~ tr/ATGCatgc/TACGtacg/;
  
  return reverse($str);
}

sub getfastq{
  my $ar=shift;
  
  my $res;
   
  if ($$ar[1] & 0x0040) {
	$res="@".$$ar[0]."/1\n";
  }
  else {
	$res="@".$$ar[0]."/2\n";
  }
  if ($$ar[1] & 0x0010) {
	### have to recomp seq
	$res.=revcomp($$ar[9])."\n"."+\n".reverse($$ar[10])."\n";
  }
  else {
	$res.=$$ar[9]."\n"."+\n".$$ar[10]."\n";
  }
  return $res
}
