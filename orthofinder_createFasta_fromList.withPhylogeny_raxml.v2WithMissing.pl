#!/usr/bin/perl -w
use strict;


my $PI = `echo $$` ; chomp($PI); 


if (@ARGV != 2) {
    print "$0 Orthogroups.txt.singletonCluster  merged.fasta \n" ; 
    print "note! stop codons have been excluded\n" ; 
	exit ;
}

my $file = shift @ARGV;
my @fasta_files = split /\s+/, shift @ARGV ;


my %seqs  = () ;



foreach my $file (@fasta_files) {
    print "fasta file to be read: $file\n" ;

    open (IN, $file) or die "can't open $file!\n" ; 

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

 
}


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

    my $ismissing = 0 ;
    my %speciesIncluded = () ; 

    for (my $i = 1 ; $i < @r ; $i++ ) {

	#print "$r[$i]\n" ;

	if ( $r[$i] =~ /(^\S+)\|(\S+)/ ) {

	    my $species = $1 ;
	    my $gene = $2 ; 

	    if ( $speciesIncluded{$species} ) {
		print "$group $species already included! skip...\n" ;
		next ; 

	    }
	    else {
		$speciesIncluded{$species}++ ; 
		
		#print "$1 $2\n" ;
		if ( $seqs{$species}{$gene} ) {
		    print OUT ">$species\n$seqs{$species}{$gene}\n" ;
		}
		else {
		    print "$group\t$species\t$gene NOT FOUND!\n" ; 
		    $ismissing = 1 ;
		    last  ; 
	    }

	    }
	}
    }
    close(OUT) ;

    next if $ismissing == 1 ; 


    #system("mafft $group.fa > $group.aln") ; 

    #system("mafft --maxiterate 1000 --localpair $group.fa > $group.aln") ; 
    system("mafft --maxiterate 1000  $group.fa > $group.aln") ;


    # Make phylogeny
    #my $command = "$raxmlbin --all --msa $group.aln --model LG+G8+F --threads 1 "  . '--tree pars{10} --bs-trees 200 ' ; 
    my $command = "/home/ijt/bin/standard-RAxML-8.2.11/raxmlHPC-PTHREADS-AVX -T 60  -s $group.aln   -n $group.boot -m PROTGAMMAILGF  -p 12345 -f a  -x 1234 -N 200" ; 
    system("$command") ; 
    

    #system("muscle -in $group.fa -out $group.aln") ;
    #system("muscle -in $group.dna.fa -out $group.dna.aln") ;
 



    $count++ ;
    #last if $count == 3;
}
