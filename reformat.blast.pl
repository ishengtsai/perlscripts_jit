#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV != 1) {
    print "$0 blastx.out.dir \n\n" ;
    exit ;
}

my $dir = shift ; 

opendir (D, "$dir") or die "can't opendir: $!\n" ; 

while ( my $file = readdir(D) ) {


    next unless $file =~ /\.out$/ ; 
    print "$file\n" ;

    #next ; 

    open (IN, "$dir/$file") or die "oooops\n" ; 
    open OUT, ">", "$dir/$file.reformat.xml" or die "oops\n" ; 

    my $count = 0 ; 
    my $inhit = 0 ; 

    while (<IN>) {
	
	chomp; 
	
	s/^\s+//gi ; 
	

	if ( /Iteration_hits/ ) {
	    $count = 0 ; 
	}
	if ( /<Hit>/ ) {
	    $count++ ; 
	    $inhit = 1 ; 
	}


	if ( $inhit == 1 && $count < 31 ) {
	    
	    if ( /Hit_def.+\| (.+)/ ) {
		print OUT "<Hit_def>$1\n" ; 
	    }
	    else {
		print OUT "$_\n" ;
	    }
	
	}
	elsif ( $inhit == 1 && /<\/Hit>/ ) {
	    $inhit = 0 ; 
	}
	elsif ( $inhit == 0 ) {
	    print OUT "$_\n" ;
	}

	#last ; 
    }
    close(IN) ;
    close(OUT) ; 

    system("rm $dir/$file") ; 
    print "$dir/$file.reformat.xml created, $dir/$file deleted\n" ; 
    

    #last ; 

}

print "all done!\n" ; 
