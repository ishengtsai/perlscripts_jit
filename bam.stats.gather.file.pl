#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV != 1) {
    print "$0 file \n" ;
    exit ;
}

my $file = shift @ARGV;


print "File\tTotalReads\tMappedReads\tMappedReads(%)\tForwardStrand\tForwardStrand(%)\tReverseStrand\tReverseStrand(%)\tFailedQC\tFailedQC(%)\tDuplicates\tDuplicates(%)\tPE\tPE(%)\tProper-pairs\tProper-pairs(%)\tBothMapped\tBothMapped(%)\tSingletons\tSingletons(%)\tAverageInsert(bp)\tMedianInsert(bp)\n" ;

print "$file\t" ; 

    open (IN, "$file") or die $! ; 

    while (<IN>) {

        if (/Total reads:\s+(\d+)/ ) {
            print "$1\t" ; 
        }
        if (/(\d+)\s+\((\S+\%)\)$/ ) {
            print "$1\t$2\t" ; 
        }
        if (/\(absolute value\): (\S+)/ ) {
            print  "$1\t" ; 
        }


    }
    close(IN) ; 
    print "\n" ; 




