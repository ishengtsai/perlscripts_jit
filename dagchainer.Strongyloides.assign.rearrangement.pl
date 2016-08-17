#!/usr/bin/perl -w
use strict;







if (@ARGV != 2) {
    print "$0 assigned.chr.list dagchainer.output.stage1 \n" ; 
	exit ;
}

my $genelocfile = shift ; 
my $filenameA = shift ; 


my %groups = () ; 

open (IN, $genelocfile) or die "dadakjdadjklad\n" ; 
while (<IN>) {
    chomp; 
    my @r = split /\s+/, $_ ; 
    $groups{$r[0]} = "$r[1]" ; 
}
close(IN) ; 

open (IN, $filenameA) or die "can't open $filenameA\n" ; 


my %assigned = () ; 

while (<IN>) {
    next if /\#/ ; 

    chomp ;
    my @r = split /\s+/, $_ ; 

    if ( $r[0] =~ /Chr1/ ) {
	$r[0] = 'Chr1' ; 
    }
    elsif ( $r[0] =~ /Chr2/ ) {
	$r[0] = 'Chr2';
    }
    elsif ( $r[0] =~ /ChrX/ ) {
	$r[0] = 'ChrX';
    }
    else {
	$r[0] = 'unplaced' ; 
    }

    
    if ( $groups{"$r[1]"} ) {
	my $chr = $groups{"$r[1]"} ; 
	$assigned{$r[0]}{$chr} += $r[2] ; 
    }
    else {
	$assigned{$r[0]}{"unplaced"} += $r[2] ; 

    }
    

}


for my $refchr (sort keys %assigned ) {

    for my $qrychr ( sort keys % { $assigned{$refchr} } ) {
	my $num = $assigned{$refchr}{$qrychr} ; 
	print "$refchr\t$qrychr\t$num\n" ; 

    }


}

