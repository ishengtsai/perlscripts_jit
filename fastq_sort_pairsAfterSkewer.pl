#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';




if (@ARGV != 2) {
    print "$0 Fread Rread \n" ; 
    exit ;
}

my $filenameA = $ARGV[0];
my $filenameB = $ARGV[1] ; 
my $minlen = $ARGV[2] ; 
my $removeN = $ARGV[3] ; 

#open OUTF, "$filenameA.sorted_1.fastq" or die "oooops!\n" ;
open OUTR, ">", "$filenameA.sorted_2.fastq" or die "doasodppaosdpo\n" ; 


if ( $filenameA =~ /gz$/ ) {
    open (IN, "zcat $filenameA |") or die "oops!\n" ;
    open (IN2, "zcat $filenameB |") or die "oops!\n" ;
}
else {
    open (IN, "$filenameA") or die "oops!\n" ;
    open (IN2, "$filenameB") or die "oops!\n" ;
}


my $count = 0 ; 
my $exclude = 0 ; 
my $Nreads = 0 ; 

my %Fread = () ; 
my %Rread = () ; 


while (<IN2>) {

    my $nametmp = $_ ;
    my $seq = <IN2> ;
    my $tmp = <IN2> ;
    my $qual = <IN2> ;
    my $finalend = 0 ;

    my $name ;

    if ( $nametmp =~ /(.+)\/2/  ) {
	$name = $1 ; 
    }
    $Rread{$name} = "$nametmp$seq$tmp$qual" ; 
}
close(IN2) ; 


while (<IN>) {

    my $name2tmp = $_ ; 
    my $seq2 = <IN> ; 
    my $tmp2 =<IN> ; 
    my $qual2 = <IN> ; 

    my $name ;
    if ( $name2tmp =~ /(.+)\/1/ ) {
	$name =$1 ;
    }
    print OUTR $Rread{$name} ; 

}

close(IN) ;



