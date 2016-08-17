#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';




if (@ARGV != 1) {
    print "$0 frg \n" ;
	exit ;
}

my $filenameA = $ARGV[0];



open OUT, ">", "$filenameA.unpaired.fa" ;
open OUTF, ">", "$filenameA\_1.fastq" ; 
open OUTR, ">", "$filenameA\_2.fastq" ; 

open (IN, "$filenameA") or die "oops!\n" ;

my %read = () ;

my $readname = '' ;
my $seq = '' ; 

while (<IN>) {

    if ( /^acc:(\S+)/ ) {
	$readname = $1 ; 
    }
    
    if ( /^seq:/ ) {
	$seq = '' ; 
	while (<IN>) {
	    if (/^\./ ) {
		#print "$readname $seq\n" ; 
		last ; 
	    }
	    else {
		chomp; 
		$seq .= $_ ; 
	    }
	}
    }
    if ( /^qlt:/ ) {
	my $qlt= '' ;
	while (<IN>) {
	    if (/^\./ ) {

		if ( $readname =~ /(\S+)a$/ ) {
		    $read{$1}{'F'} = "\@$readname\n$seq\n+\n$qlt\n" ; 
		}
		elsif ( $readname =~ /(\S+)b$/ ) {
                    $read{$1}{'R'} = "\@$readname\n$seq\n+\n$qlt\n" ; 
                }
		else {
		    $read{$readname}{'UP'} = "\@$readname\n$seq\n+\n$qlt\n" ; 
		}

		last ; 
	    }
	    else {
		chomp;
		$qlt .= $_ ;
	    }
	}
    }
    


}
close(IN) ; 


my $penum = 0 ; 
my $senum = 0 ; 

for my $readname ( sort keys %read ) {
    
    if ( $read{$readname}{'F'} ) {
	print OUTF $read{$readname}{'F'} ;
	print OUTR $read{$readname}{'R'} ;
	$penum++ ; 
    }
    else {
	print OUT $read{$readname}{'UP'} ;
	$senum++ ; 
    }

}


print "total of $penum PE reads!\n" ; 
print "total of $senum unpaired reads!\n" ; 
