#!/usr/bin/perl -w
use strict;







if (@ARGV != 2) {
    print "$0 hist sample \n" ;
    print "Need bedtools installed in path\n" ; 
    exit ;
}

my $filenameA = $ARGV[0];
my $sample = $ARGV[1] ; 




open OUT, ">", "$filenameA.cov.txt" or die "oooops!\n" ;



open (IN, "$filenameA") or die "oops!\n" ;

my %cov = () ; 
my %cumu = () ; 


my @window_line = () ;

while (<IN>) {
    chomp;
    my @r = split /\s+/, $_ ;

    if ( /^all/ ) {
	next ; 
    }
    
    my $window = "$r[0]\t$r[1]\t$r[2]\t" . ( $r[1] + ($r[2]-$r[1])/2 ) ; 

    unless ( $cumu{$window} ) {
	push(@window_line, $window) ; 
	$cumu{$window} = 0 ; 
    }

    #print "$window\t$r[3]\t$cumu{$window}\n" ; 
    
    my $beforecov = $cumu{$window} ; 
    my $aftercov = $cumu{$window} + $r[6] ; 
    
    if ( $beforecov <= 0.025 && $aftercov >= 0.025 ) {
	$cov{$window}{0.025} = $r[3] ; 
    }
    
    if ( $cov{$window}{'0.5'}  ) {
    }
    else {
	if ( $aftercov >= 0.5 ) {
	    $cov{$window}{0.5} = $r[3] ;
	}
    }

    if ( $cov{$window}{'0.975'}  ) {
    }
    else {
	if ( $aftercov >= 0.975 ) {
	    $cov{$window}{0.975} = $r[3] ;
	}
    }
    
    



    
    $cumu{$window} += $r[6] ;

    

}
close(IN) ;


foreach my $window (@window_line) {
    print OUT "$sample\t$window\t" ;;
    print OUT "$cov{$window}{0.025}\t" ;
    print OUT "$cov{$window}{0.5}\t" ;
    print OUT "$cov{$window}{0.975}" ;
    print OUT "\n" ; 
}



print "all done! $filenameA.cov.txt produced!\n" ; 
