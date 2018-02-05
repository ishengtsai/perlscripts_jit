#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV != 2) {
    print "$0 directory test_mode\n" ;
    print "test_mode == 1 print command only ; test_mode == 0 execute!\n" ; 
    exit ;
}

my $directory = shift @ARGV;
my $test_mode = shift @ARGV ; 

opendir (DIR, $directory) or die $!;



while (my $file = readdir(DIR)) {

    next unless $file =~ /_R1.fastq.gz/ ;
    next if $file =~ /trim/ ; 
#    print "$file!!!\n" ;

    my $name = $file ;
    my $ID ; 

    #LTS16_JY34_402bp_CGGCTATG-CCTATCCT_L001_R2.fastq.gz
    #LTS17_LZ20_377bp_GTTTCG_L001_R2.fastq.gz

    
    if ( $name =~ /^(\w+\d+)_(\w+\d+)(_.+)_R1.fastq.gz/ ) {
        $ID = "$1_$2" ;
	$name = "$1_$2$3" ; 
    }




    print "name: $name\nID: $ID\n" ;

    my $command = "java -jar /home/ijt/bin/Trimmomatic-0.36/trimmomatic-0.36.jar PE -threads 32 " . 
    	"$name" . "_R1.fastq.gz" .   " $name" . "_R2.fastq.gz " . "$ID\_trim_R1.fastq.gz $ID\_trim_up_R1.fastq.gz $ID\_trim_R2.fastq.gz $ID\_trim_up_R2.fastq.gz " . 
	" ILLUMINACLIP:/home/ijt/bin/Trimmomatic-0.36/adapters/TruSeq3-PE-2.fa:2:30:10 LEADING:20 TRAILING:20 SLIDINGWINDOW:4:20 MINLEN:50" ;  

    print "$command\n" ;
    system("$command") if $test_mode == 0 ;
    
    
}
