#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV != 2) {
    print "$0 directory testmode \n" ;
    exit ;
}

my $directory = shift @ARGV;
my $testmode = shift @ARGV ; 

opendir (DIR, $directory) or die $!;



while (my $file = readdir(DIR)) {

    next unless $file =~ /_trim_R1.fastq.gz$/ ;

    


    my $name = $file ;

    # Quick hack for muscovy duck
    my $ID ; 


    #LTS17_LZ01_trim_R1.fastq.gz
    
    if ( $name =~ /^(\w+\d+)_(\w+\d+)_trim_R1.fastq.gz/ ) {
        $ID = "$2" ;
	$name = "$1_$2" ;
    }


    print "name: $name\nID: $ID\n" ;



    my $command = "/home/ijt/bin/STAR-2.5.3a/bin/Linux_x86_64/STAR --runThreadN 32 --genomeDir ref_star_index --readFilesCommand gunzip -c " .
	    "--outFilterMatchNminOverLread 0.4  --outFilterScoreMinOverLread 0.4 --outFileNamePrefix mapping_star_$ID.pe   " .
	    "--readFilesIn " . "$name" . "_trim_R1.fastq.gz " . 
	    "$name" . "_trim_R2.fastq.gz"   ; 

	

    
    print "$command\n\n" ;
    system("$command") if $testmode == 0 ;
    

    
    
}
