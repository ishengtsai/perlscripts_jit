#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV != 7) {
	print "$0 fa.len.txt coords Chr1file Chr2file ChrXfile v4scaffoldname diminution.file \n\n" ;
	exit ;
}

my $lenfile = shift ; 
my $filenameA = shift ; 
my $chrIfile = shift ; 
my $chrIIfile = shift ; 
my $chrXfile = shift ; 
my $convertfile = shift ; 
my $diminutionfile = shift ; 


my %seq_len = () ;
my @seq_order = () ; 


#my @ratti_scaffolds = ( "Sratt_Chr1_000001", "Sratt_Chr2_000001", "Sratt_ChrX_000001", "Sratt_ChrX_000002", "Sratt_ChrX_000003", "Sratt_ChrX_000004", "Sratt_ChrX_000005", "Sratt_ChrX_000006", "Sratt_ChrX_000007", "Sratt_ChrX_000008" ) ;

my @ratti_scaffolds = ( "chrI", "chrX", "chrII"   ) ; 

open(IN, "$lenfile") or die "oops!\n" ;

while(<IN>) {
    chomp; 
    if ( /(\S+)\s+(\d+)/) {
	$seq_len{$1} = "$2" ;  
	push(@seq_order, $1) ; 
    }
}
close(IN) ; 


my %chrI = () ; 
my %chrII = () ; 
my %chrX = () ; 


open (IN, "$chrIfile") or die "diaidaodiaod\n" ; 
while (<IN>) {
    chomp; $chrI{$_}++ ; 
}
close(IN); 

open (IN, "$chrIIfile") or die "diaidaodiaod\n" ;
while (<IN>) {
    chomp; $chrII{$_}++ ;
}
close(IN);

open (IN, "$chrXfile") or die "diaidaodiaod\n" ;
while (<IN>) {
    chomp; $chrX{$_}++ ;
}
close(IN);

my %convert = () ;


open (IN, "$convertfile") or die "diaidaodiaod\n" ;
while (<IN>) {
    chomp; 
    my @r = split /\s+/, $_ ; 
    $convert{$r[1]} = $r[0]  ;
}
close(IN);

my %diminution = () ; 
open (IN, "$diminutionfile") or die "daodaopdpoadp\n" ; 
while (<IN>) {
    chomp; 
    my @r = split /\s+/, $_ ; 
    $diminution{$r[0]} = "$r[1].$r[2]" ; 

}


open (IN, "$filenameA") or die "oops!\n" ;

my %seq_match_segment = () ; 
my %seq_match_total = () ; 

while (<IN>) {
    chomp ;
    my @r = split /\s+/, $_ ;

    my $match = 0 ; 

    if ( $r[2] > $r[3] ) {
	$match = $r[2] - $r[3] + 1 ; 
    }
    else {
	$match = $r[3] - $r[2] + 1 ; 
    }

    if ( $chrI{$r[11]} ) { 
	$seq_match_segment{$r[12]}{'chrI'} += $match ; 
    }
    elsif ( $chrII{$r[11]} ) {
	$seq_match_segment{$r[12]}{'chrII'} += $match ;
    }
    elsif ( $chrX{$r[11]} ) {
	$seq_match_segment{$r[12]}{'chrX'} += $match ;

    }
    else {
	$seq_match_segment{$r[12]}{$r[11]} += $match ;
    }
    $seq_match_total{$r[12]}+= $match ;
    
    
}
close(IN); 


print "seq.name\tv4\t\tdimuntion\tseq.len\tmatch.total\t@ratti_scaffolds\n" ; 

foreach my $seq (@seq_order) {



    if ( $seq_match_total{$seq} ) {

	print "$seq\t$convert{$seq}\t"  ;

	if ( $diminution{ $convert{$seq} } ) {
	    print "$diminution{ $convert{$seq} }" ; 
	}
	else {
	    print "NA" ; 
	}
	print "\t$seq_len{$seq}\t$seq_match_total{$seq}\t" ; 
	
	
	foreach my $rattiseq (  @ratti_scaffolds  ) {
	    
	    if ( $seq_match_segment{$seq}{$rattiseq} ) {
		print "$seq_match_segment{$seq}{$rattiseq}\t" ; 
	    }
	    else {
		print "0\t" ; 
	    }
	    
	}
	print "\n" ; 
	
    }
    else {
	#print "$seq\t$seq_len{$seq}\t0\t0\t0\t0\t0\t0\t0\t0\t0\t0\t0\t0\t0\n" ;  
	print "$seq\t$convert{$seq}\t" ; 

	if ( $diminution{ $convert{$seq} } ) {
            print "$diminution{ $convert{$seq} }" ;
        }
        else {
            print "NA" ;
        }

	print "\t$seq_len{$seq}\t0\t0\t0\t0\n" ; 
    }




    #last ; 
}
