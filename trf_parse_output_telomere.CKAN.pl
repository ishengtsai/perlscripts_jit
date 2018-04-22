#!/usr/bin/perl -w
use strict;







if (@ARGV != 2) {
    print "$0 dat contig_len_file\n\n" ;
    exit ;
}

my $filenameA = $ARGV[0];
my $contig_len_file = $ARGV[1] ; 


my %contig_len = () ; 

open (IN, "$contig_len_file") or die "oops!\n" ;
while (<IN>) {
    chomp; 
    if ( /(^\S+)\s+(\S+)/ ) {
	$contig_len{$1} = $2 ; 
    }
}
close(IN) ; 


open (IN, "$filenameA") or die "oops!\n" ;
#open OUT, ">", "$filenameA.parsed.out" or die "ooooops!\n" ;

my $count = 0 ;
my $seq = '' ;

while (<IN>) {

    if ( /Sequence: (\S+)/ ) {
        $seq =  $1 ;
	#print "\n" ; 
    }
    if (/^\d+/) {
        chomp ;
        my @r = split /\s+/, $_ ;


	next if $r[2] != 7 ;
	
	my $isrepeat = checkRepeat($r[13]) ;
	#print "$isrepeat\n" ; 
	





	# set within 5kb

	if ( $isrepeat == 1 ) {
	    #print "here!\n" ; 
	    print "$seq\t$contig_len{$seq}\t$r[0]\t$r[1]\t$r[2]\t$r[3]\t$r[13]\n" ;
	}
	





        #for (my $i = 0 ; $i < 17 ; $i++ ) {
        #    print "\t$r[$i]" ;
        #}
        #print "\n" ;
    }

}


sub checkRepeat {
    my $repeat = shift ;
    #print "$repeat\n" ; 
    my $isrepeat =  0;

    my %repeatloop = () ;
    $repeatloop{'TAAACCC'}++ ; 
    $repeatloop{'AAACCCT'}++ ;
    $repeatloop{'AACCCTA'}++ ;
    $repeatloop{'ACCCTAA'}++ ;
    $repeatloop{'CCCTAAA'}++ ; # reverse complement of TTTAGGG
    $repeatloop{'CCTAAAC'}++ ;
    $repeatloop{'CTAAACC'}++ ;

#    $repeatloop{'ATTTGGG'}++ ;
#    $repeatloop{'TTTGGGA'}++ ;
#    $repeatloop{'TTGGGAT'}++ ;    
#    $repeatloop{'TGGGATT'}++ ;
#    $repeatloop{'GGGATTT'}++ ;
#    $repeatloop{'GGATTTG'}++ ;
#    $repeatloop{'GATTTGG'}++ ;

    $repeatloop{'TTTAGGG'}++ ;
    $repeatloop{'TTAGGGT'}++ ;
    $repeatloop{'TAGGGTT'}++ ;
    $repeatloop{'AGGGTTT'}++ ;
    $repeatloop{'GGGTTTA'}++ ;
    $repeatloop{'GGTTTAG'}++ ;
    $repeatloop{'GTTTAGG'}++ ;


    

    
    if ($repeatloop{$repeat} ) {
	#print "yes!\n" ;
	$isrepeat = 1;
    }

    
    return $isrepeat ; 

}
