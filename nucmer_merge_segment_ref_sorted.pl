#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV != 2) {
    print "$0 coords listfile\n\n" ; 
	exit ;
}

my $filenameA = $ARGV[0];
my $listfile = $ARGV[1] ; 


my %list = () ; 
open (IN, "$listfile") or die "ooops\n" ; 
while (<IN>) {

    chomp; 
    $list{$_}++ ; 

}
close(IN); 


open (IN, "$filenameA") or die "oops!\n" ;

my @firstline = split (/\s+/, <IN>) ; 


my $previous = $firstline[12] ; 
my $start = $firstline[0] ; 
my $end = $firstline[1] ; 

my $len = $firstline[5] ; 

my $len_F = 0 ; 
my $len_R = 0 ; 

if ( $firstline[3] > $firstline[2] ) {
    $len_F = $firstline[5] ; 
}
else {
    $len_R = $firstline[5] ;
}


my %scafflen = () ; 
my %maxmatch = () ; 
my @segments = () ; 



while (<IN>) {

    chomp; 
    my @r = split /\s+/, $_ ; 

    $scafflen{$r[12]} = "$r[8]"  ;

    if ( $r[12] eq $previous ) {
	$end = $r[1] ; 
	$len += $r[5] ; 

	if ( $r[3] > $r[2] ) {
	    $len_F += $r[5] ;
	}
	else {
	    $len_R += $r[5] ;
	}

    }
    else {


	push(@segments, "$start\t$end\t$previous\t$len\t$len_F\t$len_R") ; 

	if ( $maxmatch{$previous}  ) {
	    $maxmatch{$previous} = $len if $len > $maxmatch{$previous};
	}
	else {
	    $maxmatch{$previous} = $len ; 
	}


	$previous = $r[12] ; 
	$start = $r[0] ; 
	$end = $r[1] ; 
	$len = $r[5] ; 

	$len_F = 0 ; 
	$len_R = 0 ; 

	if ( $r[3] > $r[2] ) {
            $len_F = $r[5] ;
        }
        else {
            $len_R = $r[5] ;
        }


    }


}
close(IN); 

if ( $maxmatch{$previous}  ) {
    $maxmatch{$previous} = $len if $len > $maxmatch{$previous};
}
else {
    $maxmatch{$previous} = $len ;
}


my %scaffold_found = () ; 

push(@segments, "$start\t$end\t$previous\t$len\t$len_F\t$len_R") ;

foreach (@segments ) {

    my @r = split /\s+/, $_ ; 
    next unless $list{$r[2]} ; 

    $scaffold_found{$r[2]}++ ; 

    print "$r[0]\t$r[1]\t$r[2]\t$r[3]" ; 

    my $proportion = sprintf("%.3f", $r[3]  / $scafflen{$r[2]} ) ; 
    print "\t$proportion\t" ; 

    print "$r[4]\t$r[5]\t" ; 

    if ( $r[4] > $r[5] ) {
	print "+\t" ; 
    }
    else {
	print "-\t" ; 
    }


    if ( $maxmatch{$r[2]} == $r[3] ) {
	print "\tMAX\n" ; 
    }
    else {
	print "\n" ; 
    }



}



for my $scaff ( keys %list ) {

    print "\#\t$scaff not found!\n" unless $scaffold_found{$scaff} ; 

}
