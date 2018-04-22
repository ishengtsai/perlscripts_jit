#!/usr/bin/perl -w
use strict;



if (@ARGV != 1) {
	print "$0 gff \n\n" ;
	print "Example usage:\n $0  gff \n\n" ;

	exit ;
}

my $file = shift @ARGV;
my $fastafile = shift @ARGV ;
my $contig_name = '' ;



open OUT, ">", "$file.gene.location" or die "ooops\n" ; 
open INTERGENE, ">", "$file.intergenic" or die "sadidoiasida\n" ; 
#open BED, ">", "$file.bed" or die "ooops\n" ; 


open (IN, "$file") or die "oops!\n" ;

# gff

my $intron_start = '' ; 
my $count = 1; 



my %models = (); 
my %present = () ; 


# read in gff annotations
while (<IN>) {
	
    next if /rfamscan/ ; 
    next if /tRNA/ ; 
    next if /rRNA/ ; 
    next if /^\#/ ; 

    s/\#/\./gi ; 
	chomp ;
	my @r = split /\s+/, $_ ;

	#updated: for parsing the RATT event 
	$r[8] =~ s/\"//gi ; 

	

	
	if ( $r[2] eq 'gene' ) {

	    if ( $r[8] =~ /Name=(\S+)$/) {
		my $gene = $1 ;

		if ($gene =~ /(\S+)\;ances/) {
		    $gene = $1 ; 
		}

		if ( $models{"$r[0]"}{"$r[3]"} ) {
		    print "$r[0] $r[3] already a model\n" ; 
		}
		else {
		    if ( $present{$gene} ) {
			print "$gene already printed\n" ; 
		    }
		    else {
			$models{"$r[0]"}{"$r[3]"} = "$gene $r[3] $r[4]" ; 
			$present{$gene}++ ;
		    }
		}

	    }


	}
	    



	#last;
}
close(IN) ;




for my $scaff (sort keys %models ) {

    my $previous_coord = 0 ; 
    my $gene_in_scaff = 1 ; 

    for my $info ( sort { $a <=> $b } keys (%{ $models{$scaff} }) ) {
	
	my @r = split /\s+/, $models{$scaff}{$info} ; 

#print "$scaff\t@r\n" ; 
	my $countFormatted = sprintf("%05d", $count);

	$scaff =~ s/\#/\./gi ; 
	
	print OUT "$r[0]\t$scaff\t$info\t$scaff....$countFormatted\t$r[2]\t$gene_in_scaff\n" ;
	
	if ( $gene_in_scaff != 1 ) {
	    print INTERGENE "" . ( $info - $previous_coord - 1) . "\n" ; 

	}

	$count++ ;
	$gene_in_scaff++ ; 
	$previous_coord = $r[2] ; 
    }

    
    
}



print "all done!!! $file.gene.location and $file.intergenic produced\n" ;
