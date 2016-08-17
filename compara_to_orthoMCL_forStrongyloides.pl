#!/usr/bin/perl -w
use strict;



if (@ARGV != 1) {
    print "$0 comparafile\n" ; 
    print "compara -> orthomcl\n" ; 

	exit ;
}

my $comparafile = shift @ARGV;


my %location = () ; 

my %species = (
    "parastrongyloides_trichosuri" => "PTRK", 
    "rhabditophanes_kr3021" => "RSKR",
    "caenorhabditis_elegans" => "CEL",
    "haemonchus_contortus" => "HCOI", 
    "strongyloides_stercoralis" => "SSTP",
    "brugia_malayi" => "BMA", 
    "meloidogyne_hapla" => "MHA", 
    "panagrellus_redivivus" => "PANA",
    "strongyloides_ratti" => "SRAE",
    "strongyloides_papillosus" => "SPAL",
    "strongyloides_venezuelensis" => "SVE",
    "bursaphelenchus_xylophilus" => "BXY" ,
    "trichinella_spiralis" => "TSP" ,
    "necator_americanus" => "NAME" ,
    "trichuris_muris" => "TMUE" ,
    "ascaris_suum" => "ASUUM" 
) ; 


open (IN, "$comparafile") or die "oops\n"; 
while (<IN>) {
    next if /^----/ ; 

    chomp; 
    s/\(//gi ; 
    s/\)//gi ; 

    s/\.t\d+:mRNA//gi ; 
    s/:mRNA//gi ; 

    my @r = split /\s+/, $_ ; 

    print "ORTHOMCL$r[1]:" ; 
    
    
    for (my $i = 3 ; $i < @r ; $i += 2 ) {

	#check flag here
	unless ( $species{$r[$i+1]} ) {
	    print "no species for $r[$i+1]!\n" ; 
	    exit ;
	}


	my $isspecies = $species{$r[$i+1]} ;

	if ( $isspecies eq 'SRAE' ) {
	    #$r[$i] .= '.1' ; 
	}
	unless ( $isspecies eq 'CEL' ) {
	    #$r[$i] =~ s/\.\d+$/\.1/ ; 
        }

	print " $isspecies\|$r[$i]" ; 


    }
    print "\n" ; 


}
close(IN) ; 


