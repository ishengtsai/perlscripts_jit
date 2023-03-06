#! /usr/bin/perl -w

######################################################################################
# This script takes alignment sequence fasta file and converts it to phylip file
# Author: Wenjie Deng
# Date: 2007-01-29
# Usage: perl Fasta2Phylip.pl inputFastaFile outputPhilipFile
######################################################################################
use strict;


#if (@ARGV != 1) {
#    print "$0 paf \n" ; 
#        exit ;
#}

#my $pafFile = $ARGV[0];




#open (IN, "$pafFile") or die "unable to open  $pafFile\n" ;

my @chrs = () ; 

my %reads = () ; 

while (<>) {
    chomp ;
    my @r = split /\s+/ ;



    if ( $r[0] eq $r[5] && $r[4] eq '-' ) {
	
	my $overlap_prop = ( $r[3] - $r[2] ) / $r[6] ; 
	#print "$_\n" ;
	if ( $reads{$r[0]} ) {
	}
	else {
	    print "$r[0]\t$overlap_prop\t$r[2]\n" ; 
	    $reads{$r[0]}++ ;
	}
    }

    
}




 #   samtools mpileup -q 20 -Q 20 -C 50 -u -r $chr -f ref.fa $Bam | \
 #       bcftools call -c -V indels | \
#        /home/ijt/bin/msmc-tools/bamCaller.py $Depth $Bam_prefix\_mask.bed.gz | \
#    gzip -c > $Bam_prefix.vcf.gz


