#!/usr/bin/perl -w
use strict;



if (@ARGV != 3) {
	print "$0 genes.manual.gb.test genes.manual.gb.test.hints.overlap interlen \n\n" ;


	exit ;
}

my $file = shift @ARGV;
my $hint = shift @ARGV ;
my $interlen = shift @ARGV ; 

open OUT, ">" , "$file.formatted" or die "ooops can't open!\n" ; 
open OUTHINTS, ">" , "$file.formatted.hints"or die "ooops can't open!\n" ;

open (IN, "$file") or die "oops!\n" ;

my $count = 1; 
my %locus = () ; 

my %locus_start = () ; 
my %locus_end = () ; 

my $start = 0 ; 
my $end = 0 ; 

## read in the cufflink annotations
while (<IN>) {
	
	chomp ;
	if (/^LOCUS\s+(\S+)/ ) {
	    my $locus = $1 ; 
	    s/$locus/LOCUS$count/gi ; 
	    print OUT "$_\n" ; 
	}
	elsif ( /gene=\"(\S+)\"/ ) {
	    $locus{"$1"} = "LOCUS$count" ; 
	    $count++ ; 
	    print OUT "$_\n" ; 
	}
	else {
	    print OUT "$_\n" ; 

	}

}
close(IN) ; 

open (IN, "$hint") or die "oooooops\n" ; 


while (<IN>) {

    chomp; 
    my @r = split /\s+/, $_ ; 

    if ( ($r[13] + $interlen) < $r[4] ) {
	$r[4] = ($r[13] + $interlen ) ;
    }

    my $present = 0 ;

    if ( $r[17] =~ /Name=(\S+)/ ) {
	my $gene = $1 ; 

	if ( $locus{$gene} ) {
	    $r[0] = $locus{$gene} ; 
	    $present = 1 ; 


	    # do filtering
	    $r[3] = $r[3] - $r[12] + 1 + $interlen; 
	    $r[3] = 1 if $r[3] <= 0 ; 

	    $r[4] = $r[4] - $r[12] + 1 + $interlen;

	}
	else {

	}


    }
    # Taisei's format
    elsif ( $r[17] =~ /ID=(\S+)/ ) {
        my $gene = "$1" . "t" ;

	#print "$gene found!\n" ; 

        if ( $locus{$gene} ) {
            $r[0] = $locus{$gene} ;
            $present = 1 ;


            # do filtering
            $r[3] = $r[3] - $r[12] + 1 + $interlen;
            $r[3] = 1 if $r[3] <= 0 ;

            $r[4] = $r[4] - $r[12] + 1 + $interlen;

        }
        else {

        }

    }


    if ( $present ) {
	#print "@r\n" ; 

	print OUTHINTS "$r[0]" ; 
	for (my $i = 1 ; $i< 9 ; $i++) {
	    print OUTHINTS "\t$r[$i]" ; 
	}
	print OUTHINTS "\n" ; 

    }



}


print "all done! $file.formatted.hints and $file.formatted created !\n\n" ; 
