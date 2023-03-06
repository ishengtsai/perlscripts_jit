#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV != 3) {
    print "$0 directory test_mode char\n" ;
    print "test_mode == 1 print command only ; test_mode == 0 execute!\n" ;
    print "Char: usually - or _ \n" ; 
    exit ;
}

my $directory = shift @ARGV;
my $test_mode = shift @ARGV ; 
my $char = shift @ARGV ; 

opendir (DIR, $directory) or die $!;



while (my $file = readdir(DIR)) {

    next unless $file =~ /_R1.fastq.gz/ ;
    next if $file =~ /trim/ ; 
#    print "$file!!!\n" ;

    my $name = $file ;
    my $ID ; 

    #LTS16_JY34_402bp_CGGCTATG-CCTATCCT_L001_R2.fastq.gz
    #LTS17_LZ20_377bp_GTTTCG_L001_R2.fastq.gz


    #LTS18-NK05_358bp_CTGAAGCT-AGGCGAAG_L003_R1.fastq.gz
    #LTS18_NK52_354bp_AGCGATAG-TAATCTTA_L002_R1.fastq.gz
    #LTS18_NK32A_341bp_GAATTCGT-GGCTCTGA_L002_R1.fastq.gz
    if ( $name =~ /^(\w+\d+)$char(\w+\d+\w*)(_\d+bp_.+_L)(\d+)_R1.fastq.gz/ ) {
        $ID = "$1-$2$char$4" ;
	$name = "$1$char$2$3$4" ; 
    }




    print "name: $name\nID: $ID\n" ;

    my $command = "java -jar /home/ijt/bin/Trimmomatic-0.36/trimmomatic-0.36.jar PE -threads 32 " . 
    	"$name" . "_R1.fastq.gz" .   " $name" . "_R2.fastq.gz " . "$ID\_t_R1.fastq.gz $ID\_t_up_R1.fastq.gz $ID\_t_R2.fastq.gz $ID\_t_up_R2.fastq.gz " . 
	" ILLUMINACLIP:/home/ijt/bin/Trimmomatic-0.36/adapters/TruSeq3-PE-2.fa:2:30:10 LEADING:20 TRAILING:20 SLIDINGWINDOW:4:20 MINLEN:50" ;  

    print "$command\n" ;
    system("$command") if $test_mode == 0 ;
    
    
}
