#!/usr/bin/perl -w
use strict;



if (@ARGV != 3) {
	print "$0 groups.txt fastafile SP\n\n" ;
	print "create partitioned list\n" ; 

	exit ;
}

my $file = shift @ARGV;
my $fastafile = shift @ARGV ; 
my $SPfile = shift @ARGV ; 

my %SP = () ; 
my %fasta = () ; 


open (IN, "$SPfile") or die "daoidaodiaos\n" ; 
while (<IN>) {

    next if /^\#/ ; 
    chomp ; 
    my @r = split /\s+/, $_ ; 

    $SP{$r[0]}++ if $r[9] eq 'Y' ; 


}
close(IN) ; 

open (IN, "$fastafile") or die "daidaodai\n" ; 
while (<IN>) {

    chomp; 
    if ( /^>(\S+)/ ) {
	chomp; 
	my $name = $1 ; 
	my $seq = <IN> ; 
	chomp($seq) ; 

	$fasta{$name} = ">$name\n$seq\n"  ; 
    }
}
close(IN); 


open (IN, "$file") or die "oops!\n" ;
open OUT, ">", "$file.SP.summary" or die "can't create $file.singletonCluster\n" ;



my $count = 0 ;
my %cluster_size = () ;

my %shared_gene = () ;

## read in the cufflink annotations
while (<IN>) {

    chomp ; 
    #print "$_\n" ;
    my @r = split /\s+/, $_ ;


    my $peptide_present = 0 ;  ; 
    my $Tw_present = 0 ; 
    my $Td_present = 0 ; 
    my $Tp_present = 0 ;
    my $Tf_present = 0 ;

    for (my $i = 0 ; $i < @r ; $i++ ) {
	if ( $SP{$r[$i]}  ) {
	    $peptide_present++ ; 
	    
	    $Tw_present++ if $r[$i] =~ /^Tw/ ; 
	    $Td_present++ if $r[$i] =~ /^Td/ ;
	    $Tf_present++ if $r[$i] =~ /^Tf/ ;
	    $Tp_present++ if $r[$i] =~ /^Tp/ ;


	}

    }

    print OUT "$_\t$peptide_present\t$Tw_present\t$Td_present\t$Tf_present\t$Tp_present\t" ; 


    open FA, ">", "tmp.fa" or die "daodoapdoa\n" ; 
    for (my $i = 0 ; $i < @r ; $i++ ) {
	print FA "$fasta{$r[$i]}" ; 
    }
    close(FA) ; 

  
    system("mafft --maxiterate 1000 --localpair tmp.fa > tmp.aln") ;
    system("fasta2singleLine_IMAGE.pl tmp.aln tmp.SL.aln") ;

    open (IN2, "tmp.SL.aln") or die "daisdaodioa\n" ; 
    my %sakura_seqs = () ; 
    while (<IN2>) {
	if (/>(\S\S)/ ) {
	    my $name = $1 ; 
	    my $seq = <IN2> ; chomp($seq) ; 	    
	    $sakura_seqs{$name} = $seq ; 
	}
    }
    close(IN2) ; 

    # Tw vs Td
    my ($simi, $simigap) = similarity( $sakura_seqs{'Tw'}, $sakura_seqs{'Td'} ) ;
    print OUT "$simi\t$simigap\t" ; 

    # Tw vs Tf
    ($simi, $simigap) = similarity( $sakura_seqs{'Tw'}, $sakura_seqs{'Tf'} ) ;
    print OUT "$simi\t$simigap\t" ;

    # Tw vs Tp
    ($simi, $simigap) = similarity( $sakura_seqs{'Tw'}, $sakura_seqs{'Tp'} ) ;
    print OUT "$simi\t$simigap\n" ;

    
    


    $count++ ;
    #last if $count == 2;


}



sub similarity {

    my $aln1 = shift ; 
    my $aln2 = shift ; 

    my $same = 0 ;
    my $bothnucleotide = 0 ;
    my $bothgap =  0 ; 

    for (my $i = 0 ; $i < length($aln1) ; $i++ ) {
	my $base1 = substr($aln1, $i, 1) ;
	my $base2 = substr($aln2, $i, 1) ;

        if ( $base1 eq '-'  && $base2  eq '-' ) {
	    $bothgap++ ; 
	}
	if ( $base1 eq '-'  || $base2  eq '-' ) {
	    next ;
	}

	$same++ if $base1 eq $base2 ;
	$bothnucleotide++ ;
    }

    my $similarity = sprintf ("%.3f", $same / $bothnucleotide ) ;
    my $similarity_gap = sprintf ("%.3f", $same / ( length($aln1) - $bothgap ) ) ;

    return($similarity, $similarity_gap) ; 


}
