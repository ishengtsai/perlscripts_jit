#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV != 6) {
    print "$0 final.fa uc centroid.fa.SL minimum_prior SampleNum totalSeq \n" ; 
    exit ;
}



my $priorfile = $ARGV[0] ; 
my $list = $ARGV[1] ;
my $centroid = $ARGV[2] ; 
my $minimumprior = $ARGV[3] ; 
my $sample = $ARGV[4] ; 
my $totalseq = $ARGV[5]; 

my %prior = () ; 


my $name = '' ; 


open (IN, "$priorfile") or die "daodoapod\n" ;
while (<IN>) {
    
    chomp ; 
    my @r = split /\s+/, $_ ; 
    
    if ( />(\S+) Prior=(\d+\.\d+) Length=(\d+) NormPrior=(\d+\.\d+)/ ) {
	#print "here!\n" ; 
	$prior{$1}{'P'} = $2 ; 
	$prior{$1}{'N'} = $4 ;
	$prior{$1}{'len'} = $3 ; 
    }


}
close(IN) ; 

my %removed = () ; 

open (IN, "$list") or die "daodoapod\n" ; 
while (<IN>) {
    
    chomp; 
    my @r = split /\s+/ , $_ ; 

    if ( $r[0] eq 'H' ) {
	$removed{$r[8]}++ ; 
	$prior{$r[9]}{'P'} += $prior{$r[8]}{'P'} ;
	$prior{$r[9]}{'N'} += $prior{$r[8]}{'N'} ; 
    }

}
close(IN) ; 


open (IN, "$centroid") or die "daodpado\n" ; 
open OUT, ">", "$sample\_R1_001.fastq" or die "daoodpdo\n" ; 

my $tallyprior = 0 ; 
my $totalprior = 0 ; 
my $count = 0 ; 



while (<IN>) {


    if ( />(\S+)/ ) {
	my $name = $1 ; 
	my $seq = uc(<IN>) ; 

	if ( $prior{$name}{'P'} >= $minimumprior ) {
	    $tallyprior += $prior{$name}{'P'} ;
	    $totalprior += $prior{$name}{'P'} ;
	    


	    my $abundanceCount = sprintf("%.0f", $totalseq * $prior{$name}{'P'} ) ; 
	    print "$name Prior=" . $prior{$name}{'P'} . " Length=" . $prior{$name}{'len'} . " NormPrior=" . $prior{$name}{'N'} . " SeqCount:$abundanceCount\n" ;


	    for (my $i = 0 ; $i < $abundanceCount ; $i++ ) {
		print OUT ">$sample\_" . ($i + $count) . " $name \n" ; 
		print OUT "$seq" ; 
	    }

	    $count += $abundanceCount ; 
	}
	else {
	    $totalprior += $prior{$name}{'P'} ;
	}

    }

}

print "Total prior: $totalprior\n" ; 
print "Prior above $minimumprior: $tallyprior\n" ; 
