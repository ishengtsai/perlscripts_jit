#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV != 1) {
    print "$0 fasta\n" ; 
    exit ;
}

my $filenameA = $ARGV[0] ;


my %fastas = () ; 


open (IN, "$filenameA") or die "oops!\n" ;

my $read_name = '' ;
my $read_seq = '' ;

while (<IN>) {
            if (/^>(\S+)/) {
                $read_name = $1 ;
                $read_seq = "" ;
                $read_name =~ s/\#/\./gi ;

                while (<IN>) {

                        if (/^>(\S+)/) {
			    $fastas{$read_name} = $read_seq ; 
                            $read_name = $1 ;
                            $read_seq = "" ;
                            $read_name =~ s/\#/\./gi ;
                        }
                        else {
                            chomp ;
                            $read_seq .= $_ ;
                        }
                }

            }
}
close(IN) ;
$fastas{$read_name} = $read_seq ;





my $intrascaffold_gap = 0 ; 

open READ, ">", "$filenameA.agp" or die "oooops\n" ; 
open FASTA, ">", "$filenameA.contigs.fa" or die "oooooops\n" ; 


for my $seq_name (sort keys %fastas) {

    my $seq = $fastas{$seq_name} ;
    chomp($seq) ;
    my $seq_len = length($seq) ;       
    $seq = uc($seq) ; 
    
    if ($seq =~ /N/ ) {
	
	
	
	my @seq_parts = split /N+/ , $seq ;
	my $relative_position = 1 ; 
	
	$intrascaffold_gap += $#seq_parts ;
	
	my $start = 1 ;
	my $end ;
	my $count = 1 ; 
	
	for (my $i = 0 ; $i < @seq_parts ; $i++) {

	    my $seq_contig = $seq_parts[$i] ; 
	    my $seq_len = length($seq_parts[$i]) ;
	    
	    $end = $start + $seq_len - 1; 
	    
	    print READ "$seq_name\t$start\t$end\t$count\tW\t$seq_name.$count\t1\t$seq_len\t+\n" ;		   
	    print FASTA ">$seq_name.$count\n$seq_contig\n" ; 
		    $count++ ; 
	    
	    my $gap = 0 ; 
	    $seq =~ s/^$seq_contig//gi ; 
	    
	    if ( $seq =~ /(^N+)/ ) {
		my $seq_gap = $1 ; 
		my $seq_gap_len = length($seq_gap) ; 
		
		$seq =~ s/^$seq_gap//gi ; 
		
		$start = $end +1 ;
		$end = $start + $seq_gap_len - 1 ; 
		
		print READ "$seq_name\t$start\t$end\t$count\tN\t$seq_gap_len\tscaffold\tyes\tpaired-ends\n" ; 
		$count++ ; 
	    }
	    
	    
	    $start = $end +1 ; 
	    
	    
	}
	
    }
    else {
	
	
	my $seq_len = length($seq) ;
	print READ "$seq_name\t1\t$seq_len\t1\tW\t$seq_name\t1\t$seq_len\t+\n" ;
	print FASTA ">$seq_name\n$seq\n" ; 
	
	
	
    }

    
	
}





print "Preparation done! There are a total of $intrascaffold_gap intrascaffold gaps\n" ; 
print "All done! final agp file produced: $filenameA.agp\n" ; 
print "All done (really!) final contig file produced: $filenameA.contigs.fa\n" ; 





sub checkpath {
my $program = shift ;

	if ( `which $program` ) {
		print "found! $program path: " , `which $program` ;
	}
	else {
		print "$program path not found!\n" ;
		exit ;
	}
}

