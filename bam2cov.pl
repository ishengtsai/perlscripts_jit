#! /usr/bin/perl -w
#
#
# Copyright (C) 2009 by Pathogene Group, Sanger Center
#
# Author: JIT
# Description: 
#		a script that map the Solexa reads back to the reference/contigs
#		and parition them based on either ends of the contigs
#
#
#




use strict;
use warnings;

# to print
local $" = "\t";


my $PI = `echo $$` ; chomp($PI) ;


#"


if (@ARGV != 3 ) {
    print "$0 qual ref.fa bam \n" ;
	exit;
}

my $qual  = shift  ; 
my $ref = shift ; 

system("/home/ishengtsai/bin/image/contig_length_fasta.pl $ref > $ref.len.txt.z") ; 
my $file = "$ref.len.txt.z";


my $bam = shift ;


print '----------------------------------------------------------' ;
print "\nauthor: JIT\n" ;
print "\nmpileup ---> coverage \n" ;
print "qual = $qual\n" ; 
print "PI = $PI\n" ;
print "s/bam file is: $file\n" ;
print '----------------------------------------------------------' . "\n\n";






# store coverage
my %coverage = () ;




################################################################################################



system("rm $bam.$PI.final.coverage.percontig") ; 


open( IN, "$file" ) or die "Cannot open $file\n";



my $count = 0 ;



while (<IN>) {
    chomp ;
    
    if (/(^\S+)\s+(\d+)/ ) {


	my $seq = $1 ;
	my $seq_len = $2 ; 

#	next unless $seq eq 'OM4' ; 

	#print "doing $seq\n" ; 

#	system("~/bin/samtools-0.1.17/samtools depth -q 4 -r $seq $bam > tmp.$PI.depth") ;
	
#	$seq = "SVE.contig.00939.1377" ; 

	my $command = "samtools mpileup -q $qual -f $ref -r $seq $bam" ;
	my $command2 = "$command" . ' | awk \'{print $4 }\' ' ;

	print "$command2 \n" ; 

	system("$command2 > tmp.$PI.depth") ;

	my $bp_with_cov = `less tmp.$PI.depth |wc -l` ;
	chomp($bp_with_cov) ; 


	print "seqlen: $seq_len\n" ; 
	print "bpwithcov: $bp_with_cov\n" ; 

	#open ADD_ZERO , ">>", "tmp.$PI.depth" or die "can't append!\n" ; 
	#for (my $i = 0 ; $i < ($seq_len - $bp_with_cov) ; $i++ ) {
	#    print ADD_ZERO "0\n" ; 
	#}
	#close(ADD_ZERO); 

	if ( $bp_with_cov eq '0' ) {
	    $count++ ; 
	    open APPEND, ">>", "tmp.$PI.parsed.cov" or die "oooops\n" ;
	    print APPEND "$seq $seq_len " . ($seq_len - $bp_with_cov) . " 0" x 9 . "\n" ;
	    close(APPEND) ;

      	    $count++ ; 
	    next ; 
	}

	
	open  R, ">", "tmp.$PI.cov.R" or die "ooops" ;
	print R ' x <- read.table("tmp.' . "$PI" . '.depth",header=F) ' . "\n" ;
	print R ' y <- as.numeric( quantile(x[,1],p=c(0.025,0.05,0.25,0.4,0.5,0.6,0.75,0.95,0.975)) ) ' ."\n" ;
	print R ' y <- c("' . $seq . '","' . $seq_len . '","' . ($seq_len - $bp_with_cov)  . '",y )' . "\n" ; 
	print R ' write(y, file="tmp.' . "$PI" . '.parsed.cov", ncolumns=12, append=T) '. "\n" ;


	close(R);



	system("R CMD BATCH  tmp.$PI.cov.R") ; 


	$count++; 

	#last ;

	#last if $count == 3 ; 
    }

}

system("mv tmp.$PI.parsed.cov $bam.$PI.final.coverage.qual$qual.percontig") ; 








close(IN) ;



#
# usage:
#   print median(@array);
#

sub median {
    my @pole = @_;



    my @sorted = () ;
    my $median;
    my $lower;
    my $upper;

    @sorted = sort { $a <=> $b } @pole;
    my $length = scalar @sorted ;

    $lower = sprintf("%.0f", ($length * 0.025) ) ;
    $upper = sprintf("%.0f", ($length * 0.975) ) ;

    $lower = $sorted[$lower-1] ;
    $upper = $sorted[$upper-1] ;


    if( (@sorted % 2) == 1 ) {
        $median = $sorted[((@sorted+1) / 2)-1];
    } else {
        $median = ($sorted[(@sorted / 2)-1] + $sorted[@sorted / 2]) / 2;
    }

    return ("$median","$lower","$upper", "$length");

}
