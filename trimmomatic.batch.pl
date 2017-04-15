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



while (my $file = readdir(DIR)) {

    next unless $file =~ /_R1.fastq.gz/ ;
    next if $file =~ /trim/ ; 
#    print "$file!!!\n" ;

    my $name = $file ;
    my $ID ; 

    #LTS16_JY34_402bp_CGGCTATG-CCTATCCT_L001_R2.fastq.gz
    
    if ( $name =~ /^(\w+\d+)_(\w+\d+)(.+)_R1.fastq.gz/ ) {
        $ID = "$1_$2" ;
	$name = "$1_$2$3" ; 
    }




    print "name: $name\nID: $ID\n" ;

    my $command = "java -jar /home/ijt/bin/Trimmomatic-0.36/trimmomatic-0.36.jar PE -threads 32 " . 
    	"$name" . "_R1.fastq.gz" .   " $name" . "_R2.fastq.gz " . "$name\_trim_R1.fastq.gz $name\_trim_up_R1.fastq.gz $name\_trim_R2.fastq.gz $name\_trim_up_R2.fastq.gz " . 
	" ILLUMINACLIP:/home/ijt/bin/Trimmomatic-0.36/adapters/TruSeq3-PE-2.fa:2:30:10 LEADING:20 TRAILING:20 SLIDINGWINDOW:4:20 MINLEN:50" ;  

    print "$command\n" ;
    system("$command") ;
    
    
}
