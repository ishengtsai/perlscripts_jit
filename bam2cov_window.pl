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


if (@ARGV != 6 ) {
    print "$0 quality contig.fa.len.txt scaffold window ref bam \n" ;
	exit;
}


my $qual = shift ; 
my $file = shift;
my $select_scaffold = shift ; 
my $window = shift ; 
my $ref = shift ; 
my $bam = shift ;


print '----------------------------------------------------------' ;
print "\nauthor: JIT\n" ;
print "\nmpileup ---> coverage to plot in R (make jpg later)\n" ;
print "s/bam file is: $file\n" ;
print '----------------------------------------------------------' . "\n\n";






# store coverage
my %coverage = () ;




################################################################################################





open( IN, "$file" ) or die "Cannot open $file\n";



my $count = 0 ;



while (<IN>) {
    chomp ;
    
    if (/(^\S+)\s+(\d+)/ ) {
	my $seq = $1 ;
	my $seq_len = $2 ; 

	if ( $seq ne $select_scaffold ) {
	    next ; 
	}

	#print "doing $seq\n" ; 
	my $left = 1 ; 

	for (my $i = $window ; $i < $seq_len ; $i += $window ) {
	    my $right = $i ; 
	    
	    #    print "doing $seq:$left-$right\n" ; 
	    
	#    system("~/bin/samtools-0.1.17/samtools depth -q 4 -r $seq:$left-$right $bam > tmp.$PI.depth") ;

	    
	    my $command = "samtools mpileup -q $qual -f $ref -r $seq:$left-$right $bam" ;
	    my $command2 = "$command" . ' | awk \'{print $4 }\' ' ;

	    print "$command2 \n" ;

	    system("$command2 > tmp.$PI.depth") ;

	    my $bp_with_cov = `wc -l tmp.$PI.depth` ;
	    chomp($bp_with_cov) ;

	    if ( $bp_with_cov eq '0' ) {
		$count++ ;
		open APPEND, ">>", "tmp.$PI.parsed.cov" or die "oooops\n" ;
		print APPEND "$seq $left $right $bp_with_cov ".  " 0" x 9 . "\n" ;
		close(APPEND) ;

		$left += $window ;
		next ; 
	    }

	    
	    open  R, ">", "tmp.$PI.cov.R" or die "ooops" ;
	    print R ' x <- read.table("tmp.' . "$PI" . '.depth",header=F) ' . "\n" ;
	    print R ' y <- as.numeric( quantile(x[,1],p=c(0.025,0.05,0.1,0.2,0.5,0.8,0.9,0.95,0.975)) ) ' ."\n" ;
	    print R ' z <- length( x[,1] ) ' ."\n" ; 
	    print R ' y <- c("' . $seq . '","' . $left . '","' . $right . '","' . $bp_with_cov . '",y,z )' . "\n" ; 
	    print R ' write(y, file="tmp.' . "$PI" . '.parsed.cov", ncolumns=14, append=T) '. "\n" ;
	    
	    $left += $window ; 
	    
	
	    close(R);
	    system("R CMD BATCH tmp.$PI.cov.R") ;
	    
	        $count++;
	 #       last if $count == 5 ;
	    
	}

	#last ;
	
    }
    

    #last;

}

system("mv tmp.$PI.parsed.cov $bam.final.coverage.qual$qual.$select_scaffold.$window") ; 








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
