#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV != 1) {
    print "$0 directory \n" ;
    print "will parse out all vcf files in the current directory\n" ; 
    exit ;
}



my $directory = shift ; 

print "$0\n parsing vcf files...\n" ;

opendir (DIR, $directory) or die $!;


my %ref = () ; 
my %alt = () ; 
my @isolates = () ; 
my %loci = () ; 

while (my $file = readdir(DIR)) {
    
    next unless $file =~ /.vcf/ ; 
    open (IN, "$directory/$file") or die $! ; 
    push (@isolates, $file) ; 

    while (<IN>) {

	next if /^\#/ ; 
	next if /INDEL/ ; 

	# need homozygous differences
	next unless /AF1=1/ ; 

	chomp ; 
	my @r = split /\s+/, $_ ; 

	next if $r[4] =~ ',' ; 

	$loci{$r[0]}{$r[1]}++ ; 
	
	#print "$file\t$_\n" ; 
	
	# ref allele
	$ref{$r[0]}{$r[1]} = $r[3] unless $ref{$r[1]} ; 


	# alt allele
	$alt{$r[0]}{$r[1]}{$file} = $r[4] ;

    }
    close(IN) ; 
    #print "\n" ; 
}


# check if same
my %samealt = () ; 


# filter out common alleles
for my $scaff (sort keys %ref ) {
    
    foreach my $pos ( keys % { $ref{$scaff} } ) {
	
	my %alleles= () ;
	foreach my $isolate ( @isolates ) {
	    
	    if ( $alt{$scaff}{$pos}{$isolate} ) {
		my $allele = $alt{$scaff}{$pos}{$isolate} ; 
		#print "$allele" ;
		$alleles{$allele}++ ; 
	    }
	    else {
		my $allele = $ref{$scaff}{$pos} ; 
		#print "$allele" ;
		$alleles{$allele}++ ; 
	    }
	    
	}
	
	my $isdiff = 0 ;
	if ( scalar keys %alleles == 1 ) {
	    #print "issame!!!!\n" ; 
	    $samealt{$scaff}{$pos}++ ; 
	}
	#print "\n" ;
    }

}



my $count = 1 ; 

open OUT, ">", "homosnps.whole.alignment.fasta" or die "daospdadospoda\n" ; 

foreach my $isolate (@isolates) {
    
    if ( $isolate =~ /(ED\d+)/ ) {
	print OUT ">$1\n" ; 
    }
    else {
	print OUT ">Sample$count\n" ; 
    }


    for my $scaff (sort keys %ref ) {
	
	foreach my $pos ( sort {$a<=>$b} keys % { $ref{$scaff} } ) {
	    
	    
	    next if $samealt{$scaff}{$pos} ; 
	    
	    if ( $alt{$scaff}{$pos}{$isolate} ) {
		print OUT "$alt{$scaff}{$pos}{$isolate}" ; 
	    }
	    else {
		print OUT "$ref{$scaff}{$pos}" ; 
	    }
	    
	}
	

    }

    print OUT "\n" ;
    $count++ ;

    

}


print "all done! homosnps.whole.alignment.fasta produced!\n" ;
