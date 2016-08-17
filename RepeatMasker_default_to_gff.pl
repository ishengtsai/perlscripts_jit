#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV != 2) {
	print "RepeatMasker_default_to_gff.pl RMoutput gff\n\n" ;
	exit ;
}

my $filenameA = shift @ARGV;
my $out = shift @ARGV;


open (IN, "$filenameA") or die "oops!\n" ;
open OUT, ">" , "$out" or die "oops out!\n" ;

print OUT "\#\#gff-version3\n" ;

while (<IN>) {

# gff is like this
##gff-version 3
#ctg123  .  exon  1300  1500  .  +  .  ID=exon00001
# detail at http://gmod.org/wiki/GFF


# repeat masker output like this
#824 10.17 0.00 0.00 Schisto_mansoni.Chr_1 1 118 (65488065) R=37 2369 2486 (2307) 5
# or
#2080 13.02 0.59 0.29 Schisto_mansoni.Chr_1 153 491 (65487692) C R=37 (2396) 2397 2058 5

    next if /^\n/ ; 
    chomp ;
s/^\s+//g; 

my @line = split /\s+/ , $_ ;


next if $line[0] =~ /\#/ ;
next if $line[0] =~ /\D+/ ;


if ($line[8] eq 'C') {
	print OUT "$line[4]\tRepeatmasker\trepeat\t$line[5]\t$line[6]\t$line[1]\t-\t.\tTarget \"Motif:$line[9]\" perc.div:$line[1]\n" ;

}
else {
	print OUT "$line[4]\tRepeatmasker\trepeat\t$line[5]\t$line[6]\t$line[1]\t+\t.\tTarget \"Motif:$line[9]\" perc.div:$line[1]\n" ;
}

}


