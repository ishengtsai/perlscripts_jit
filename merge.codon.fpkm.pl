#!/usr/bin/perl -w
use strict;







if (@ARGV != 2) {
    print "$0 fpkm ENc.GC3 \n" ; 
    exit ;
}

my $fileone = shift ;
my $filetwo = shift ;

my $count = 1 ;

my %feature = () ;
my %chrpos = () ;


open (IN, "$fileone") or die "oops!\n" ;
while (<IN>) {

    chomp ;
    next if /^\#/ ;
    next if /^tracking/ ; 


    my @r = split /\s+/ ;


    $feature{$r[0]}{'fpkm'} = $r[1] ;
    $count++ ;

}
close(IN) ;


open (IN, "$filetwo") or die "oops!\n" ;
while (<IN>) {
    chomp ;
    next if /^\#/ ;
    next if /^title/ ; 
    my @r = split /\s+/ ;


    $feature{$r[0]}{'NC'} = $r[1] ;
    $feature{$r[0]}{'GC3'} = $r[2] ;

}
close(IN) ;


for my $gene ( sort keys %feature ) {



    if ( $feature{$gene}{'NC'} && $feature{$gene}{'GC3'} ) {
	next unless $feature{$gene}{'fpkm'} ; 
	next if $feature{$gene}{'NC'} =~ /\*/ ;
	next if $feature{$gene}{'GC3'} =~ /\*/ ;
	#print STDERR "$gene\n" ; 
	print "$gene\t$feature{$gene}{'fpkm'}\t$feature{$gene}{'NC'}\t$feature{$gene}{'GC3'}\n" ; 
    }
    else {
	#print STDERR "$gene not found!\n" ; 
    }

}
