#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


#if (@ARGV != 1) {
#    print "$0 directory \n" ;
#    exit ;
#}





my @dirs = grep { -d } glob '*';

foreach my $directory (sort {$a <=> $b} @dirs) {



    opendir (DIR, $directory) or die $!;
 
    my $yes = 0 ; 
   
    while (my $file = readdir(DIR)) {       
	#print "$file\n" ; 
	$yes = 1 if $file eq 'iter.40' ; 	
    }
    close(IN) ; 
    

    print "$directory\t$yes\n" ; 

}


