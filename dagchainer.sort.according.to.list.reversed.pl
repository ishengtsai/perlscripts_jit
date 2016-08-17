#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV != 4) {
    print "$0 dagchainer.output.stage1 chr1.listfile offset reveredlen\n" ; 
	exit ;
}

my $filenameA = $ARGV[0];
my $listfile = $ARGV[1] ; 
my $offset = $ARGV[2] ; 
my $reversedlen = $ARGV[3] ; 

my @list = () ; 
my %listcoord = () ; 

open (IN, $listfile) or die "daidaioda\n" ; 
while (<IN>) {
    chomp ; 
    my @r = split /\s+/, $_ ; 

    push(@list, $r[0]) ; 
    $listcoord{$r[0]} = $r[1] ; 

}
close(IN) ; 


my %dagchainer = () ; 

my %refcoords = () ; 
#chr2 = Chr1 len + 1Mb
$refcoords{'pathogen_SRAE_Chr2_000001'} = '30000000' ;
$refcoords{'pathogen_SRAE_Chr1_000001'} = '1' ;
$refcoords{'pathogen_SRAE_ChrX_000001'} = '15000000' ;
$refcoords{'pathogen_SRAE_ChrX_000002'}= '21000000' ;


open (IN, "$filenameA") or die "oops!\n" ;
while (<IN>) {
    chomp ;
    my @r = split /\s+/, $_ ;

    if ( $listcoord{$r[0]} && $refcoords{$r[1]} ) {
	my $qryright = $reversedlen - $r[6] + $listcoord{$r[0]} + $offset ; 
	my $qryleft = $reversedlen - $r[11] + $listcoord{$r[0]} + $offset ;

	my $refleft = $r[14] + $refcoords{$r[1]} ; 
	my $refright = $r[19] + $refcoords{$r[1]} ; 

	$dagchainer{$r[0]}{$r[5]} = "$r[1]\t$qryleft\t$qryright\t$refleft\t$refright\t$r[2]" ; 

    }

}
close(IN) ; 

foreach my $qryscaff ( @list ) {

    for my $order ( sort {$b<=>$a} keys %{ $dagchainer{$qryscaff} } ) {
	print "$qryscaff\t$order\t$dagchainer{$qryscaff}{$order}\n" ; 

    }



}

