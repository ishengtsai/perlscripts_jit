#!/usr/bin/perl -w
use strict;
use POSIX qw(ceil);



my $largest = 0;
my $contig = '';


if (@ARGV != 2) {
	print "$0 fasta max.len\n\n" ;
	exit ;
}

my $filenameA = $ARGV[0];
my $splitLen= $ARGV[1] ;



my $count = 1 ;
my $tmp_count = 0 ;

my %fasta = () ; 

open (IN, "$filenameA") or die "oops!\n" ;
open OUT, ">", "$filenameA.max$splitLen" or die "daksdlkkalsdja\n" ; 

my $read_name = '' ;
my $read_seq = '' ;

while (<IN>) {
    if (/^>(\S+)/) {
	$read_name = $1 ;
	$read_seq = "" ;
	
	while (<IN>) {
	    
	    if (/^>(\S+)/) {
		
		#			    print "$read_name\t" . length($read_seq) . "\n" ;
		
		if ( length($read_seq) > $splitLen ) {
		    print "len of $read_name is too long! Split in bins of $splitLen !\n" ;
		    my $division = length($read_seq) / $splitLen ; 
		    my $rounded = ceil($division) ; 
		    print "division: $division , rounded $rounded \n" ;
		    
		    for (my $i = 0 ; $i < $division ; $i++ ) {
			
			#If OFFSET and LENGTH specify a substring that is partly outside the string, only the part within the string is returned.
			my $seq = substr $read_seq, $i * $splitLen, $splitLen ;
			
			$fasta{"$read_name.$i"} = $seq ;
		    }
		    
		    
		}
		else {
		    $fasta{$read_name} = $read_seq ; 
		}
		
		$read_name = $1 ;
		$read_seq = "" ;
		
		
		
	    }
	    else {
		chomp ;
		$read_seq .= $_ ;
	    }
	    
	    
	}
	
    }
}

close(IN) ;


if ( length($read_seq) > $splitLen ) {
    print "len of $read_name is too long! Split in bins of $splitLen !\n" ;
    my $division = length($read_seq) / $splitLen ;
    my $rounded = ceil($division) ;

    print "division: $division , rounded $rounded \n" ;
    
    for (my $i = 0 ; $i < $division ; $i++ ) {

	#If OFFSET and LENGTH specify a substring that is partly outside the string, only the part within the string is returned.
	my $seq = substr $read_seq, $i * $splitLen, $splitLen ; 

	$fasta{"$read_name.$i"} = $seq ;	
    }


    
}
else {
    $fasta{$read_name} = $read_seq ;
}


for my $seqname  (sort keys %fasta ) {
    print OUT ">$seqname\n$fasta{$seqname}\n" ; 
}



