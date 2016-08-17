#!/usr/bin/perl -w
use strict;



if (@ARGV != 3) {
    print "$0 file.hint num.intron.filter merge.mode\n" ; 
    exit ;

}

my $file = shift @ARGV;
my $hint = shift @ARGV ;
my $merge = shift @ARGV ; 

open OUTHINTS, ">" , "$file.filtered.$hint.merge.$merge.hints"or die "ooops can't open!\n" ;

open (IN, "$file") or die "oops!\n" ;



## read in the cufflink annotations
while (<IN>) {
	
	chomp ;
	my @r = split /\s+/, $_ ; 

	if ( $r[2] eq 'ep' ) {
	    print OUTHINTS "$_\n" ; 
	}
	elsif ( $r[2] eq 'intron' && $r[8] =~ /^mult=(\d+)/ ) {
	    if ( $1 > $hint ) {
		if ( $merge == 1 ) {
		    s/mult=\d+/mult=1/ ; 
		    print OUTHINTS "$_\n" ; 
		}
		else {
		    print OUTHINTS "$_\n" ;
		}
	    }
	    else {

	    }

	}
	else {

	}



}

print "all done! $file.filtered.$hint.merge.$merge.hints\n" ; 
