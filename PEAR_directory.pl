#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV != 2) {
    print "$0 Inputdirectory outputDIR\n" ;
    exit ;
}

my $directory = shift ; 
my $outputdir = shift ;

print "$0\n doing PEAR on the current directory.....\n" ;
print "outputDIR will be $outputdir\n" ;


opendir (DIR, $directory) or die $!;


my $name = '' ;
my %samples = () ; 
    
while (my $file = readdir(DIR)) {

    if ( $file =~ /GI(\d+)/ ) {
	$name = $1 ;
    }
    if ($file =~ /R1/ ) {
	$samples{$name}{'R1'} = $file ; 
    }
    if ($file =~ /R2/ ) {
	$samples{$name}{'R2'} = $file ;
    }

}

    
my $count = 1 ; 

for my $name (sort keys %samples ) {
    
    #print "$directory\n";

    
    mkdir("$outputdir") ;
    mkdir("$outputdir.bak") ;
    print "command: /home/ishengtsai/bin/pear-0.9.6-bin-64/pear-0.9.6-bin-64 -f $directory/$samples{$name}{'R1'} -r $directory/$samples{$name}{'R2'} -o $outputdir.bak/$count -q 10 -j 8 \n" ;
    #system("/Users/ishengtsai/bin/pear-0.9.6-src/src/pear -f $directory/$forward -r $directory/$reverse -o $outputdir.bak/$ID -q 10") ;    
    print "command: /home/ishengtsai/bin/cutadapt/bin/cutadapt -a CTGTCTCTTATACACATCT -o $outputdir/$count\_R1_001.fastq $outputdir.bak/$count.assembled.fastq -m 60 \n" ; 

    system("/home/ishengtsai/bin/pear-0.9.6-bin-64/pear-0.9.6-bin-64 -f $directory/$samples{$name}{'R1'} -r $directory/$samples{$name}{'R2'} -o $outputdir.bak/$count -q 10 -j 8 ") ; 
    system("/home/ishengtsai/bin/cutadapt/bin/cutadapt -a CTGTCTCTTATACACATCT -o $outputdir/$count\_R1_001.fastq $outputdir.bak/$count.assembled.fastq -m 60") ; 

    
    $count++ ;
    #last if $count == 5 ;


}
