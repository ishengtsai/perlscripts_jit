#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV != 3) {
	print "$0 gff lineages-2017-03-17.csv diamondFile\n\n" ;
	exit ;
}

my $gfffile = $ARGV[0] ; 
my $filenameA = $ARGV[1];
my $diamondfile = $ARGV[2] ; 


my %tax2kingdom = () ;
my %tax2species = () ; 
my %tax2genus = () ; 

my %proteins = () ;
my %proteins2scaffold = () ; 

my %scaffoldNumOfGenes = (); 

my %scaffoldContent = () ; 


open (IN, "$gfffile") or die "daisdiaoidiaod\n" ;
while (<IN>) {
    
    my @r = split /\s+/, $_ ; 

    if ( $r[2] eq "gene" && $r[8] =~ /Name=(\S+)\;$/) {
	my $protein = $1 ; 
	$proteins2scaffold{$protein} = $r[0] ;
	$scaffoldNumOfGenes{$r[0]}++ ; 
    }

}


open (IN, "$filenameA") or die "oops!\n" ;
while (<IN>) {
    
    my @r = split /\,/, $_ ;    
#    print "$r[0]\t$r[1]\t$r[7]\n" ; 

    $tax2kingdom{$r[0]} = $r[1] ;
    $tax2genus{$r[0]} = $r[6] ;
    $tax2species{$r[0]} = $r[7] ; 
    
}
close(IN) ; 

print "tax files read, now parsing....\n" ;

open OUT, ">", "$diamondfile.taxfile" or die "doadpadpso\n" ; 



open (IN, "$diamondfile") or die "oops!\n" ;
while (<IN>) {

    my @r = split /\s+/, $_ ;

    next if $proteins{$r[0]} ; 
    
    if ( $r[1] =~ /\S+\.(\d+)$/ ) {
	my $taxid = $1 ; 
	my $scaffold = $proteins2scaffold{$r[0]} ; 
	print OUT "$scaffold\t$r[0]\t$taxid\t$tax2kingdom{$taxid}\t$tax2genus{$taxid}\t$tax2species{$taxid}\n" ;

	$proteins{$r[0]}++  ;
	$scaffoldContent{ $scaffold }{ $tax2kingdom{$taxid} } ++ ; 
	
    }


}
close(IN) ;


for my $scaffold (sort keys %scaffoldNumOfGenes ) {

    print "$scaffold\t$scaffoldNumOfGenes{$scaffold}\t" ;

    if ( $scaffoldContent{ $scaffold } ) {
	my $total = 0 ;
	my $max = 0 ; 
	for my $kingdom ( keys %{ $scaffoldContent{ $scaffold } } ) {
	    my $number = $scaffoldContent{ $scaffold }{$kingdom} ;
	    $total += $number ; 
	}

	print "$total\t" ;

	my $morethan50 = 0 ; 
	for my $kingdom ( keys %{ $scaffoldContent{ $scaffold } } ) {
	    my $number = $scaffoldContent{ $scaffold }{$kingdom} ;
	    if ( (  $number / $total  ) > 0.5 ) {
		print "majority\t$kingdom\t$number\n" ;
		$morethan50 = 1 ; 
	    }
	}

	if ( $morethan50 == 0 ) {
	    print "ambiguous" ;
	    for my $kingdom ( keys %{ $scaffoldContent{ $scaffold } } ) {
		my $number = $scaffoldContent{ $scaffold }{$kingdom} ;
		print "\t$kingdom\t$number" ;
	    }
	    print "\n" ;
	}

	

    }
    else {
	print "0\n" ; 
    }




	
}
