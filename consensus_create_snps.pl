#!/usr/bin/perl -w
use strict;


my $largest = 0;
my $contig = '';


if (@ARGV != 1) {
	print "$0 directory\n\n" ;
	exit ;
}

my $directory = shift @ARGV;
opendir (DIR, $directory) or die $!;

my %allseq = () ; 

while (my $file = readdir(DIR)) {

    my $sample ;

    if ( $file =~ /^(\S+).fa/ ) {
	$sample = $1 ;
	next if $sample =~ /\./ ; 
    }
    else {
	next ; 
    }

    print "reading $sample ...\n" ; 
    
    open (IN, "$file") or die "oops!\n" ;
    
    my $read_name = '' ;
    my $read_seq = '' ;
    
    while (<IN>) {
	if (/^>(\S+)/) {
	    $read_name = $1 ;
	    $read_seq = "" ;
	    
	    while (<IN>) {
		
		if (/^>(\S+)/) {
		    $allseq{$sample} .= uc($read_seq) ; 

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
    
    $allseq{$sample} .= uc($read_seq) ;

}

print "all samples loaded!\n" ; 

# check length

my $finalLen = 0 ;
for my $sample (keys %allseq ) {

   $finalLen = length($allseq{$sample}) ; 
   print "$sample\t$finalLen\n" ;
}



print "now getting polymorphic sites.. this may take a while\n" ; 
my $totalMissing = 0 ; 
my $total = 0 ; 
my %fastas = () ; 

for (my $i = 0 ; $i < $finalLen ; $i++) {

    print "$i bases gone through\n" if $i % 100000 == 0 ;
    my $diff = 0 ; 
    my $missing = 0 ; 
    my %alleles = () ; 

    for my $sample (keys %allseq ) {
	my $base = substr( $allseq{$sample}, $i , 1) ; 
	$missing = 1 if $base eq 'N' ;
	$alleles{$base}++ ; 
    }

    if ($missing == 1 ) {
	$totalMissing++ ;
	next ; 
    }

    my $numAlleles = scalar keys %alleles ;

    if ( $numAlleles > 1 ) {
	for my $sample (keys %allseq ) {
	    my $base = substr( $allseq{$sample}, $i , 1) ;
	    $fastas{$sample} .= "$base" ; 
	}
	$total++ ; 
    }
    else {
	next ; 
    }

    #print "$i\n" ; 

    
}



print "$total polymorphic sites\n" ;
print "$totalMissing sites have been excluded\n" ; 

open OUT, ">", "parsed.sites.fasta" or die "diadiaodia\n" ;

for my $sample (sort keys %fastas) {
    print OUT ">$sample\n" ;
    print OUT "$fastas{$sample}\n" ; 

}
close(OUT) ;


print "parsed.sites.fasta printed!\n" ;



