#!/usr/bin/perl -w
use strict;
use warnings;




my $largest = 0;
my $contig = '';


if (@ARGV < 3) {
	print "$0 repeatlib.fasta RM.out match_proportion\n\n" ;
	exit ;
}

my $filenameA = shift @ARGV;
my $RM_file = shift @ARGV;
my $proportion = shift @ARGV  ;

open OUT, ">", "$RM_file.full.copy.TEs.$proportion" or die "ooooooooooooooops\n" ;
open OUTSUM, ">", "$RM_file.full.copy.TEs.$proportion.summary" or die "ooooooooooooooops\n" ;



my %contig_seq = () ;
my %contig_type = () ;
my %contig_len = () ;


open (IN, "$filenameA") or die "oops!\n" ;

	my $read_name = '' ;
	my $read_seq = '' ;
        my $read_type = '' ;


	while (<IN>) {
	    if (/^>(\S+)\#(\S+)/ || /^>(\S+)/) {
		$read_name = $1 ;

		if ( $2) {
		    $read_type = $2 ;
		}
		else {
		    $read_type = 'Unknown' ;
		}



		$read_seq = "" ;
		
	
		while (<IN>) {

			if (/^>(\S+)\#(\S+)/ || /^>(\S+)/  ) {
			    
				$contig_seq{$read_name} = $read_seq ;

				$contig_len{$read_name} = length($read_seq) ;
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

$contig_seq{$read_name} = $read_seq ;
$contig_len{$read_name} = length($read_seq) ;
close(IN) ;



my %LTR_coords = () ;




open (IN, "$RM_file") or die "oops!\n" ;


my %repeat_found = () ;
my %repeat_total = () ;

my %repeat_full_found = () ;
my %repeat_full_total = () ;


while (<IN>) {


    #print "$_" ;
#    print "$line[5]\n" ;
#    print "$line[10]\n" ;


    next if /^\n/ ;

    chomp ;
    my @line = split /\s+/, $_ ;



    if ( $line[0] eq '') {
	shift(@line) ;
    }


    

    next if $line[0] =~ /\D+/ ;

    $contig_type{$line[9]} = $line[10];


    #some unwanted parsing/modification
    next if $line[11] =~ /Simple_repeat/ ;
    next if $line[11] =~ /Low_complexity/ ;
    next if $line[9] =~ /\(.+\)n/ ;
    next if $line[9] =~ /rich/ ;
    next if $line[9] =~ /HSATII/ ;
    next if $line[9] =~ /polypyrimidine/ ;

 #   print "$line[9]\n" ; 
 #   next ; 

    unless ( $contig_seq{$line[9]} ) {
        print "Consensus not found: @line\n" ; 
        next ;
    }
    if ( $line[12] > $contig_len{$line[9]} ) {
	print "error: $_ $contig_len{$line[9]} \n" ;
	next ;
    }



    #print "$line[4]\n" ;


    my $match_len = 0 ;
    if ( $line[8] eq 'C') {
	$match_len = $line[12] - $line[13] + 1 ;
    }
    else {
	$match_len = $line[12] - $line[11] + 1 ;
    }


    $repeat_found{$line[9]}++;
    $repeat_total{$line[9]} += $match_len;




    if ( ( $match_len / length($contig_seq{$line[9]}) )  >= $proportion ) {
	print OUT "$match_len @line\n" ;
	$repeat_full_found{$line[9]}++;
	$repeat_full_total{$line[9]} += $match_len;
    }



    #last ;




}
close(IN) ;


print OUTSUM "repeat\trepeat_len\tnum_hits\tnum_bases\tnum_hits_full\tnum_bases\ttype\n" ;

for (sort keys %repeat_found) {
    print OUTSUM "$_\t". (length($contig_seq{$_})) ."\t$repeat_found{$_}\t$repeat_total{$_}\t" ;

    if ( $repeat_full_found{$_} ) {
	print OUTSUM "$repeat_full_found{$_}\t$repeat_full_total{$_}\t" ;
    }
    else {
	print OUTSUM "0\t0\t" ;
    }

    if ( $contig_type{$_} ) {
	print OUTSUM "$contig_type{$_}\n" ;
    }
    else {
	print OUTSUM "Unknown\n" ;
    }


}


print "all done!\n" ;
