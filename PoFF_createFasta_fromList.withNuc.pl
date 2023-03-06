#!/usr/bin/perl -w
use strict;


my $PI = `echo $$` ; chomp($PI); 


if (@ARGV != 4) {
    print "$0 PoFF.proteinortho_single.copy.tsv  aa.merged.fasta nuc.merged.fasta /home/ijt/bin/pal2nal.v14/pal2nal.pl \n" ; 
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
     s/\:/_/gi ;

    if (/^>(.+)\_(.+)$/) {
	$read_name = $1 ;
	$read_seq = "" ;
	$species = $2 ;  
	
	while (<IN>) {
	    $read_seq =~ s/\*//g ;
	    s/\:/_/gi ;
	    
	    if (/^>(.+)\_(.+)$/) {
		#print "$read_name\n" ; 
		
		
		$seqs{$species}{$read_name} = $read_seq ;
		
		
		$read_name = $1 ;
		$species = $2  ;
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

print "$fasta_file1 file read!\n" ; 

open (IN, $fasta_file2) or die "can't open $fasta_file2!\n" ;

$species = '' ;
$read_name = '' ;
$read_seq = '' ;
while (<IN>) {
     s/\:/_/gi ;
    
    if (/^>(.+)\_(.+)$/) {
	$read_name = $1 ;
	$read_seq = "" ;
	$species = $2 ;

	while (<IN>) {
	    $read_seq =~ s/\*//g ;
	     s/\:/_/gi ;
	    
	    if (/^>(.+)\_(.+)$/) {


		$seqs_nuc{$species}{$read_name} = $read_seq ;


		$read_name = $1 ;
		$species = $2 ;
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


print "$fasta_file2 file read!\n" ;





mkdir "fastas.$PI" or die "ooops\n" ; 
chdir "fastas.$PI" ; 



open (IN, "../$file") or die "oops! erm \n" ;

my $count = 1 ;

## read in the PoFF file


while (<IN>) {

    chomp ; 
#    print "$_\n" ;

    next if /^\#/ ; 
    
    my @r = split /\s+/, $_ ;

    my $group = $count ;

    


    open OUT, ">", "$group.aa.fa" or die "ooops\n" ;
    open OUTNUC, ">", "$group.nuc.fa" or die "daosdpadoaopd\n" ; 


    print "doing $group\n" ; 
    my $ismissing = 0 ; 

    # check if it's missing
    for (my $i = 3 ; $i < @r ; $i++ ) {

	#print "$r[$i]\n" ;

	if ( $r[$i] =~ /(^.+)\_(.+)$/ ) {

	    print "$1 $2\n" ;
	    if ( $seqs{$2}{$1} && $seqs_nuc{$2}{$1} ) {
	    }
	    else {
		print "$group\t$2\t$1 NOT FOUND!\n" ; 
		$ismissing = 1 ;
		last  ; 
	    }
	}
    }
    last if $ismissing == 1 ; 


    for (my $i = 3 ; $i < @r ; $i++ ) {

        #print "$r[$i]\n" ;

        if ( $r[$i] =~ /(^.+)\_(.+)$/ ) {

            #print "$1 $2\n" ;
            if ( $seqs{$2}{$1} && $seqs_nuc{$2}{$1} ) {
		print "$1\t$2\n" ; 
                print OUT ">$2\n$seqs{$2}{$1}\n" ;
                print OUTNUC ">$2\n$seqs_nuc{$2}{$1}\n" ;
            }

        }
    }
    close(OUT) ;
    close(OUTNUC) ;

    

    #system("mafft $group.fa > $group.aln") ; 

    #system("mafft --maxiterate 1000 --localpair $group.fa > $group.aln") ; 

    system("mafft --quiet --maxiterate 1000  $group.aa.fa > $group.aa.aln") ;
    system("$pal2nalCommand $group.aa.aln $group.nuc.fa -output fasta > $group.nuc.aln") ; 
    

    #system("muscle -in $group.fa -out $group.aln") ;
    #system("muscle -in $group.dna.fa -out $group.dna.aln") ;
 



    $count++ ;
    #last if $count == 2;
}
