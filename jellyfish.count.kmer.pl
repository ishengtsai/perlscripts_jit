#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';






if (@ARGV != 3) {
    print "$0 fasta smallkmer largekmer \n" ; 
	exit ;
}

my $contigs = $ARGV[0];
my $small = $ARGV[1]; 
my $large = $ARGV[2] ; 

my $jellyfish = '/home/ishengtsai/bin/jellyfish-1.1.11/bin/jellyfish ' ; 

system("rm jellyfish.count.kmer") ; 
my $largestkmer = 0 ; 
my $kmeroccur = 0 ; 

open OUT, ">", "$contigs.kmer.count" or die "dasdioadioaosdioa\n" ; 

for (my $i = $small; $i < $large ; $i+= 2) {

    system("rm jelly.tmp.out\_*") if -e "jelly.tmp.out_0" ; 
	   
    my $command = "$jellyfish count -o jelly.tmp.out -m $i -s 100000000 -t 8 $contigs" ; 
    system("$command") ; 
    
    if ( -e "jelly.tmp.out_1" ) {
	$command = "$jellyfish merge -o output.jf jelly.tmp.out\_*" ;
	print "executing: $command\n" ;
	system("$command") ;
	system("rm jelly.tmp.out\_*") ;
    }
    else {
	system("mv jelly.tmp.out_0 output.jf") ; 
    }

    	   
    $command = "$jellyfish stats output.jf > jellyfish.count.kmer" ;
    system("$command") ; 
    
    open (IN, "jellyfish.count.kmer") or die "odosapdspod\n" ; 
    while (<IN>) {
	if ( /Unique:\s+(\d+)/ ) {
	    my $unique = $1 ; 
	    if ( $unique > $kmeroccur ) {
		$kmeroccur = $unique ; 
		$largestkmer = $i ; 
	    }
	    print OUT "$i\t$unique\n" ; 
	}

    }

	   
	   last if $i == 35 ; 
}


print OUT "Largestkmer\t$largestkmer\n" ; 
print "Largestkmer\t$largestkmer\n" ;
print "all done!\n" ; 
