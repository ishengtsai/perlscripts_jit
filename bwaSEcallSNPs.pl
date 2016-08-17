#!/usr/bin/env perl

use strict;
use warnings;
use File::Spec;



my $PI = `echo $$` ;    chomp($PI) ;

#debug 
my $debug = 0 ; 

if (@ARGV != 3) {
    print STDERR "usage: $0 bamseparatebycomma output threads \n" ; 
    print STDERR "This is for Tsai's T1D data \n" ; 

    exit(1);
}

my $ref = "/home/ishengtsai/db/hg19/ucsc.hg19.fasta" ;
my $picardpath = "/home/ishengtsai/bin/picard-tools-1.107/" ; 
#my $gatkjar = "/home/ishengtsai/bin/GenomeAnalysisTK-2.7-2-g6bda569/GenomeAnalysisTK.jar" ;  
my $gatkjar = "/home/ishengtsai/bin/GenomeAnalysisTK-3.1-1/GenomeAnalysisTK.jar " ; 


my @bams = split (/\,/, shift) ;
my $output = shift ; 
my $cpu = shift ; 


#java set
system("java -Xmx6g -version ; ulimit -v 20000000 ") ; 
print "Number of CPU: $cpu\n" ; 



# call SNPs!

my $bamstring = '' ; 
foreach my $bam ( @bams ) {
    $bamstring .= " -I $bam " ; 
}

system_call("java -Xmx6g -jar $gatkjar -T HaplotypeCaller -nct $cpu -R $ref $bamstring --dbsnp /home/ishengtsai/db/hg19/dbsnp_138.hg19.vcf --genotyping_mode DISCOVERY -stand_emit_conf 10 -stand_call_conf 30 -o $output.raw_variants.vcf") ; 


# usage: system_call(string)
# Runs the string as a system call, dies if call returns nonzero error code
sub system_call {
    my $cmd  = shift;
    print "$cmd\n";
    system($cmd) ; 

}
