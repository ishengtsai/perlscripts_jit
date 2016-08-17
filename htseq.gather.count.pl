#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';

if (@ARGV != 3) {
    print "$0 gtf directory prefix\n" ;


    exit ;
}

my $gtf = shift ; 
my $directory = shift ; 
my $prefix = shift ; 

open OUT, ">", "$prefix.withgenelen.genematrix" or die "doasodpad\n" ; 
open OUT2, ">", "$prefix.genematrix" or die "doasodpad\n" ;


my %genelen = () ; 

open (IN, "$gtf") or die "dadoapdao\n" ; 
while (<IN>) {

    chomp; 
    my @r = split /\s+/, $_ ; 
    my $len  = $r[4] - $r[3] + 1 ; 

    if (/gene_id \"(\S+)\"/ ) {
	$genelen{$1} += $len ; 
    }


}
close(IN) ; 


opendir (DIR, "$directory") or die $!;

my %conditions = () ;
my @condName = () ;  
my %genes = () ; 

while (my $file = readdir(DIR)) {

    next unless $file =~ /.count$/ ; 
#    print "$file!!!\n" ;

    my $condition = '' ; 
    if ( $file =~ /(\S+).count/ ) {
	$condition = $1 ; 
	$condition =~ s/-/./gi ; 
    }
    push(@condName, $condition) ; 

    open (IN, "$directory/$file") or die $! ; 

    while (<IN>) {
	next if /^__/ ; 

	chomp; 
	my @r = split /\s+/, $_ ; 
	$conditions{$condition}{$r[0]} = "$r[1]" ; 
	$genes{$r[0]}++ ; 


    }
    close(IN) ; 


}

local $" = "\t";

print OUT "gene\tgene_len\t@condName\n" ; 
print OUT2 "gene\t@condName\n" ;

for my $gene (sort keys %genes ) {

    print OUT "$gene\t$genelen{$gene}" ; 
    print OUT2 "$gene" ;

    foreach ( @condName ) {

	if ( $conditions{$_}{$gene} ) {
	    print OUT "\t$conditions{$_}{$gene}" ; 
	    print OUT2 "\t$conditions{$_}{$gene}" ;
	}
	else {
	    print OUT "\t0" ; 
	    print OUT2 "\t0" ;
	}

    }

    print OUT "\n" ; 
    print OUT2 "\n" ;

}

print "all done!\n" ; 
