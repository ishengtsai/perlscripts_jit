#!/usr/bin/env perl

use strict;
use warnings;
use File::Spec;



my $PI = `echo $$` ;    chomp($PI) ;

#debug 
my $debug = 0 ; 


# all the memory requirements... 
#my $indexram = 5 ; 
#my $mergeram = 30 ; 





if (@ARGV != 3) {
    print STDERR "usage: $0 ref noPCR_lane ram\n" ; 
    print STDERR "\n" ; 

    exit(1);
}

my $ref = shift ; 
my $lane = shift ; 
my $ram = shift ; 




# generate lane
open OUT, ">", "noPCR.Gapfiller.lib" or die "ooops\n" ; 

if ( -e "$lane\_1.fastq.gz" ) {
    
    print OUT "lib bowtie $lane\_1.fastq.gz $lane\_2.fastq.gz 450 0.3 FR\n" ; 
    close(OUT); 
    
}
else {

    print OUT "lib bowtie $lane\_1.fastq $lane\_2.fastq 450 0.3 FR\n" ;
    close(OUT);

}

# submit Gapfiller
my $bjob_command = "qsub.pl hdd $ram gapfiller 1 \" perl /home/ishengtsai/bin/GapFiller_v1-11_linux-x86_64/GapFiller.pl -l noPCR.Gapfiller.lib -s $ref  -b noPCRGapfilled \" "; 



system_call("$bjob_command\n") ;


# usage: system_call(string)
# Runs the string as a system call, dies if call returns nonzero error code
sub system_call {
    my $cmd  = shift;
    print "$cmd\n";
    if (system($cmd)) {
        print STDERR "Error in system call:\n$cmd\n";
        exit(1);
    }
}
