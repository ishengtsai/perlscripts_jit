#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV != 3) {
    print "$0 species.prefix blast.file hmmfile \n\n" ;
    exit ;
}

my $species = shift ; 
my $blastfile = shift ; 
my $hmmfile = shift ; 

my %id = () ; 
my %blastid = () ; 
my %hmm = () ; 

my $hmmheader = '#                                                               --- full sequence ---- --- best 1 domain ---- --- domain number estimation ----
# target name        accession  query name           accession    E-value  score  bias   E-value  score  bias   exp reg clu  ov env dom rep inc description of target
#------------------- ---------- -------------------- ---------- --------- ------ ----- --------- ------ -----   --- --- --- --- --- --- --- --- ---------------------' ;



    open (IN, "$blastfile") or die "oooops\n" ; 

    while (<IN>) {
	
	chomp; 
	my @r = split /\s+/, ; 

	my $name = $r[0] ; 
	#$name =~ s/$species//gi ; 

	$id{$name}++ ; 
	$blastid{$name} .= "$_\n" ; 

    }
    close(IN) ;
    close(OUT) ; 




open (IN, $hmmfile ) or die "oooops\n" ; 
while (<IN>) {

    next if /^\#/ ; 

    chomp ; 
    my @r = split /\s+/, $_ ; 

    my $name = $r[2] ;
    #$name =~ s/$species//gi ;


    $id{$name}++ ; 
    $hmm{$name} .= "$_\n" ; 


}
close(IN); 


mkdir "$species.forargot.input" ; 

my $count = 1 ;
my $numgenes = 0 ;  
my $genebin = 9999 ; 

for my $gene ( keys %id ) {

    if ( $numgenes == 0 ) {
	open OUT, ">", "$species.forargot.input/$count.blast" or die "ooops\n" ; 
	open OUT2, ">", "$species.forargot.input/$count.hmm" or die "ooops\n" ; 
    }

    if ( $blastid{$gene} ) {
	print OUT "$blastid{$gene}" ; 
    }
    if ( $hmm{$gene} ) {
	print OUT2 "$hmm{$gene}" ; 
    }


    $numgenes++ ; 

    if ( $numgenes == $genebin ) {
	system("zip -r $species.forargot.input/$count.blast.zip $species.forargot.input/$count.blast") ; 
	system("zip -r $species.forargot.input/$count.hmm.zip $species.forargot.input/$count.hmm") ; 

	$count++ ; 
	$numgenes = 0 ; 


	close(OUT) ; 
	close(OUT2) ; 
    }

    #last if $count == 2 ; 
}

system("zip -r $species.forargot.input/$count.blast.zip $species.forargot.input/$count.blast") ;
system("zip -r $species.forargot.input/$count.hmm.zip $species.forargot.input/$count.hmm") ;


print "all done!\n" ; 
