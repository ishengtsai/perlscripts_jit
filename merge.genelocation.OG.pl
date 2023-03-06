#!/usr/bin/perl -w
use strict;







if (@ARGV != 2) {
    print "$0 gene.location inOGfile\n" ; 
    exit ;
}

my $fileLocation = shift ;
my $fileOG = shift ;

my $count = 1 ;

my %OG = () ;

open OUT, ">", "$fileLocation.withLocation.txt" or die "cansdolkalsdjalksdjkal\n" ; 

open (IN, "$fileOG") or die "oops!\n" ;
while (<IN>) {

    chomp ;
    next if /^\#/ ;

    my @r = split /\s+/ ;

    $OG{$r[0]}{$r[1]} = $r[2] ; 

    $count++ ;

}
close(IN) ;




open (IN, "$fileLocation") or die "oops!\n" ;

while (<IN>) {
    chomp ;
    next if /^\#/ ;
    my @r = split /\s+/ ;

    my @gene = split /\|/, $r[0] ; 

    if ( $OG{$gene[0]}{$gene[1]} ) {

	$r[4] =~ s/\+/1/ ;
	$r[4] =~ s/\-/-1/ ;
	
	#print OUT "$gene[0]\t$gene[1]\t$r[1]\t$r[2]\t$r[3]\t$r[4]\t$OG{$gene[0]}{$gene[1]}\n" ;
	print OUT "$gene[0]\t$OG{$gene[0]}{$gene[1]}\t$r[2]\t$r[3]\t$r[4]\t$r[1]\tblack\tlightgrey\tarrows\n" ; 
	
    }
    else {
	#print OUT "$gene[0]\t$gene[1]\t$r[1]\t$r[2]\t$r[3]\t$r[4]\tNA\n" ;
	print OUT "$gene[0]\tNA\t$r[2]\t$r[4]\t$r[3]\tblack\tlightgrey\tarrows\n" ;
	print "$gene[0]\t$gene[1] not found in $fileOG!\n" ; 
    }

    
}
close(IN) ;

close(OUT) ; 

print "$fileLocation.withLocation.txt done!\n" ; 
