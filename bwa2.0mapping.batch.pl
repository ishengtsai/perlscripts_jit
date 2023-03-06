#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV != 4) {
    print "$0 directory testmode[yes==1] Numcore ref \n" ;
    print "lookign for *_1.fp.fastq.gz Fastp gzipped files\n" ; 
    print "need index with /home/ijt/bin/bwa-mem2-2.0pre2_x64-linux/bwa-mem2 index ref.fa first!\n" ; 
    exit ;
}

my $directory = shift @ARGV;
my $testmode = shift @ARGV ;
my $cpucore = shift @ARGV ;
my $ref = shift @ARGV ; 

opendir (DIR, $directory) or die $!;



while (my $file = readdir(DIR)) {

    next unless $file =~ /_1.fp.fastq.gz$/ ;

    


    my $name = $file ;

    # Quick hack for muscovy duck
    my $ID ; 



    #PD01B_trim_R1.fastq.gz
    
    if ( $name =~ /^(\S+)_1.fp.fastq.gz/ ) {
        $ID = "$1" ;
	$name = "$1" ;
    }


    print "name: $name\nID: $ID\n" ;



    my $command = "runBWA2.0PE.sh $ID $ID\_1.fp.fastq.gz $ID\_2.fp.fastq.gz $ref $cpucore" ; 

	

    
    print "$command\n\n" ;
    system("$command") if $testmode == 0 ;
    

    
    
}
