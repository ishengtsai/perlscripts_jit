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

    #KX0208_output_file1.fastq
    
    next unless $file =~ /_R1.fastq/ ;
#    print "$file!!!\n" ;

    my $name = $file ;

    if ( $name =~ /(\S+)_R1.fastq.gz/ ) {
        $name = $1 ;
    }


    my $SAM = $name ;

#    print "$SAM\n" ;

    #my $command = "java -classpath /usr/local/bin/trimmomatic-0.33.jar org.usadellab.trimmomatic.TrimmomaticPE -phred33 $SAM\_R1.fastq.gz $SAM\_R2.fastq.gz $SAM" . 
    #	"_CL_1.fastq.gz" . " $SAM" . "_CL_1.up.fastq.gz" . " $SAM" . "_CL_2.fastq.gz" . 
    #	" $SAM" . "_CL_2.up.fastq.gz ILLUMINACLIP:/home/ijt/bin/illumina_adaptors1.fa:2:$qual:10 LEADING:$qual TRAILING:$qual SLIDINGWINDOW:4:$qual MINLEN:50" ;


    my $finalsample ;

    #LGL16_JS01_3_CGAGAGTT-AGAGTCAC_L001_R1.fastq.gz
    if ( $SAM =~ /LGL16_(JS\S+)_(\d+)/ ) {
	$finalsample = "$1$2" ; 
    }

    # 18 samples
    #LGL17_LP01_73_CTCGACTT-AGAGTCAC_L001_R1.fastq.gz
    if ( $SAM =~ /LGL17_(LP\S+)_(\d+)/ ) {
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
