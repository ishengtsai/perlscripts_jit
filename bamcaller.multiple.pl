#! /usr/bin/perl -w

######################################################################################
# This script takes alignment sequence fasta file and converts it to phylip file
# Author: Wenjie Deng
# Date: 2007-01-29
# Usage: perl Fasta2Phylip.pl inputFastaFile outputPhilipFile
######################################################################################
use strict;


if (@ARGV != 4) {
        print "$0 chrFile inputBam Bam_prefix depth\n\n" ;
        exit ;
}

my $chrFile = $ARGV[0];
my $inBam = $ARGV[1] ;
my $Bam_prefix = $ARGV[2] ; 
my $Depth = $ARGV[3] ;


my $bamcaller = '/home/ijt/bin/msmc-tools/bamCaller.py' ;


open (IN, "$chrFile") or die "unable to open  $chrFile\n" ;

my @chrs = () ; 

while (<IN>) {
    chomp ;
    my @r = split /\s+/ ;

    print "$r[0]\t$r[1]\n" ; 

    my $command = "samtools mpileup -q 20 -Q 20 -C 50 -u -r '$r[0]' -f ref.fa $inBam \| " .
	"bcftools call -c -V indels  \|  " .
	"$bamcaller $Depth covered_$Bam_prefix\_chr$r[1].bed.gz \| " .
	" gzip -c > $Bam_prefix\_chr$r[1].vcf.gz " ;
    
    
    print "executing:\n $command\n\n" ;
    system("$command") ;
}




 #   samtools mpileup -q 20 -Q 20 -C 50 -u -r $chr -f ref.fa $Bam | \
 #       bcftools call -c -V indels | \
#        /home/ijt/bin/msmc-tools/bamCaller.py $Depth $Bam_prefix\_mask.bed.gz | \
#    gzip -c > $Bam_prefix.vcf.gz


