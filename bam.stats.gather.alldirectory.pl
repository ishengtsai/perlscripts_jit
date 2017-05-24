#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


#if (@ARGV != 1) {
#    print "$0 directory \n" ;
#    exit ;
#}

print "$0\n printing bam files...\n" ; 

print "Directory\tFile\tTotalReads\tMappedReads\tMappedReads(%)\tForwardStrand\tForwardStrand(%)\tReverseStrand\tReverseStrand(%)\tFailedQC\tFailedQC(%)\tDuplicates\tDuplicates(%)\tPE\tPE(%)\tProper-pairs\tProper-pairs(%)\tBothMapped\tBothMapped(%)\tSingletons\tSingletons(%)\tAverageInsert(bp)\tMedianInsert(bp)\n" ; 

my @dirs = grep { -d } glob '*';

foreach my $directory (@dirs) {

opendir (DIR, $directory) or die $!;

while (my $file = readdir(DIR)) {

    next unless $file =~ /.bam.stats/ ; 
#    print "$file!!!\n" ;

    print "$directory\t$file\t";

    open (IN, "$directory/$file") or die $! ; 

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
}

}
