#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV != 3) {
    print "$0 directory testmode Numcore \n" ;
    exit ;
}

my $directory = shift @ARGV;
my $testmode = shift @ARGV ;
my $cpucore = shift @ARGV ;

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



    my $command = "runSmaltPE.sh $ID $ID\_trim_R1.fastq.gz $ID\_trim_R2.fastq.gz $cpucore" ; 

	

    
    print "$command\n\n" ;
    system("$command") if $testmode == 0 ;
    

    
    
}
