#! /usr/bin/perl -w

######################################################################################
# This script takes alignment sequence fasta file and converts it to phylip file
# Author: Wenjie Deng
# Date: 2007-01-29
# Usage: perl Fasta2Phylip.pl inputFastaFile outputPhilipFile
######################################################################################
use strict;
use POSIX;



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

	my $half = floor(  $r[6] / 2 ) ;
	my $start = floor ( $r[6] * 0.1 ) ;
	my $end = floor ( $r[6] * 0.9 ) ;

	my $isend = 0 ;

	# 3 for both ; 2 end ; 1 for start ; 
	if ( $r[2] < $start && $r[3] > $end ) {
	    $isend = 3;
	}
	elsif ( $r[2] < $start ) {
	    $isend = 1 ;
	}
	elsif ( $r[3] > $end ) {
	    $isend = 2 ; 
	}


	my $start_pos = sprintf("%.2f", $r[2] / $r[1] );
	my $end_pos = sprintf("%.2f", $r[3] / $r[1] );
	
	my $overlap_prop = ( $r[3] - $r[2] ) / $r[1] ; 
	#print "$_\n" ;
	
	# only want best hit
	if ( $reads{$r[0]} ) {
	    #print "$_\t" ;
	    #if ( $isend != 0 ) {
	    #  print "isend\n" ; 
	    #}
	    #else {
	    #	print "\n" ; 
	    #}
	    
	}
	else {
	    print "$_\t$overlap_prop\t$isend\t$start_pos\t$end_pos\t" ;

	    if ( $isend == 3 || $isend == 2 ) {
		my $cutoff = $r[2] + floor( ($r[3] - $r[2]) / 2 ) ;
		print "1\t$cutoff\n" ; 
	    }
	    elsif ( $isend == 0 ) {
                my $cutoff = $r[2] + floor( ($r[3] - $r[2]) / 2 ) ;
		print "1\t$cutoff\n" ;
            }
	    elsif ( $isend == 1 ) {
		my $cutoff = $r[3] - floor ( ($r[3] - $r[2]) / 2 ) ;
		print "$cutoff\t$r[1]\n" ; 

	    }
	    else {

		print "1\t$r[1]\n" ; 
	    }

	    
	    $reads{$r[0]}++ ;
	}
    }

    
}




 #   samtools mpileup -q 20 -Q 20 -C 50 -u -r $chr -f ref.fa $Bam | \
 #       bcftools call -c -V indels | \
#        /home/ijt/bin/msmc-tools/bamCaller.py $Depth $Bam_prefix\_mask.bed.gz | \
#    gzip -c > $Bam_prefix.vcf.gz


