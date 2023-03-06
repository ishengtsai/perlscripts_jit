#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV != 2) {
    print "$0 directory test_mode char\n" ;
    print "test_mode == 1 print command only ; test_mode == 0 execute!\n" ;
    exit ;
}

my $directory = shift @ARGV;
my $test_mode = shift @ARGV ; 


opendir (DIR, $directory) or die $!;



while (my $file = readdir(DIR)) {

    next unless $file =~ /_R1.fq.gz/ ;
    next if $file =~ /_t_/ ; 
#    print "$file!!!\n" ;

    my $name = $file ;
    my $ID ; 


    if ( $name =~ /^(\S+)_R1.fq.gz/ ) {
        $ID = "$1" ;
	$name = "$1" ; 
    }




    print "name: $name\n" ;

    my $command = "java -jar /home/ijt/bin/Trimmomatic-0.39/trimmomatic-0.39.jar PE -threads 32 " . 
    	"$name" . "_R1.fq.gz" .   " $name" . "_R2.fq.gz " . "$ID\_t_R1.fastq.gz $ID\_t_up_R1.fastq.gz $ID\_t_R2.fastq.gz $ID\_t_up_R2.fastq.gz " . 
	" ILLUMINACLIP:/home/ijt/bin/Trimmomatic-0.39//adapters/NexteraPE-PE.fa:2:30:10:2:keepBothReads LEADING:15 TRAILING:15 SLIDINGWINDOW:4:15 MINLEN:50" ;  

    print "$command\n\n\n" ;
    system("$command") if $test_mode == 0 ;
    
    
}
