#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV != 1) {
    print "$0 file \n" ;
    exit ;
}

my $file = shift ; 



open (IN, "$file") or die $! ; 

while (<IN>) {
    
    if (/Number of read pairs:\s+(\d+)/ ) {
	print "$1\t" ; 
    }
    if (/Number of duplicate pairs:.+\s+(\d+\.\d+) \%/) {
	print "$1\t" ; 
    }
    if (/Total pairs in category A:.+\s+(\d+\.\d+) \%/) {
	print "$1\t" ; 
    }
    if (/A pairs long enough:.+\s+(\d+\.\d+) \%/) {
        print "$1\t" ;
    }
    if (/Total pairs in category B:.+\s+(\d+\.\d+) \%/) {
	print "$1\t" ;
    }
    if (/B pairs long enough:.+\s+(\d+\.\d+) \%/) {
        print "$1\t" ;
    }
    if (/Total pairs in category C:.+\s+(\d+\.\d+) \%/) {
	print "$1\t" ;
    }
    if (/C pairs long enough:.+\s+(\d+\.\d+) \%/) {
        print "$1\t" ;
    }
    if (/Total pairs in category D:.+\s+(\d+\.\d+) \%/) {
	print "$1\t" ;
    }
    if (/D pairs long enough:.+\s+(\d+\.\d+) \%/) {
        print "$1\t" ;
    }
    if (/Total usable pairs:.+\s+(\d+\.\d+) \%/) {
	print "$1\t" ;
    }
    if (/All long enough:.+\s+(\d+\.\d+) \%/) {
	print "$1\t" ;
    }
    if (/All categories too short:.+\s+(\d+\.\d+) \%/) {
        print "$1\t" ;
    }

    


    
    
}
print "\n" ; 

close(IN) ; 




