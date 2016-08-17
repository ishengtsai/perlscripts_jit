#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV != 3) {
    print "$0 scaffold.name scaff.len directory \n" ;
    print "will parse out all vcf files in the current directory\n" ; 
    exit ;
}

my $scaff = shift  ;
my $scafflen = shift ; 
my $directory = shift ; 

print "$0\n printing bam files...\n" ;

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
	next unless /^$scaff/ ; 
	next if /INDEL/ ; 

	# need homozygous differences
	next unless /AF1=1/ ; 

	chomp ; 
	my @r = split /\s+/, $_ ; 

	next if $r[4] =~ ',' ; 

	$loci{$r[1]}++ ; 
	
	#print "$file\t$_\n" ; 
	
	# ref allele
	$ref{$r[1]} = $r[3] unless $ref{$r[1]} ; 

	# alt allele
	$alt{$file}{$r[1]} = $r[4] ; 

    }
    close(IN) ; 
    #print "\n" ; 
}

my @locus = () ; 
for my $key ( sort {$a<=>$b} keys %loci) {
	push(@locus, $key) ; 
}

# check if same
my %samealt = () ; 


# filter out common alleles
foreach my $pos ( @locus ) {
    
    my %alleles= () ;
    foreach my $isolate ( @isolates ) {
	
        if ( $alt{$isolate}{$pos} ) {
	    my $allele = $alt{$isolate}{$pos} ; 
            #print "$allele" ;
	    $alleles{$allele}++ ; 
        }
        else {
	    my $allele = $ref{$pos} ; 
            #print "$allele" ;
	    $alleles{$allele}++ ; 
        }
	
    }
    
    my $isdiff = 0 ;
    if ( scalar keys %alleles == 1 ) {
	#print "issame!!!!\n" ; 
	$samealt{$pos}++ ; 
    }
    #print "\n" ;
 

}


open SITES, ">", "$scaff.sites" or die "odoapsdoa\n" ;
open LOC, ">", "$scaff.locs" or die "doapadoapdao\n" ; 
open FASTA, ">", "$scaff.fasta" or die "daosdpoaodpa\n" ; 

my $count = 1 ; 

my $isolatenum = scalar @isolates ;
my $snpnum = scalar @locus - scalar keys %samealt ; 

print SITES "$isolatenum $snpnum 1\n" ; 

foreach my $isolate ( @isolates ) {

    print SITES ">Sample$count\n" ; 
    
    if ( $isolate =~ /(ED\d+)/ ) {
	print FASTA ">$1\n" ; 
    }
    else {
	print FASTA ">Sample$count\n" ; 
    }

    foreach my $pos ( @locus ) {
	next if $samealt{$pos} ; 

	if ( $alt{$isolate}{$pos} ) {
	    print SITES "$alt{$isolate}{$pos}" ; 
	    print FASTA "$alt{$isolate}{$pos}" ;
	}
	else {
	    print SITES "$ref{$pos}" ; 
	    print FASTA "$ref{$pos}" ;
	}

    }

    print SITES "\n" ; 
    print FASTA "\n" ; 
    $count++ ; 
}

print "$scaff.sites for sites file of rhomap is produced!\n" ; 


print LOC "$snpnum $scafflen L\n" ; 

foreach my $pos ( @locus ) {
    next if $samealt{$pos} ;
    print LOC "$pos " ; 
}
print LOC "\n" ; 


print "$scaff.fasta is produced!\n" ; 
