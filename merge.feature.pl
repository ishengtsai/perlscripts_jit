#!/usr/bin/perl -w
use strict;







if (@ARGV != 2) {
    print "$0 ChrALL.nuc gene.density.window.gff \n" ; 
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

    my @r = split /\s+/ ;

    my $windownum = $r[8] ;
    my $midpoint = $r[3] + ( ( $r[4] - $r[3] ) / 2 ) ;

    $chrpos{$windownum} = "$r[0]\t$midpoint\t$r[3]\t$r[4]" ;
    $feature{$windownum}{'GC'} = $r[10] ;

    $count++ ;

}
close(IN) ;




open (IN, "$filetwo") or die "oops!\n" ;
while (<IN>) {
    chomp ;
    next if /^\#/ ;
    my @r = split /\s+/ ;
    my $windownum = $r[8] ;

    $feature{$windownum}{'GENE'} = $r[12] ;

}
close(IN) ;


for (my $i = 1 ; $i < $count ; $i++ ) {

    print "$chrpos{$i}\t$feature{$i}{'GC'}\t$feature{$i}{'GENE'}\t$i\n" ; 


}
