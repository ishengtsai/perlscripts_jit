#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV != 3) {
    print "$0 species1.location species2.location all.blast\n" ; 
	exit ;
}

my $filenameA = shift ; 
my $filenameB =shift ;

my $filenameC = shift ; 


my %species1 = () ; 
my %species2 = () ; 

open (IN, $filenameA) or die "odpadosaosd\n" ; 

while (<IN>) {

    chomp ;
    if ( /(^\S+)\s+(\S+)\s+\S+\s+\S+\.\.\.\.(\d+)/) {

	#print "$1\t$2\t" . int($3). "\n" ; 

	$species1{$1}{'scaff'} = $2 ; 
	$species1{$1}{'order'} = int($3) ;

    }

}
close(IN) ; 


open (IN, "$filenameB") or die "odpadosaosd\n" ;

while (<IN>) {

    chomp ;
    if ( /(^\S+)\s+(\S+)\s+\S+\s+\S+\.\.\.\.(\d+)/) {

        #print "$1\t$2\t" . int($3). "\n" ;

	$species2{$1}{'scaff'} = $2 ;
	$species2{$1}{'order'} = int($3) ;

    }

}
close(IN) ;



open (IN, $filenameC) or die "odpadosaosd\n" ;

my %already = () ; 

while (<IN>) {

    chomp ;
    my @r = split /\s+/, $_ ; 

    next unless $r[10] < 0.00001 ; 
    next if $r[0] eq $r[1] ; 

    $r[0] =~ s/\S+\|// ; 
    $r[1] =~ s/\S+\|// ;

    #print "$r[0]\t$r[1]\n" ; 

    if ( $r[0] =~ /\.1\.1$/ ) {
	$r[0] =~ s/\.1$// ; 
    }
    if ( $r[1] =~ /\.1\.1$/ ) {
	$r[1] =~ s/\.1$// ; 
    }

    if ( $species1{$r[0]} && $species2{$r[1]} ) {

	if ( $already{"$r[0].$r[1]"} ) {
	    
	}
	else {
	    print "" . $species1{$r[0]}{'scaff'} . "\t$r[0]\t" . $species1{$r[0]}{'order'} . "\t" . $species1{$r[0]}{'order'} . "\t" ; 
	    print "" . $species2{$r[1]}{'scaff'} . "\t$r[1]\t" . $species2{$r[1]}{'order'} . "\t" .$species2{$r[1]}{'order'} . "\t" ;
	    print "$r[10]\n" ;
	    $already{"$r[0].$r[1]"}++ ; 
	}


 
    }
    elsif ( $species1{$r[1]} && $species2{$r[0]} ) {

	if ( $already{"$r[1].$r[0]"} ) {

	}
	else {
	    
	    print "" . $species1{$r[1]}{'scaff'} . "\t$r[1]\t" . $species1{$r[1]}{'order'} . "\t" . $species1{$r[1]}{'order'} . "\t" ;
	    print "" . $species2{$r[0]}{'scaff'} . "\t$r[0]\t" . $species2{$r[0]}{'order'} . "\t" . $species2{$r[0]}{'order'} . "\t" ;
	    print "$r[10]\n" ;
	    $already{"$r[1].$r[0]"}++ ; 
	}

    }

}
