#!/usr/bin/env perl

use strict;
use warnings;
use File::Spec;



my $PI = `echo $$` ;    chomp($PI) ;

#debug 
my $debug = 0 ; 

if (@ARGV != 2) {
    print STDERR "usage: $0 input outputprefix \n" ; 
    print STDERR "This is for Tsai's T1D data \n" ; 

    exit(1);
}

my $ref = "/home/ishengtsai/db/hg19/ucsc.hg19.fasta" ;
#my $ref = "/home/ishengtsai/db/hg19/hg19.fa" ; 
my $picardpath = "/home/ishengtsai/bin/picard-tools-1.107/" ; 
#my $gatkjar = "/home/ishengtsai/bin/GenomeAnalysisTK-2.7-2-g6bda569/GenomeAnalysisTK.jar" ;  
my $gatkjar = "/home/ishengtsai/bin/GATK3.3.0/GenomeAnalysisTK.jar" ; 

my $input = shift ; 
my $output = shift ; 
#my $cpu = shift ; 

#java set
system("java -Xmx6g -version ; ulimit -v 20000000 ") ; 


#sam to bam
system_call("java -Xmx6g -jar $picardpath/SortSam.jar VALIDATION_STRINGENCY=LENIENT SORT_ORDER=coordinate INPUT=$input OUTPUT=$output.withoutH.bam CREATE_INDEX=true") ; 

#add headers
system_call("java -Xmx6g -jar $picardpath/AddOrReplaceReadGroups.jar INPUT=$output.withoutH.bam OUTPUT=$output.bam SORT_ORDER=coordinate RGID=$output RGLB=$output RGPL=illumina RGSM=T1D$output RGPU=T1D$output CREATE_INDEX=true") ; 

#system_call("java -Xmx6g -jar $picardpath/ReorderSam.jar INTPUT=$output.withH.bam OUTPUT=$out.bam 

#mark duplicates
#ignored
#system_call("java -Xmx6g -jar $picardpath/MarkDuplicates.jar INPUT=$output.bam OUTPUT=$output.markdup.bam METRICS_FILE=metrics CREATE_INDEX=true VALIDATION_STRINGENCY=LENIENT") ; 

#stats
#system_call("~/bin/bamtools/bin/bamtools stats -in $output.markdup.bam > $output.markdup.bam.stats") ;
#system_call("~/bin/bamtools/bin/bamtools stats -in $output.bam > $output.bam.stats") ; 

#indel calling
#system_call("java -Xmx6g -jar $gatkjar -T RealignerTargetCreator -R $ref -I $output.bam -o $output.bam.indel.list") ; 


# local realignment
#system_call("java -Xmx6g -jar $gatkjar -T IndelRealigner -targetIntervals $output.bam.indel.list -R $ref -I $output.bam -o $output.realigned.bam") ; 

# base recalibration
#system_call("java -Xmx6g -jar $gatkjar -T BaseRecalibrator -I $output.bam -R $ref -knownSites /home/ishengtsai/db/hg19/dbsnp_138.hg19.vcf -o $output.recal_data.table") ; 

# print recalibrated bam
#system_call("java -Xmx6g -jar $gatkjar -T PrintReads -I $output.bam -R $ref -BQSR $output.recal_data.table -o $output.recalibrated.bam") ; 

# call SNPs!
#system_call("java -Xmx6g -jar $gatkjar -T HaplotypeCaller -R $ref -I $output.markdup.realigned.bam -L 20 --genotyping_mode DISCOVERY -stand_emit_conf 10 -stand_call_conf 30 -o $output.raw_variants.vcf


# usage: system_call(string)
# Runs the string as a system call, dies if call returns nonzero error code
sub system_call {
    my $cmd  = shift;
    print "$cmd\n";
    system($cmd) ; 

}
