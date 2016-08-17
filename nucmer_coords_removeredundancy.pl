#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV != 1) {
	print "nucmer_repetitive_contigs.pl coords\n\n" ;
	exit ;
}

my $filenameA = $ARGV[0];


open (IN, "$filenameA") or die "oops!\n" ;
open OUT, ">", "$filenameA.removeredundancy.coords" or die "oooops\n" ;



# lots of hashes to store information...

my %saved_results = () ; 

my %region = () ;



my $count = 0 ;
my @pre_r = () ;

while (<IN>) {
    
    chomp ;

    my @r = split /\s+/ , $_ ;
        
    next unless $r[0] ;
    next unless $r[0] =~ /^\d+$/ ;
    next if /IDENTITY/ ;

    # if like this: remove:
    #4       3300    3300    4       3297    3297    98.09   12439   12439   26.51   26.51   pathogen_EMU_contig_60894       pathogen_EMU_contig_60894       [BEGIN]

    if ( $r[0] eq $r[3] && $r[1] eq $r[2] ) {
	
	if ($r[11] eq $r[12] ) {
	    print "1. palindrome!:\n@r\n\n" ;
	    #next ;
	}
    }

    
    # if like this: also remove:
    # 1       6657    1       6657    6657    6657    100.00  14258   14258   46.69   46.69   pathogen_EMU_scaffold_000020    pathogen_EMU_scaffold_000020
    if ( $r[0] eq $r[2] && $r[1] eq $r[3] ) {

        if ($r[11] eq $r[12] ) {
            print "2. wtf is wrong with nucmer:\n@r\n\n" ;
            next ;
        }
    }








   
    $region{$count} = @r ; 

    

    if ($count == 0)  {
	$count++ ;
	for (my $i = 0 ; $i <$#r ; $i++) {
            print OUT "$r[$i]\t" ;
        }
        print OUT "$r[$#r]\n" ;

	$saved_results{"$r[4].$r[5].$r[6].$r[7].$r[8].$r[9].$r[10]"}  = "@r" ; 

	@pre_r = @r ;
	next;
    }


    # remove these:
    # -> 221092  276750  395141  339481  55659   55661   99.96   4914057 4914057 1.13    1.13    pathogen_EMU_scaffold_007798    pathogen_EMU_scaffold_007798
    # 265928  266980  746297  745230  1053    1068    80.78   4914057 15716476        0.02    0.01    pathogen_EMU_scaffold_007798    pathogen_EMU_scaffold_007768
    # -> 339481  395141  276750  221092  55661   55659   99.96   4914057 4914057 1.13    1.13    pathogen_EMU_scaffold_007798    pathogen_EMU_scaffold_007798
    if ( $saved_results{"$r[4].$r[5].$r[6].$r[7].$r[8].$r[9].$r[10]"} ) {

	my @previous_line = split /\s+/, $saved_results{"$r[4].$r[5].$r[6].$r[7].$r[8].$r[9].$r[10]"} ;

	my $q_left = '' ;
	my $q_right = '' ;
	my $s_left = '' ;
	my $s_right = '' ; 

	my $non_overlap = 0 ; 

	if ( $previous_line[2] > $previous_line[3] ) {
	    
	}

	if ( $r[0] eq $previous_line[0] && $r[1] eq $previous_line[1] ) {
	    
	    if ( $r[2] >= $previous_line[2] && $r[2] <= $previous_line[3] ) {
#		print "4. already found overlap: @r\n 4. previous line: " . $saved_results{"$r[4].$r[5].$r[6].$r[7].$r[8].$r[9].$r[10]"} ."\n\n" ;
		#next ;
	    }
	    elsif ( $r[3] >= $previous_line[2] && $r[3] <= $previous_line[3] ) {
#                print "4. already found overlap: @r\n 4. previous line: " . $saved_results{"$r[4].$r[5].$r[6].$r[7].$r[8].$r[9].$r[10]"} ."\n\n" ;
                #next ;
	    }
	    else {
		$non_overlap++ ; 
	    }
	}
	if ( $r[2] eq $previous_line[2] && $r[3] eq $previous_line[3] ) {

            if ( $r[0] >= $previous_line[0] && $r[0] <= $previous_line[1] ) {
#                print "4. already found overlap: @r\n 4. previous line: " . $saved_results{"$r[4].$r[5].$r[6].$r[7].$r[8].$r[9].$r[10]"} ."\n\n" ;
                #next ;
            }
            elsif ( $r[1] >= $previous_line[0] && $r[1] <= $previous_line[1] ) {
#                print "4. already found overlap: @r\n 4. previous line: " . $saved_results{"$r[4].$r[5].$r[6].$r[7].$r[8].$r[9].$r[10]"} ."\n\n" ;
                #next ;
            }
            else {
		$non_overlap++;
            }
        }

	#107089 108398 97176 95867 1310 1310 99.85 737470 737470 0.18 0.18 pathogen_EMU_contig_60709 pathogen_EMU_contig_60709
	#95867 97176 108398 107089 1310 1310 99.85 737470 737470 0.18 0.18 pathogen_EMU_contig_60709 pathogen_EMU_contig_60709
	if ( $r[0] eq $previous_line[3] && $r[1] eq $previous_line[2] ) {
	    print "6.. redundant inverted : @r\n 6. previous line: " . $saved_results{"$r[4].$r[5].$r[6].$r[7].$r[8].$r[9].$r[10]"} ."\n\n" ;
	    next ;	    
	}



	if ($non_overlap == 0 ) {
	    #print "5. already found: @r\n 5. previous line: " . $saved_results{"$r[4].$r[5].$r[6].$r[7].$r[8].$r[9].$r[10]"} ."\n\n" ;
	    #next ;
	}
	else {
            #print "5. ok! @r\n 5. previous line: " . $saved_results{"$r[4].$r[5].$r[6].$r[7].$r[8].$r[9].$r[10]"} ."\n\n" ;
            #next ;
	}


    }
    elsif ( $saved_results{"$r[5].$r[4].$r[6].$r[7].$r[8].$r[9].$r[10]"} ) {
        my @previous_line = split /\s+/, $saved_results{"$r[5].$r[4].$r[6].$r[7].$r[8].$r[9].$r[10]"} ;

	if ( $r[3] eq $previous_line[0] && $r[2] eq $previous_line[1] ) {

	    if ( $r[0] eq $previous_line[3] && $r[1] eq $previous_line[2] ) {
		print "8. EVIL!!! @r\n previous line: " .  $saved_results{"$r[5].$r[4].$r[6].$r[7].$r[8].$r[9].$r[10]"} ."\n\n" ;
		next ; # first use mergebed to get the blocks

	    }


	}


    }








    my $redundant = 0 ;

    #output like this:
    #1516    2575    7190    6137    1060    1054    99.34   14335   18608   7.39    5.66    pathogen_EMU_contig_006135      pathogen_EMU_scaffold_005925    
    #1555    2575    1269    261     1021    1009    98.73   14335   1272    7.12    79.32   pathogen_EMU_contig_006135      pathogen_EMU_contig_50008       

    # check for redundancy!!
    my $coord_1 = $pre_r[0] - $r[0] ;
    my $coord_2 = $pre_r[1] - $r[1] ;
    my $coord_3 = $pre_r[2] - $r[2] ;
    my $coord_4 = $pre_r[3] - $r[3] ;

    if ( abs($coord_1) < 100 && abs($coord_2) < 100 ) {

	if (abs($coord_3) < 100 && abs($coord_4) < 100 ) {
	    
	    if ($r[11] eq $pre_r[11] && $r[12] eq $pre_r[12]) {
		$redundant = 1 ;
	    }
	    
	}
    }

    if ( $redundant == 1) {
	print "redundant!\n@pre_r\n@r\n\n" ;
    }
    else {
	
	for (my $i = 0 ; $i <$#r ; $i++) {
	    print OUT "$r[$i]\t" ;
	}
	print OUT "$r[$#r]\n" ;

        $saved_results{"$r[4].$r[5].$r[6].$r[7].$r[8].$r[9].$r[10]"}  = "@r" ;





    }


    @pre_r = @r ;
    $count++ ;
   
}


close(IN) ;

sleep 1; 


