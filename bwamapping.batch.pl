#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV != 4) {
    print "$0 directory testmode Numcore ref \n" ;
    exit ;
}

my $directory = shift @ARGV;
my $testmode = shift @ARGV ;
my $cpucore = shift @ARGV ;
my $ref = shift @ARGV ; 

opendir (DIR, $directory) or die $!;



while (my $file = readdir(DIR)) {

    next unless $file =~ /_trim_R1.fastq.gz$/ ;

    


    my $name = $file ;

    # Quick hack for muscovy duck
    my $ID ; 



    #PD01B_trim_R1.fastq.gz
    
    if ( $name =~ /^(\S+)_trim_R1.fastq.gz/ ) {
        $ID = "$1" ;
	$name = "$1" ;
    }


    print "name: $name\nID: $ID\n" ;



    my $command = "runBWAPE.sh $ID $ID\_trim_R1.fastq.gz $ID\_trim_R2.fastq.gz $ref $cpucore" ; 

	

    
    print "$command\n\n" ;
    system("$command") if $testmode == 0 ;
    

    
    
}
