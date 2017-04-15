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

    next unless $file =~ /_1.fastq.gz/ ;
#    print "$file!!!\n" ;

    my $name = $file ;
    my $ID ; 
    
    if ( $name =~ /^(\w+\d+)_(\w+\d+)(.+)CL_1.fastq.gz/ ) {
        $ID = "$1_$2" ;
	$name = "$1_$2$3" ; 
    }




    print "name: $name\nID: $ID\n" ;

    my $command = "hisat2 --dta --rna-strandness FR -p 8 -q -x ref -1 " . 
    	"$name" . "CL_1.fastq.gz" .   " -2 $name" . "CL_2.fastq.gz -S $ID.sam " ;  

    #print "$command\n" ;
    #system("$command") ;

    #$command = 'samtools view -@ 8 -bt ref.fa.len.txt -o ' . "$ID.bam $ID.sam" ;
    #print "$command\n" ;
    #system("$command") ;
    
    
    #$command = 'samtools sort -@ 8  -o ' . "$ID.sorted.bam $ID.sam" ;
    #print "$command\n" ; 
    #system("$command") ;
    
    #$command = "bamtools index -in $ID.sorted.bam ; bamtools stats -in $ID.sorted.bam -insert > $ID.sorted.bam.stats" ; 
    #print "$command\n" ; 
    #system("$command") ;


    $command = "stringtie -p 16 -o $ID.sorted.bam.gtf -l $ID $ID.sorted.bam" ; 
    print "$command\n\n" ; 
    system("$command") ;
    
    
}
