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
	print "\n" ; 
    }
    if (/^\d+/) {
        chomp ;
        my @r = split /\s+/, $_ ;

	# exclude copy less than 5
	next if $r[3] < 5 ; 

	# exclude less than 3 base
	next if $r[2] <= 3 ; 

	# set within 5kb
	if ( $r[1] < 5000 && $r[2] < 10 ) {
	    print "$seq\t$contig_len{$seq}\tSTART\t$r[0]\t$r[1]\t$r[2]\t$r[3]\t$r[13]\n" ; 
	}
	elsif ( ($contig_len{$seq} -  $r[1] ) < 5000 && $r[2] < 10 ) {
            #print "$seq\t$contig_len{$seq}\tEND\t$_\n" ;
	    print "$seq\t$contig_len{$seq}\tEND\t$r[0]\t$r[1]\t$r[2]\t$r[3]\t$r[13]\n" ;
        }
	





        #for (my $i = 0 ; $i < 17 ; $i++ ) {
        #    print "\t$r[$i]" ;
        #}
        #print "\n" ;
    }

}
