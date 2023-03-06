#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';




if (@ARGV != 3) {
    print "$0 readnamefile fastq.gz|fastq outputFastq\n" ; 
    exit ;
}


my $readfile = $ARGV[0] ; 
my $filenameA = $ARGV[1];
my $outfile = $ARGV[2] ; 

my %reads = () ; 

open (IN, "$readfile") or die "oops!\n" ;
while (<IN>) {
    chomp;
    $reads{$_}++ ; 

}



if ( $filenameA=~ /.gz$/ ) {
    open (IN, "zcat $filenameA |") or die "oops!\n" ;
}
else {
    open (IN, "$filenameA") or die "oops!\n" ;
}

my $line = 0; 
my $count = 0 ; 

open OUT, ">", "$outfile" or die "odapdoapsd\n" ; 



while (<IN>) {
    $line++ ; 

    


    my $name = $_;


    my $id ; 
    if ( $name =~ /^\@(\S+)/ ) {
	#print "$1 found!\n" ; 
	$id = $1 ; 
    }


    
    my $seq = <IN> ;
    my $tmp = <IN> ;
    my $qual = <IN> ;

    if ( $reads{$id} ) {
    
	print OUT "$name$seq$tmp$qual" ; 
	$count++ ; 
    }


    
    
}


print "Done! $count reads found. new file is $filenameA.subseq.fq\n" ; 


