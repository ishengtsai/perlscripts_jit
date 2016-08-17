#!/usr/bin/env perl

use strict;
use warnings;
use File::Spec;



my $PI = `echo $$` ;    chomp($PI) ;

#debug 
my $debug = 0 ; 

if (@ARGV != 3) {
    print STDERR "usage: $0 input[out.sorted.markdup.bam] ref_prefix[ref] threads\n" ; 
    print STDERR "This is for icorn \n" ; 

    exit(1);
}



my $input = shift ; 
my $ref = shift ; 
my $cpu = shift ; 

my $gatkjar = '/home/ishengtsai/bin/GenomeAnalysisTK-3.1-1/GenomeAnalysisTK.jar' ; 

#java set
system("java -Xmx6g -version ; ulimit -v 20000000 ") ; 

#bwa
#my $bwacommand = "/home/ishengtsai/bin/bwa-0.7.7/bwa mem -t $cpu -M -R '\@RG\\tID:$output\\tLB:T1D\\tSM:$output\\tPL:ILLUMINA' $ref $input > $output.sam" ;

#system_call("$bwacommand") ; 

#sam to bam
#system_call("java -Xmx6g -jar $picardpath/SortSam.jar VALIDATION_STRINGENCY=LENIENT SORT_ORDER=coordinate INPUT=$output.sam OUTPUT=$output.bam CREATE_INDEX=true") ; 

#mark duplicates
#ignored
#system_call("java -Xmx6g -jar $picardpath/MarkDuplicates.jar INPUT=$output.bam OUTPUT=$output.markdup.bam METRICS_FILE=metrics CREATE_INDEX=true VALIDATION_STRINGENCY=LENIENT") ; 

#stats
#system_call("~/bin/bamtools/bin/bamtools stats -in $output.markdup.bam > $output.markdup.bam.stats") ;
#system_call("~/bin/bamtools/bin/bamtools stats -in $output.bam > $output.bam.stats") ; 

#samtools index
#system_call("~/bin/samtools-0.1.6_x86_64-linux/samtools faidx $ref") ; 

#create dict
#system_call("java -Xmx6g -jar /home/ishengtsai/bin/picard-tools-1.107/CreateSequenceDictionary.jar R=$ref.fa O=$ref.dict ") ; 

#assign readgroup
#system_call("java -Xmx6g -jar /home/ishengtsai/bin/picard-tools-1.107/AddOrReplaceReadGroups.jar INPUT=$input OUTPUT=$input.RG.bam RGLB=NORMAL RGPL=Illumina RGPU=0001 RGSM=ICORN ") ; 
#system_call("~/bin/samtools-0.1.6_x86_64-linux/samtools index $input.RG.bam") ; 

#indel calling
system_call("java -Xmx6g -jar $gatkjar -T RealignerTargetCreator -R $ref.fa -I $input.RG.bam -o $input.bam.indel.list -nt 32 &> out.gatk.1.txt") ; 

# local realignment
system_call("java -Xmx6g -jar $gatkjar -T IndelRealigner -targetIntervals $input.bam.indel.list -R $ref.fa -I $input.RG.bam -o $input.realigned.bam &> out.gatk.2.txt") ; 

# Unified Genotyper
system_call("java -Xmx6g -jar $gatkjar -T UnifiedGenotyper -I $input.realigned.bam -o gatk_variants.variants.vcf -ploidy 1 -R $ref.fa -nt $cpu &> out.gatk.3.txt") ; 


# base recalibration
#system_call("java -Xmx6g -jar $gatkjar -T BaseRecalibrator -I $output.realigned.bam -R $ref -knownSites /home/ishengtsai/db/hg19/dbsnp_138.hg19.vcf -o $output.recal_data.table ") ; 

# print recalibrated bam
#system_call("java -Xmx6g -jar $gatkjar -T PrintReads -I $output.realigned.bam -R $ref -BQSR $output.recal_data.table -o $output.realigned.recalibrated.bam") ; 

# call SNPs!
#system_call("java -Xmx6g -jar $gatkjar -T HaplotypeCaller -R $ref -I $output.markdup.realigned.bam -L 20 --genotyping_mode DISCOVERY -stand_emit_conf 10 -stand_call_conf 30 -o $output.raw_variants.vcf


# usage: system_call(string)
# Runs the string as a system call, dies if call returns nonzero error code
sub system_call {
    my $cmd  = shift;
    print "$cmd\n";
    system($cmd) ; 

}
