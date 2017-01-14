#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV != 1) {
    print "$0 file.cat \n" ;
    exit ;
}

my $filenameA = shift @ARGV;
my $out = "$filenameA.out" ;

my $offset = 50 ;


open (IN, "$filenameA") or die "oops!\n" ;

open OUT, ">" , "$out" or die "oops out!\n" ;
#open GTF, ">", "$filenameA.gtf" or die "dadoapdoadpoa\n" ; 
open OUT_debug, ">" , "$out.debug" or die "oops out!\n" ;




my $previous_result = "" ;
my $previous_contig = 0 ;
my $previous_start = 0;
my $previous_stop = 0 ;
my $previous_repeat = 0 ;
my $previous_score = 0 ;



my @overlap = () ;


print OUT "   SW   perc perc perc  query                    position in query        matching       repeat           position in repeat\n" ;
print OUT "score   div. del. ins.  sequence                 begin  end      (left)   repeat         class/family   begin  end    (left)  ID\n" ;
print OUT "\n" ;


while (<IN>) {

    next unless /^\d+/ ; 
    
    print OUT_debug  "$_" ; 

# gff is like this
##gff-version 3
#ctg123  .  exon  1300  1500  .  +  .  ID=exon00001
# detail at http://gmod.org/wiki/GFF


# repeat masker .out output like this
#   SW   perc perc perc  query                    position in query        matching       repeat           position in repeat
#score   div. del. ins.  sequence                 begin  end      (left)   repeat         class/family   begin  end    (left)  ID
#
#  244   22.4  4.4  1.4  Schisto_mansoni.SC_0206      74    141 (425166) + SAU3A_TR       SINE              304    373   (15)   1  
#  646   27.9  2.9  5.4  Schisto_mansoni.SC_0206    1528   1806 (423501) C SACI-5         LTR/Gypsy         (0)   4257   3999   2  
#   31   65.4  0.0  0.0  Schisto_mansoni.SC_0206    2786   2837 (422470) + AT_rich        Low_complexity      1     52    (0)   3  

# problem case here'
# 19786   14.4  1.1  1.2  Schisto_mansoni.SC_0221   88239  92027 (231215) C NONAUT-3       LTR/Gypsy       (772)   4016      4  69   2609
# 274 32.71 3.60 2.22 Schisto_mansoni.SC_0221 88239 88460 (234782) C Gulliver#LTR/Gypsy (772) 4016 3792 5
# 2393 32.34 3.25 3.49 Schisto_mansoni.SC_0221 88287 90410 (232832) C NONAUT-5#LTR/Gypsy (826) 3901 1783 5
# 19786 6.34 0.15 0.23 Schisto_mansoni.SC_0221 89420 92027 (231215) C NONAUT-3#LTR/Gypsy (0) 2609 4 5
    
    
    
    chomp ;
    
    my @line = split /\s+/ , $_ ;



    
    next if $line[0] =~ /\#/ ;
    next if $line[0] =~ /\D+/ ;



    # modification of original result so it looks more like *.out output
    if ($line[8] ne 'C') {
	splice(@line, 8, 0, '+') ;
    }

    if ($line[9] =~ /(\S+)\#(\S+)/ ) {
	splice(@line, 10, 0, $2) ;
	$line[9] = $1 ;
    }
    elsif ( $line[9] =~ /rnd-\d+/ ) {
	splice(@line, 10, 0, "New_repeat") ;
    }
    else {
	splice(@line, 10, 0, "unknown") ;
    }


    # don't count these things...
    #if ( $line[10] eq 'Simple_repeat' || $line[10] eq 'unknown' ) {

    if ( $line[10] eq 'Simple_repeat' ) {
	print OUT "  @line *uncounted*\n" ;
	next ;
    }
    

    # if overlap is found...
    my $thisIsOverlap = 0 ;

    if ( $line[5] >= $previous_start &&  $line[5]  <= $previous_stop-$offset ) {
	
	#if ( $line[4] eq $previous_contig && $line[9] ne $previous_repeat ) {
	if ( $line[4] eq $previous_contig ) {
	#print "found!\n" ;
	    #print "$previous_result\n" ;
	    #print "@line\n" ;

	    if ( @overlap ) {
		push(@overlap, "@line") ;
	    }
	    else {
		push(@overlap, $previous_result) ;
	        push(@overlap,  "@line") ;
	    }

	    $thisIsOverlap = 1 ;

	}
	else {

	    if (@overlap) {

		#print "overlap: @overlap\n oh yeah: @line\n" ;

		if ( @overlap == 2 ) {
		    #print "found 2!\n" ;                                                                                                                                                                                                                                             
		    
		    my $left_score = 0 ;
		    my $right_score = 0 ;
		    my $higher_result = 0 ;
		    
		    if ( $overlap[0] =~ /(^\d+)/ ) {
			$left_score = $1 ;
		    }
		    if ( $overlap[1] =~ /(^\d+)/ ) {
			$right_score = $1 ;
		    }
		    $higher_result = 1 if $right_score > $left_score ;
		    
		    print OUT "  $overlap[$higher_result] *1from2*\n" ;
		    
		    foreach (@overlap) {
			print OUT_debug "Pair: $_\n" ;
		    }
		    
		    
		}
		else {
		    my $isT2 = 1 ;

		    foreach (@overlap) {
			unless (/T2/ || /Sj-alpha/) {
			    $isT2 = 0 ;
			}
			print OUT_debug "Nested: $_\n" ;
		    }

		    if ( $isT2 == 1 ) {
                #print "only T2 and Sj-alpha copy..\n" ;                                                                                                                                                                                                                      

			foreach (@overlap) {
			    if (/T2/) {
				print OUT "  $_ *T2nested*\n" ;
			    }

			}

		    }
		    else {
                #print "more than 2..\n" ;                                                                                                                                                                                                                                    


			my $max_score = 0 ;
			my $highest = 0 ;

			for (my $i = 0 ; $i < @overlap ; $i++ ) {
			    if ( $overlap[$i] =~ /(^\d+)/ ) {
				if ( $1 > $max_score ) {
				    $highest = $i ;
				    $max_score = $1 ;
				}
			    }
                    #print "$overlap[$i]\n" ;                                                                                                                                                                                                                                 
			}

			print OUT "  $overlap[$highest] *nested-highest*\n" ;
			my @highest_result = split /\s+/ , $overlap[$highest] ;
			my @tokeep = () ;

			for (my $i = 0 ; $i < @overlap ; $i++ ) {
			    next if $i == $highest ;
			    my @line = split /\s+/ , $overlap[$i] ;

			    my $isIn = 0 ;

			    if ( $line[5] >=  $highest_result[5] && $line[5] <= $highest_result[6] )  {
				$isIn = 1 ;
			    }
			    if ( $line[6] >=  $highest_result[5] && $line[6] <=$highest_result[6] )  {
				$isIn =1 ;
			    }

			    if ( $isIn == 0 ) {
				push (@tokeep, "@line") ;
			    }

			}

			if ( @tokeep > 2) {
			    print "some really nasty bits!!\n" ;
			    foreach (@tokeep) {
				print "Nasty: $_\n" ;
			    }
			}
			if ( @tokeep == 2) {
			    my $left_score = 0 ;
			    my $right_score = 0 ;
			    my $lower_result = 0 ;
			    
			    
			    if ( $tokeep[0] =~ /(^\d+)/ ) {
				$left_score = $1 ;
			    }
			    if ( $tokeep[1] =~ /(^\d+)/ ) {
				$right_score = $1 ;
			    }
			    
			    $lower_result = 1 if $left_score > $right_score ;
			    
			    splice(@tokeep, $lower_result, 1) ;
			    
			    print OUT "  $tokeep[0] *nested*\n"
				
				
				
			}
			
			
		    }
		    
		    
		    
		    
		    
		}
		


		@overlap = () ;



	    }
	    else {

		print OUT "  $previous_result *clean,previousContig*\n" ;

		#print "missed bit: $previous_result oh yeah: @line\n" ;
	    }

	}
	

    }

    # not found overlap with this match;
    # so we need to process the overlap and print out the current result
    elsif ( @overlap ) {


	if ( @overlap == 2 ) {
	    #print "found 2!\n" ;

	    my $left_score = 0 ;
	    my $right_score = 0 ;
	    my $higher_result = 0 ;

	    if ( $overlap[0] =~ /(^\d+)/ ) {
		$left_score = $1 ;
	    }
	    if ( $overlap[1] =~ /(^\d+)/ ) {
		$right_score = $1 ;
	    }
	    $higher_result = 1 if $right_score > $left_score ;

	    print OUT "  $overlap[$higher_result] *1from2*\n" ;

	    foreach (@overlap) {
		print OUT_debug "Pair: $_\n" ;
	    }


	}
	else {
	    my $isT2 = 1 ;

	    foreach (@overlap) {
		unless (/T2/ || /Sj-alpha/) {
		    $isT2 = 0 ;
		}
		print OUT_debug "Nested: $_\n" ;
	    }

	    if ( $isT2 == 1 ) {
		#print "only T2 and Sj-alpha copy..\n" ;
		
		foreach (@overlap) {
		    if (/T2/) {
			print OUT "  $_ *T2nested*\n" ;
		    }

		}

	    }
	    else {
		#print "more than 2..\n" ;


		my $max_score = 0 ;
		my $highest = 0 ;

		for (my $i = 0 ; $i < @overlap ; $i++ ) {
		    if ( $overlap[$i] =~ /(^\d+)/ ) {
			if ( $1 > $max_score ) {
			    $highest = $i ;
			    $max_score = $1 ;
			}
		    }
		    #print "$overlap[$i]\n" ;
		}

		print OUT "  $overlap[$highest] *nested-highest*\n" ;
	        my @highest_result = split /\s+/ , $overlap[$highest] ;
		my @tokeep = () ;

		for (my $i = 0 ; $i < @overlap ; $i++ ) {
		    next if $i == $highest ;
		    my @line = split /\s+/ , $overlap[$i] ;
		    
		    my $isIn = 0 ;

		    if ( $line[5] >=  $highest_result[5] && $line[5] <= $highest_result[6] )  {
			$isIn = 1 ;
		    }
		    if ( $line[6] >=  $highest_result[5] && $line[6] <=$highest_result[6] )  {
			$isIn =1 ;
		    }

		    if ( $isIn == 0 ) {
			push (@tokeep, "@line") ;
		    }

		}

		if ( @tokeep > 2) {
		    print "some really nasty bits!!\n" ;
		    foreach (@tokeep) {
                        print "Nasty: $_\n" ;
                    }
		}
		if ( @tokeep == 2) {
		    my $left_score = 0 ;
		    my $right_score = 0 ;
		    my $lower_result = 0 ;

		    if ( $tokeep[0] =~ /(^\d+)/ ) {
			$left_score = $1 ;
		    }
		    if ( $tokeep[1] =~ /(^\d+)/ ) {
                        $right_score = $1 ;
		    }
		    
		    $lower_result = 1 if $left_score > $right_score ;

		    splice(@tokeep, $lower_result, 1) ;

		    print OUT "  $tokeep[0] *nested*\n"
		    

			
		}


	    }





	}



	@overlap = () ;

    }
    else {
	if ( $previous_result ) {
	    print OUT "  $previous_result *clean*\n" ;
	}

    }

    $previous_result = "@line" ;
    $previous_score = $line[0] ;
    $previous_contig = $line[4];
    $previous_start = $line[5];
    $previous_stop = $line[6];
    $previous_repeat = $line[9] ;

    

    
}


