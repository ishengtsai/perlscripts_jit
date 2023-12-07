#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';




if (@ARGV != 3) {
    print "$0 readnamefile fastq.gz|fastq filterlen\n" ; 
    exit ;
}


my $readfile = $ARGV[0] ; 
my $filenameA = $ARGV[1];
my $shortedlen = $ARGV[2] ; 

my %reads = () ; 

my $chopped = 0 ;
my $palindrome_middle = 0 ; 
my $ignored = 0 ; 

open (IN, "$readfile") or die "oops!\n" ;
while (<IN>) {
    chomp;
    my @r = split /\s+/ ;

    if ( $r[18] != 0 ) {
	$reads{"\@$r[0]"} = "$r[21]\t$r[22]\t$r[18]\t$r[1]" ;
	#print "$r[0]\t$r[21]\t$r[22]\t$r[18]\n" ; 
	$chopped++ ; 
    }
    # if palindrome at middle and still more than 30% of sequence
    elsif ( $r[19] > 0.3     ) {
	$reads{"\@$r[0]"} = "$r[21]\t$r[22]\t$r[18]\t$r[1]" ;
	$palindrome_middle++ ; 
	#print "$_\n" ;
    }
    else {
	$ignored++ ; 
    }

}


#for my $read (keys %reads ) {
#    print "$read\n" ; 
#}

print "to chop: $chopped, palindrome at middle, chop at middle: $palindrome_middle , to ignore: $ignored\n" ; 

#exit ; 



if ( $filenameA=~ /.gz$/ ) {
    open (IN, "zcat $filenameA |") or die "oops!\n" ;
}
else {
    open (IN, "$filenameA") or die "oops!\n" ;
}

my $line = 0; 
my $count = 1 ; 

#open OUT, ">", "$filenameA.subseq.fq" or die "odapdoapsd\n" ; 



open (my $gzip_in, "| /bin/gzip -c > $filenameA.include.fq.gz") or die "error starting gzip $!";
open (my $gzip_ex, "| /bin/gzip -c > $filenameA.exclude.fq.gz") or die "error starting gzip $!";





while (<IN>) {
    $line++ ; 

    
    my $name = $_ ;
    my $seqname = '' ; 
    
    if ( $name =~ /(^\@\S+)/ ) {
	$seqname = $1 ; 
    }
    
    my $seq = <IN> ; chomp($seq) ; 
    my $tmp = <IN> ;
    my $qual = <IN> ; chomp($qual) ; 

    #print "$seqname\n" ; 
    
    if ( $reads{$seqname}) {
	my @regions = split /\t/, $reads{$seqname} ;

	#print "@regions\n" ; 
	# 3 = both ; 2 = end ; 1 = start ;  
	my $type = $regions[2] ; 
	my $origlen = $regions[3] ; 

	my $newseq ;
	my $newqual ;
	my $newseq2 ;
	my $newqual2 ;
	my $seqname2 = $seqname ;

	print "$seqname\t$type\t$regions[0]\t$regions[1]\t" ; 
	
	if ( $type == 1 ) {

	    $seqname2 = "$seqname" . "-dup1.2" ;
	    $seqname = "$seqname" . "-dup1.1" ; 
	    
	    $newseq =  substr $seq, 0, ($regions[0]) ;
            $newqual = substr $qual, 0, ($regions[0]) ;

            $newseq2    = substr $seq, $regions[0] ;
            $newqual2 = substr $qual, $regions[0] ;

	}
	else {
	    #print "here!\n" ; 
	    $seqname2 =  "$seqname"	. "-dup023.2" ;
	    $seqname = "$seqname" . "-dup023.1" ;

	    $newseq =  substr $seq, 0, ($regions[1]) ;
            $newqual = substr $qual, 0, ($regions[1]) ;

	    $newseq2 = substr $seq, $regions[1] ;
            $newqual2 = substr $qual, $regions[1] ;

	}


	
	my $newseq_len = length($newseq) ;
	my $newseq2_len = length($newseq2) ;


	print "$origlen\t$newseq_len\t$newseq2_len\n" ; 
	#next ; 
	
	if ( $newseq_len  >= $shortedlen ) {
	    print $gzip_ex "$seqname\n$newseq\n$tmp$newqual\n" ;
	}
	
	if ( $newseq2_len  >= $shortedlen ) {
	    
	    print $gzip_ex "$seqname2\n$newseq2\n$tmp$newqual2\n" ;
	}

	
    }
    else {
    
	print $gzip_in "$seqname\n$seq\n$tmp$qual\n" ; 
    
    }
    
}



print "all done! all done!\n" ; 



