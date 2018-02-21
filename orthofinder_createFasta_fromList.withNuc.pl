#!/usr/bin/perl -w
use strict;


my $PI = `echo $$` ; chomp($PI); 


if (@ARGV != 4) {
    print "$0 Orthogroups.txt.singletonCluster merged.fasta merged.nuc.fasta /home/ijt/bin/pal2nal.v14/pal2nal.pl \n" ; 
    print "note! stop codons have been excluded\n" ; 
	exit ;
}

my $file = shift @ARGV;
my $fasta_file1 = shift @ARGV ;
my $fasta_file2 = shift @ARGV ; 
my $pal2nalCommand = shift @ARGV ;

my %seqs  = () ;
my %seqs_nuc = () ; 

open (IN, $fasta_file1) or die "can't open $fasta_file1!\n" ; 
my $species = '' ; 
my $read_name = '' ;
my $read_seq = '' ;
while (<IN>) {
    if (/^>(\S+)\|(\S+)/) {
	$read_name = $2 ;
	$read_seq = "" ;
	$species = $1 ;  
	
	while (<IN>) {
	    $read_seq =~ s/\*//g ;
	    
	    if (/^>(\S+)\|(\S+)/) {
		
		
		$seqs{$species}{$read_name} = $read_seq ;
		
		
		$read_name = $2 ;
		$species = $1  ;
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
$read_seq =~ s/\*//g ;
$seqs{$species}{$read_name} = $read_seq ;

open (IN, $fasta_file2) or die "can't open $fasta_file2!\n" ;

$species = '' ;
$read_name = '' ;
$read_seq = '' ;
while (<IN>) {
    if (/^>(\S+)\|(\S+)/) {
	$read_name = $2 ;
	$read_seq = "" ;
	$species = $1 ;

	while (<IN>) {
	    $read_seq =~ s/\*//g ;

	    if (/^>(\S+)\|(\S+)/) {


		$seqs_nuc{$species}{$read_name} = $read_seq ;


		$read_name = $2 ;
		$species = $1  ;
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
$read_seq =~ s/\*//g ;
$seqs_nuc{$species}{$read_name} = $read_seq ;







mkdir "fastas.$PI" or die "ooops\n" ; 
chdir "fastas.$PI" ; 



open (IN, "../$file") or die "oops! erm \n" ;

my $count = 0 ;

## read in the cufflink annotations
while (<IN>) {

    chomp ; 
#    print "$_\n" ;

    my @r = split /\s+/, $_ ;

    my $group = '' ;


    if ($r[0] =~ /(OG\S+)\:/) {
	$group = $1 ;
    }

    open OUT, ">", "$group.fa" or die "ooops\n" ;
    open OUTNUC, ">", "$group.nuc.fa" or die "daosdpadoaopd\n" ; 
    
    my $ismissing = 0 ; 

    for (my $i = 1 ; $i < @r ; $i++ ) {

	#print "$r[$i]\n" ;

	if ( $r[$i] =~ /(^\S+)\|(\S+)/ ) {

	    #print "$1 $2\n" ;
	    if ( $seqs{$1}{$2} ) {
		print OUT ">$1\n$seqs{$1}{$2}\n" ;
		print OUTNUC ">$1\n$seqs_nuc{$1}{$2}\n" ; 
	    }
	    else {
		print "$group\t$1\t$2 NOT FOUND!\n" ; 
		$ismissing = 1 ;
		last  ; 
	    }
	}
    }
    close(OUT) ;
    close(OUTNUC) ; 

    next if $ismissing == 1 ; 


    #system("mafft $group.fa > $group.aln") ; 

    #system("mafft --maxiterate 1000 --localpair $group.fa > $group.aln") ; 

    system("mafft --quiet --maxiterate 1000  $group.fa > $group.aln") ;
    system("$pal2nalCommand $group.aln $group.nuc.fa -output fasta > $group.nuc.aln") ; 
    

    #system("muscle -in $group.fa -out $group.aln") ;
    #system("muscle -in $group.dna.fa -out $group.dna.aln") ;
 



    $count++ ;
    #last if $count == 10;
}
