#!/usr/bin/env perl

use strict;
use warnings;
use File::Spec;



my $PI = `echo $$` ;    chomp($PI) ;

#debug 
my $debug = 0 ; 

if (@ARGV != 5) {
    print STDERR "usage: $0 ref PE1 PE2 outdir READGROUP \n" ; 
    print STDERR "smalt mapping!\n" ; 

    exit(1);
}

#my $ref = "/mnt/nas1/ijt/db/hg19/GRCh38_full_analysis_set_plus_decoy_hla.fa" ; 
#my $ref = "/home/ishengtsai/db/hg19/ucsc.hg19.fasta" ;
my $ref = shift ; 

my $picardbin = "/usr/local/bioinfo/picard-tools-1.130/picard.jar" ; 
my $gatkjar = "/usr/local/bioinfo/GenomeAnalysisTK.jar" ; 

my $PE1 = shift ; 
my $PE2 = shift ; 
my $outfolder = shift ; 
my $RG = shift ; 

my $cpu = 8 ; 

#java set
system("java -Xmx6g -version ;  ") ; 

my $pwd= `pwd`;
chomp($pwd) ; 

mkdir "$outfolder" or die "can not make $outfolder"  ; 
chdir "$outfolder" ; 

# make tmp dir
system("mkdir tmp") ; 


# make symbolic link
system("ln -s $pwd/$ref ref.fa") ; 

# make indexes
system("samtools faidx ref.fa") ; 
system("java -Xmx4g -Djava.io.tmpdir=`pwd`/tmp -jar $picardbin CreateSequenceDictionary REFERENCE=ref.fa OUTPUT=ref.dict") ; 

#smalt index
my $smaltcommand = "/home/ijt/bin/smalt-0.7.4/smalt_x86_64 index -k 13 -s 2 ref.fa ref.fa > zzz.log.smalt.index " ; 
system_call("$smaltcommand") ; 

$smaltcommand = "/home/ijt/bin/smalt-0.7.4/smalt_x86_64 map -i 6000 -r 10 -x -y 0.5 -n $cpu -T `pwd`/tmp -o out.sam ref.fa $pwd/$PE1 $pwd/$PE2 > zzz.log.smalt.map " ; 
system_call("$smaltcommand") ;





# sam to bam and add read group 
system_call("java -Xmx4g -Djava.io.tmpdir=`pwd`/tmp -jar $picardbin AddOrReplaceReadGroups I=out.sam O=out.bam RGLB=lib1 RGPL=Illumina RGPU=BRC RGSM=$RG SORT_ORDER=coordinate CREATE_INDEX=true > zzz.log.AddOrReplaceReadGroups") ; 

#mark duplicates
system_call("java -Xmx4g -Djava.io.tmpdir=`pwd`/tmp -jar $picardbin MarkDuplicates INPUT=out.bam OUTPUT=out.markdup.bam METRICS_FILE=out.markdup.metrics CREATE_INDEX=true VALIDATION_STRINGENCY=LENIENT > zzz.log.MarkDuplicates ") ; 

#stats
system_call("bamtools stats -in out.markdup.bam -insert > out.markdup.bam.stats") ;



#indel calling ; First declare the region
system_call("java -Xmx6g -Djava.io.tmpdir=`pwd`/tmp -jar $gatkjar -T RealignerTargetCreator -R ref.fa -I out.markdup.bam -o forIndelRealigner.intervals -nct 1 -nt $cpu > zzz.log.RealignerTargetCreator ") ; 


# local realignment
system_call("java -Xmx6g -Djava.io.tmpdir=`pwd`/tmp -jar $gatkjar -T IndelRealigner -targetIntervals forIndelRealigner.intervals -R ref.fa -I out.markdup.bam -o out.markdup.realigned.bam > zzz.log.IndelRealigner") ; 

# get insert size plot
system_call("/home/ijt/bin/Reapr_1.0.18/src/bam2insert out.markdup.realigned.bam ref.fa.fai out.markdup.realigned.bam") ; 

# base recalibration
# No known snps!
#system_call("java -Xmx6g -Djava.io.tmpdir=`pwd`/tmp -jar $gatkjar -T BaseRecalibrator -I out.markdup.realigned.bam -R ref.fa -nct $cpu -nt 1 -o recal_data.table ") ;



# Do a second pass to analyze covariation remaining after recalibration
#system_call("java -Xmx6g -Djava.io.tmpdir=`pwd`/tmp -jar $gatkjar -T BaseRecalibrator -I out.markdup.realigned.bam -R ref.fa nct $cpu -nt 1 -BQSR recal_data.table -o post_recal_data.table ") ; 

# Generate before/after plots
#system_call("java -Xmx6g -Djava.io.tmpdir=`pwd`/tmp -jar $gatkjar -T AnalyzeCovariates -I out.markdup.realigned.bam -R ref.fa -before recal_data.table -after post_recal_data.table -plots recalibration_plots.pdf ") ; 


# print recalibrated bam
#system_call("java -Xmx6g -Djava.io.tmpdir=`pwd`/tmp -jar $gatkjar -T PrintReads -I out.markdup.realigned.bam -R ref.fa -BQSR recal_data.table -o out.markdup.realigned.recalibrated.bam -nct $cpu -nt 1 ") ; 

# call SNPs!
#system_call("java -Xmx6g -Djava.io.tmpdir=`pwd`/tmp -jar $gatkjar -T HaplotypeCaller -R $ref -I $output.markdup.realigned.recalibrated.bam -L $exomeBed --dbsnp /mnt/nas1/ijt/db/hg19/1000G_phase1.indels.hg19.sites.vcf -stand_call_conf 30 -stand_emit_conf 10 -o $output.raw.snps.indels.g.vcf") ; 

# delete transient files
system_call("rm out.sam ; rm -rf tmp ") ; 

chdir("../") ; 

print "All done! Pipeline all executed\n" ; 


# usage: system_call(string)
# Runs the string as a system call, dies if call returns nonzero error code
sub system_call {
    my $cmd  = shift;
    print "Command:\n$cmd\n\n";
    system($cmd) ; 

}
