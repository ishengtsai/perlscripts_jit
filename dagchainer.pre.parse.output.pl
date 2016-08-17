#!/usr/bin/perl -w
use strict;







if (@ARGV != 2) {
    print "$0 dagchainer.output.file refspecies\n" ; 
	exit ;
}


my $filenameA = shift ; 
my $refspecies = shift ; 


my %genes = () ; 



open (IN, $filenameA) or die "can't open $filenameA\n" ; 
open OUT, ">", "$filenameA.prefilter" or die "osapoda\n" ; 

my $reforder = 0 ; 



while (<IN>) {

    if (/^\#\# alignment (\S+) vs. (\S+).+pairs: (\d+)/ ) {
	my $scaff1 = $1 ; 
	my $scaff2 = $2 ; 
	my $genepair = $3 ; 
	
	if ( $scaff1 =~ /$refspecies/ ) {
	    #no need reverse
	    print OUT "$_" ; 

	    for (my $i = 0 ; $i < $genepair ; $i++ ) {
		my $tmp = <IN> ; 
		my @r = split /\s+/, $tmp ; 
		
		print "$r[1] already present!\n" if $genes{$r[1]} ; 
		print "$r[5] already present!\n" if $genes{$r[5]} ;
		
		$genes{$r[1]}++ ; 
		$genes{$r[5]}++;

		print OUT "$tmp" ; 
	    }


	}
	elsif ( $scaff2 =~ /$refspecies/ ) {
	    #print "$_ need reversed!\n" ; 
	    s/$scaff2/$scaff1/ ; 
	    s/$scaff1/$scaff2/ ; 

	    print OUT "$_" ; 

            for (my $i = 0 ; $i < $genepair ; $i++ ) {
                my $tmp = <IN> ;
                my @r = split /\s+/, $tmp ;

                print "$r[1] already present!\n" if $genes{$r[1]} ;
                print "$r[5] already present!\n" if $genes{$r[5]} ;

                $genes{$r[1]}++ ;
                $genes{$r[5]}++;

		print OUT "$r[4]\t$r[5]\t$r[6]\t$r[7]\t" ; 
		print OUT "$r[0]\t$r[1]\t$r[2]\t$r[3]\t" ; 
		print OUT "$r[8]\t$r[9]\n" ; 


            }

	}
	else {
	    print "warning!!! $_ with $refspecies not found!\n" ; 
	}

	

    }


}
close(IN) ; 
