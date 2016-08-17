#!/usr/bin/perl -w
use strict;







if (@ARGV != 2) {
    print "$0 emu.aa.fa tmhmm.result \n" ;
    exit ;
}

my $file = shift ;
my $tmhmmfile = shift ;


my %fasta = () ;
my %tmhmm = () ;

open (IN, "$file") or die "ooops\n" ;
while (<IN>) {

    if (/>(\S+)/ ) {

        my $name = $1 ;
        my $seq = <IN> ;

        $fasta{$name} = $seq ;
    }

}
close(IN) ;



open (IN, "$tmhmmfile") or die "ooops!\n" ;

while (<IN>) {
    next if /^\#/ ;
    chomp ;

    my @r = split /\s+/, $_ ;

    if ( /TMhelix/ ) {
	$tmhmm{$r[0]}++ ;
    }

}
close(IN) ;


my $multiple = 0 ;
my $excluded = 0 ;

for my $gene (sort keys %fasta ) {

#    print "$gene" ;


    if ( $tmhmm{$gene}  ) {

        print "$gene\t$tmhmm{$gene}\n" ;

    }
    else {

        if ( $fasta{$gene} ) {
            print "$gene\t0\n" ;
        }
        else {
            print "$gene not found!\n" ;

        }
    }


}

