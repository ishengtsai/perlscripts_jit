#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';




if (@ARGV != 4) {
    print "$0 Fread Rread minlen removeN\n" ;
    exit ;
}

my $filenameA = $ARGV[0];
my $filenameB = $ARGV[1] ; 
my $minlen = $ARGV[2] ; 
my $removeN = $ARGV[3] ; 

open OUTF, "| gzip -c > $filenameA.atleast$minlen\_1.fastq.gz" or die "oooops!\n" ;
open OUTR, "| gzip -c > $filenameB.atleast$minlen\_2.fastq.gz" or die "oooops!\n" ;


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


while (<IN>) {

    my $nametmp = $_ ;
    my $seq = <IN> ;
    my $tmp = <IN> ;
    my $qual = <IN> ;
    my $finalend = 0 ;

    my $name2tmp = <IN2> ; 
    my $seq2 = <IN2> ; 
    my $tmp2 =<IN2> ; 
    my $qual2 = <IN2> ; 

    my @name = split /\s+/, $nametmp ; 
    my @name2 = split /\s+/, $name2tmp ; 

    $name[0] =~ s/\/[12]$// ; 
    $name2[0] =~ s/\/[12]$// ; 


    if ( $name[0] ne $name2[0] ) {
	print "offset!!!!  $name[0] $name2[0]\n" ; 
	chomp($seq) ; 
	chomp($seq2) ; 
	
	$Fread{$name[0]} = "$name[0]\t$seq\t$qual" ; 
	$Rread{$name[0]} = "$name2[0]\t$seq2\t$qual2" ; 
	next ; 
    }

    if ( $removeN == 1 ) {
	if ( $seq =~ /N/ || $seq2 =~ /N/ ) {
	    $Nreads++ ;
	    next ; 
	}
    }


    if ( length($seq) >= $minlen && length($seq2) >= $minlen ) {
	print OUTF "$name[0]\n$seq\+\n$qual" ; 
	print OUTR "$name2[0]\n$seq2\+\n$qual2" ; 

    }
    else {
	$exclude++ ; 

    }


#    last;

    $count++ ; 
    #last if $count == 10000 ; 

}

close(IN) ;

for my $readname (keys %Fread ) {

    if ( $Rread{$readname} ) {
	my @readF = split /\s+/, $Fread{$readname} ; 
	my @readR = split /\s+/, $Rread{$readname} ; 

	if ( length ($readF[1]) >= $minlen && length($readR[1]) >= $minlen ) {
	    print OUTF "$readF[0]\n$readF[1]\n\+\n$readF[2]\n" ; 
	    print OUTR "$readR[0]\n$readR[1]\n\+\n$readR[2]\n" ;
	}
    }

    $count++ ; 
}


print "a total of $count reads included\n" ; 
print "a total of $exclude reads not reaching length\n" ; 
print "a total of $Nreads reads contain Ns\n" ; 



