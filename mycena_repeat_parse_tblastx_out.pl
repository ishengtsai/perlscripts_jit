#!/usr/bin/perl -w
use strict;
use warnings;






if (@ARGV < 2) {
    print "$0 tblastx.out percentQueryCovered\n" ; 
	exit ;
}

my $file = $ARGV[0] ;
my $covered = $ARGV[1] ; 

open OUT, ">", "$file.parsed" or die "13o1p23o1po\n" ; 



my %query = () ;


open (IN, "$file") or die "oops!\n" ;

#Mycchl.rnd-3_family-918#Unknown Mc.scaff0011.772874-778283#LTR  76.471  17      4       0       293     343     4087    4037    1.95e-05        35.0    44      5


while (<IN>) {
    chomp ; 
    my @r = split /\s+/, $_ ; 
    my $type = '' ; 
    if ( $r[1] =~ /\#(.+)$/ ) {
	$type = $1 ; 
    }

    next if $r[12] < $covered ; 
    
    if ( $query{$r[0]} ) {
	next ; 
    }
    else {
	$query{$r[0]} = "$type\t$r[2]\t$r[12]" ; 
    }

}

for my $name (sort keys %query) {
    print OUT "$name\t$query{$name}\n" ; 
}

print "done! $file.parsed produced!\n" ; 
