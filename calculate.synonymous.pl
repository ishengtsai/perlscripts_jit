#!/usr/bin/perl -w
use strict;





if (@ARGV != 4) {
    print "$0 nuc.fa prot.fa window startingpos\n" ; 
	exit ;
}

my $nucfile = $ARGV[0];
my $aafile = $ARGV[1];
my $windowsize = $ARGV[2] ; 
my $startingpos = $ARGV[3] ; 

my @genename = () ; 

open (IN, "$nucfile") or die "oops!\n" ;

my %nuc = () ;
my %aa = ()  ;

my $read_name = '' ;
my $read_seq = '' ;


while (<IN>) {
            if (/^>(\S+)/) {

                $read_name = $1 ;
		push (@genename, $read_name) ; 
                $read_seq = "" ;

                while (<IN>) {

                    if (/^>(\S+)/) {
			
                        $nuc{$read_name} = $read_seq ;
                        $read_name = $1 ;
			push (@genename, $read_name) ;
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
$nuc{$read_name} = $read_seq ;


# aa sequences
open (IN, "$aafile") or die "oops!\n" ;
$read_name = '' ;
$read_seq = '' ;

while (<IN>) {
            if (/^>(\S+)/) {
		$read_name = $1 ;
		$read_seq = "" ;
		
		while (<IN>) {
		    
                    if (/^>(\S+)/) {
			
                        $aa{$read_name} = $read_seq ;
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
close(IN) ;
$aa{$read_name} = $read_seq ;


my %varloc = () ; 

#1 - second last
for (my $i = 0 ; $i < $#genename ; $i++ ) {

    # 2 - last 
    for (my $k = $i+ 1 ; $k < @genename ; $k++ ) {

	my $aaseq1 = $aa{$genename[$i]} ; 
	my $aaseq2 = $aa{$genename[$k]} ;
	my $nucseq1 = $nuc{$genename[$i]} ;
	my $nucseq2 = $nuc{$genename[$k]} ;
		
	my @aa1 = split //, $aaseq1 ; 
	my @aa2 = split //, $aaseq2 ; 
	my @nuc1 = $nucseq1 =~ /(.{1,3})/g;
	my @nuc2 = $nucseq2 =~ /(.{1,3})/g;
	
	#position 
	for (my $j = 0 ; $j < @aa1 ; $j++ ) {
	    
	    if ( $aa1[$j] eq $aa2[$j] && $nuc1[$j] ne $nuc2[$j] ) {
		my $difference = nucdiff($nuc1[$j],$nuc2[$j]) ; 
		my $fold = codon2fold($nuc1[$j]) ; 
		my $rounded = sprintf("%.3f", $difference/$fold) ;
		my $abspos = $j ; 
		#print "$j\t$i\t$k\t$aa1[$j]\t$aa2[$j]\t$nuc1[$j]\t$nuc2[$j]\t$difference\t$fold\t$rounded\n" ; 

		$varloc{$abspos} += "$rounded" ;


		
	    }
	    else {
		my $abspos = $j ;
		$varloc{$abspos} += "0";
	    }
	    
	}
	
    }

}


my @posdiff = () ; 

for (my $j = 0 ; $j < scalar keys %varloc ; $j++ ) {

    my $speciesnum = scalar @genename ; 
    #print "$j\t$varloc{$j}\t$speciesnum\n" ; 
    my $rounded = sprintf("%.3f", $varloc{$j}/$speciesnum) ;

    push(@posdiff, $rounded) ; 

} 

for (my $i = 0 ; $i < scalar keys %varloc ; $i += $windowsize ) {

    my $left = $i ; 
    my $right = $i + $windowsize ; 
    $right = scalar keys %varloc if $right >= scalar keys %varloc ; 

    my $sum = 0 ; 
    my $win = 0 ; 
    for (my $j = $left ; $j < $right ; $j++ ) {
	$sum += $posdiff[$j] ; 
	$win++ ; 
    }
    my $mid = ($right-1-$left)/2+$left ; 

    my $rounded = sprintf("%.3f",$sum/$win) ; 

    my $absstart = $startingpos - 1 ; 

    #print "" . ($left+1). "\t$right\t". ($left+1+$absstart)*3  ."\t". ($right+$absstart)*3 ."\t" . (($absstart+$mid)*3-1) . "\t$sum\t$win\n" ; 

    print "" . ($left+1+$absstart)*3  ."\t". ($right+$absstart)*3 ."\t" . ($absstart+($mid*3-1)) . "\t$rounded\n" ;
    

}











sub nucdiff {
    my @seq1 = split //, $_[0] ; 
    my @seq2 = split //, $_[1] ; 
    my $diff ; 

    for (my $i = 0 ; $i < @seq1 ; $i++ ) {
	$diff++ if $seq1[$i] ne $seq2[$i] ; 
    }

    return $diff ; 
}



sub codon2fold {
    my($codon) = @_;
    $codon = uc $codon;

    my(%genetic_code) = (

    'TCA' => '0.8333',    # Serine
    'TCC' => '0.8333',    # Serine
    'TCG' => '0.8333',    # Serine
    'TCT' => '0.8333',    # Serine
    'TTC' => '0.5',    # Phenylalanine
    'TTT' => '0.5',    # Phenylalanine
    'TTA' => '0.8333',    # Leucine
    'TTG' => '0.8333',    # Leucine
    'TAC' => '0.5',    # Tyrosine
    'TAT' => '0.5',    # Tyrosine
    'TAA' => '0.6666',    # Stop
    'TAG' => '0.6666',    # Stop
    'TGC' => '0.5',    # Cysteine
    'TGT' => '0.5',    # Cysteine
    'TGA' => '0.6666',    # Stop
    'TGG' => 'wierd',    # Tryptophan
    'CTA' => '0.8333',    # Leucine
    'CTC' => '0.8333',    # Leucine
    'CTG' => '0.8333',    # Leucine
    'CTT' => '0.8333',    # Leucine
    'CCA' => '0.75',    # Proline
    'CCC' => '0.75',    # Proline
    'CCG' => '0.75',    # Proline
    'CCT' => '0.75',    # Proline
    'CAC' => '0.5',    # Histidine
    'CAT' => '0.5',    # Histidine
    'CAA' => '0.5',    # Glutamine
    'CAG' => '0.5',    # Glutamine
    'CGA' => '0.8333',    # Arginine
    'CGC' => '0.8333',    # Arginine
    'CGG' => '0.8333',    # Arginine
    'CGT' => '0.8333',    # Arginine
    'ATA' => '0.6666',    # Isoleucine
    'ATC' => '0.6666',    # Isoleucine
    'ATT' => '0.6666',    # Isoleucine
    'ATG' => 'wierd',    # Methionine (Start)
    'ACA' => '0.75',    # Threonine
    'ACC' => '0.75',    # Threonine
    'ACG' => '0.75',    # Threonine
    'ACT' => '0.75',    # Threonine
    'AAC' => '0.5',    # Asparagine
    'AAT' => '0.5',    # Asparagine
    'AAA' => '0.5',    # Lysine
    'AAG' => '0.5',    # Lysine
    'AGC' => '0.8333',    # Serine
    'AGT' => '0.8333',    # Serine
    'AGA' => '0.8333',    # Arginine
    'AGG' => '0.8333',    # Arginine
    'GTA' => '0.75',    # Valine
    'GTC' => '0.75',    # Valine
    'GTG' => '0.75',    # Valine
    'GTT' => '0.75',    # Valine
    'GCA' => '0.75',    # Alanine
    'GCC' => '0.75',    # Alanine
    'GCG' => '0.75',    # Alanine
    'GCT' => '0.75',    # Alanine
    'GAC' => '0.5',    # Aspartic Acid
    'GAT' => '0.5',    # Aspartic Acid
    'GAA' => '0.5',    # Glutamic Acid
    'GAG' => '0.5',    # Glutamic Acid
    'GGA' => '0.75',    # Glycine
    'GGC' => '0.75',    # Glycine
    'GGG' => '0.75',    # Glycine
    'GGT' => '0.75',    # Glycine
        );

    if(exists $genetic_code{$codon}) {
        return $genetic_code{$codon};
    }else{

#        print STDERR "Bad codon \"$codon\"!!\n";
        return 'X' ;
        #exit ;
    }
}
