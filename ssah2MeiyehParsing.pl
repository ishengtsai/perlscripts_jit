#!/usr/bin/perl -w
use strict;



if (@ARGV != 1) {
    print "$0 alnfile \n" ; 


	exit ;
}
my $file = shift @ARGV ; 

my $total = 0 ; 
my $map = 0 ; 

my %read = () ; 
my %mapped = () ; 

open (IN, "$file") or die "Daosdapda\n" ; 

open OUT, ">", "$file.unmapped" ; 
open HIST, ">", "$file.len.dist" ; 
open STATS, ">", "$file.stats" ; 


while (<IN>) {

    if ( /^Matches For Query \d+ \((\d+) bases\): (\S+)/ ) {
	print HIST "$2\t$1\n" ; 
	$read{$2} = $1 ; 
	$total++ ; 
    }

    next unless /^ALIGNMENT/ ; 
    $map++ ; 

    chomp; 
    my @READ = split /\s+/, $_ ; 

    #print "$_\n" ; 

    $mapped{$READ[2]}++ ; 
    my $proportion =  sprintf("%.3f", $READ[9]/$READ[11] ) ; 
    print STATS "$READ[9]\t$READ[10]\t$proportion\n" ; 



}
close(IN) ; 

for (keys %read) {

    if ( $mapped{$_} ) {

    }
    else {
	print OUT "$_\t$read{$_}\n" ; 
    }

}


print "Total: $total\n" ; 
print "Map: $map\n" ; 




sub modifycigar {

    my $cigar = shift ; 
    $cigar =~ s/\d+D//gi ; 
    $cigar =~ s/I/M/gi ; 

    if ( $cigar =~ /^\d+M\d+S$/ ) {
	return $cigar ; 
    }

    while ( $cigar =~ /(\d+)M(\d+)M/ ) {
	my $total = $1 + $2 ; 
	my $replace = $total . "M" ; 
	$cigar =~ s/\d+M\d+M/$replace/ ; 
    }
    while ( $cigar =~ /(\d+)S(\d+)M/ ) {
	my $total = $1 + $2 ; 
	my $replace = $total . "M" ; 
	$cigar =~ s/\d+S\d+M/$replace/ ; 
    }

    if ( $cigar =~ /^\d+M\d+S/ || $cigar=~ /^\d+M$/ ) {

    }
    else {
	print "erm!!! $cigar\n" ; 
	exit ; 
    }

    return $cigar ; 
}



