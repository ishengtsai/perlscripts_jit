#!/usr/bin/perl -w
use strict;



if (@ARGV != 3) {
    print "$0 genes.fpkm_tracking gene_exp.dif \"list in double quotes \"\n " ;
	exit ;
}

my $fpkmfile = shift @ARGV;
my $genediffexfile = shift @ARGV ; 
my $list = shift @ARGV ; 

my @stage = split /\s+/, $list ; 

open OUT, ">", "cuffmerge.easytable" ; 

my %diff = () ; 

open (IN, "$genediffexfile") or die "oops!\n" ;
while (<IN>) {
    chomp; 
    my @r = split /\s+/, $_ ; 

    $r[0] =~ s/:mRNA//gi ;

    $diff{$r[0]}{"$r[4].$r[5]"} = "$r[12]\t$r[13]" ; 
    $diff{$r[0]}{"$r[5].$r[4]"} = "$r[12]\t$r[13]" ;


}
close(IN) ; 





my %gene = () ; 

#my @headers = split /\s+/ , <IN> ; 
my $count = 0 ; 
open (IN, "$fpkmfile") or die "oops!\n" ;
while (<IN>) {

    chomp ; 
    my @r = split /\s+/, $_ ; 

    $r[0] =~ s/:mRNA//gi ; 

    print OUT "$r[0]\t$r[6]" ; 

    for (my $i = 9 ; $i < @r ; $i += 4 ) {
	print OUT "\t$r[$i]\t$r[$i+3]\t" ; 
    }

    if ( $count == 0 ) {
	for (my $i = 0 ; $i < $#stage  ; $i++ ) {
	    for (my $j = $i + 1 ; $j < @stage  ; $j ++ ) {
		print OUT "$stage[$i].$stage[$j]\t" ; 
	    }
	}
	#print OUT "$stage[$#stage].$stage[0]\n" ; 
    }
    else {

	for (my $i = 0 ; $i < $#stage ; $i++ ) {
	    for (my $j = $i+ 1 ; $j < @stage ; $j++ ) {
		my $cond = "$stage[$i].$stage[$j]" ;
		print OUT "$diff{$r[0]}{$cond}\t" ;
	    }
	}
	#my $cond = "$stage[$#stage].$stage[0]" ; 
	#print OUT "$diff{$r[0]}{$cond}\n" ;

    }
    print OUT "\n" ; 

    $count++ ; 
}


print "all done! cuffmerge.easytable produced\n" ; 
