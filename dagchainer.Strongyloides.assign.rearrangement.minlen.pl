#!/usr/bin/perl -w
use strict;







if (@ARGV != 4) {
    print "$0 assigned.chr.list dagchainer.output.stage1 qrycontiglen maxlen\n" ; 
	exit ;
}

my $genelocfile = shift ; 
my $filenameA = shift ; 
my $contiglenfile = shift ;
my $maxlen = shift ; 

my %contig_included = () ; 

open (IN, $contiglenfile) or die "doapdoa\n" ; 
while (<IN>) {
    chomp; 
    my @r = split /\s+/, $_ ; 
    if ( $r[1] >= $maxlen ) {
	$contig_included{$r[0]}++ ; 
    }
}
close(IN) ; 

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

    unless ( $contig_included{$r[1]} ) {
	next ; 
    }

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


if ( "$assigned{Chr1}{1}" ) {
    print "$assigned{Chr1}{1}\t" ; 
}
else {
    print "0\t" ; 
}
if ( "$assigned{Chr2}{2}" ) {
    print "$assigned{Chr2}{2}\t" ;
}
else {
    print "0\t" ; 
}
if ( "$assigned{ChrX}{X}" ) {
    print "$assigned{ChrX}{X}\t" ;
}
else {
    print "0\t" ; 
}

my $intra = $assigned{Chr1}{X} + $assigned{ChrX}{1} ;
my $inter = $assigned{Chr2}{1} + $assigned{Chr2}{X} + $assigned{ChrX}{2} + $assigned{Chr1}{2} ;

print "$intra $inter\n" ; 




for my $refchr (sort keys %assigned ) {

    for my $qrychr ( sort keys % { $assigned{$refchr} } ) {
	my $num = $assigned{$refchr}{$qrychr} ; 
	print "$refchr\t$qrychr\t$num\n" ; 

    }


}

