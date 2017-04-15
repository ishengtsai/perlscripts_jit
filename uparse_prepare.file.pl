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


my $total = 0 ; 

while (my $file = readdir(DIR)) {

    #LGL16_KX01_03_CGAGAGTT-AGAGTCAC_L001_R1.fastq.gz
    
    next unless $file =~ /_R1.fastq.gz/ ;
#    print "$file!!!\n" ;

    my $name = $file ;

    if ( $name =~ /(\S+)_R1.fastq.gz/ ) {
        $name = $1 ;
    }


    my $SAM = $name ;


    my $finalsample ;
    if ( $SAM =~ /LGL16_(\S+)_(\d+)_\w+-\w+_L\d+/ ) {
	$finalsample = "$1$2" ; 
    }

    my $command = "cp $name\_R1.fastq.gz $finalsample\_R1.fastq.gz ; cp $name\_R2.fastq.gz $finalsample\_R2.fastq.gz ; " ; 
    
    print "$command\n" ;
    system("$command") ; 

    $command = "gunzip $finalsample\_R1.fastq.gz  ; gunzip $finalsample\_R2.fastq.gz " ;
    print "$command\n" ;
    system("$command") ;

    $command = "rm $name\_R1.fastq.gz  ; rm $name\_R2.fastq.gz " ;
    print "$command\n" ;
    system("$command") ;

    $total++ ; 
}


print "total $total samples processed\n" ; 
