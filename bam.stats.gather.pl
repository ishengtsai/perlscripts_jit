#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV != 1) {
    print "$0 directory \n" ;
    exit ;
}

my $directory = shift @ARGV;


opendir (DIR, $directory) or die $!;

#print "directory\tSample_name\tTotal_reads\tMapped_reads\tMapped_reads(%)\n" ; 


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

