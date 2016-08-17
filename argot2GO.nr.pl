#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV != 2) {
    print "$0 merged.output parsed.out.file\n" ; 
    exit ;
}

my $file = shift ; 
my $out = shift ; 

open OUT, ">", "$out" or die "oooop!\n" ; 

open (IN, "$file") or die "can't openfile: $!\n" ; 

my %GOterms = (); 

while (<IN>) {
    next if /^Sequence/ ; 

    chomp; 
    my @r = split /\s+/, $_ ; 

    if ( $r[0] =~ /\S+\.(\d+)$/ ) {
	next if $1 > 1 ; 
    }

    if ( $GOterms{"$r[0]"} ) {
	$GOterms{"$r[0]"} .= ",$r[2]" ; 
    }
    else {
	$GOterms{"$r[0]"} = "$r[2]" ;
    }
    


}

for my $gene ( sort keys %GOterms ) {
    print OUT "$gene $GOterms{$gene}\n" ; 
}


print "all done! a non redundant GO file: $out is produced\n" ; 

