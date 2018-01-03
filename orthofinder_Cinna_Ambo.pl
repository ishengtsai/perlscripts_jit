#!/usr/bin/perl -w
use strict;

# Note: Last update with Dang's orthofinder and quick modifition!
# Need careful look!!


if (@ARGV != 5) {
	print "$0 contig.len.txt groups.txt gene_location Species1 Species2 \n\n" ;
	print "create partitioned list\n" ; 

	exit ;
}


my $contiglenfile = shift @ARGV;

my $file = shift @ARGV;
my $location_file = shift @ARGV ;

my $spe1 =  shift @ARGV ;
my $spe2 = shift @ARGV ; 


my %location = () ; 
my %scaffold = () ; 

my %orthoIDtoGene = () ; 

my %scaffold_gene_count = () ; 
my %contig_len = () ; 

open (IN, "$contiglenfile") or die "daoidoadoiad\n" ; 
while (<IN>) {
    if ( /(\S+)\s+(\S+)/ ) {
        #print "$1\t$2\n" ;
        $contig_len{$1} = $2 ;
    }

}
close(IN) ; 



open (IN, "$location_file") or die "oops!\n" ;
while (<IN>) {
    chomp ; 
    if ( /(\S+)\t(\S+)\t(\S+)/ ) {
	$location{$1} = "$2\t$3" ;
	$scaffold{$1} = "$2" ; 
	$scaffold_gene_count{$2}++ ; 
    }

}
close(IN) ; 





open (IN, "$file") or die "oops!\n" ;

open OUT, ">", "$file.$spe1.$spe2.locationcomparison" or die "can't open files erm!!!!!!\n" ; 


open OUT_ERR, ">", "$file.$spe1.$spe2.locationcomparison.err" or die "can't open file for input!\n" ; 

open OUT4, ">", "$file.$spe1.$spe2.locationcomparison.perscaffTable.txt" or die "ooooca can't create file!\n" ; 

my $count = 0 ;
my %cluster_size = () ;

my %shared_gene = () ;
my %shared_gene_in_scaffold = () ; 
my $gene_pairs = 0 ; 






my %genes_in_cel_chrom = () ; 



while (<IN>) {

    chomp ; 
    #print "$_\n" ;

    my @r = split /\s+/, $_ ;

    my $group = '' ;

    if ($r[0] =~ /^(\d+):/) {
	$group = $1 ;
    }




    #print "$r[0]\t$r[1]\n" ;

    my %gene_count = () ; 
    my %genes = () ; 

    for (my $i = 1; $i < @r ; $i++) {

	if ( $r[$i] =~ /(\S+)\|(\S+)/ ) {
	

	    if ( $gene_count{$1}  ) {
		$genes{$1} .= "\t$2"  ; 
	    }
	    else {
		$genes{$1} = "$2"  ;
	    }
	    #print "$1\t$2\n" ; 

	    $gene_count{$1}++ ;

	}       
    }
    
    

    #last; 

    if ( $gene_count{$spe1} && $gene_count{$spe2} ) {
	#print "$gene_count{$spe1}\t$gene_count{$spe2}\t$genes{$spe1}\t.\t$genes{$spe2}\n" ;


    }
    
    if ( $gene_count{$spe1} && $gene_count{$spe2} ) {

	if ( $gene_count{$spe1} == 1 && $gene_count{$spe2} == 1) {
	    
	    
	    my $gene1 =  $genes{$spe1}  ; 
	    my $gene2 =  $genes{$spe2}  ; 

	    


	    if ( $location{$gene1} && $location{$gene2}) {

		#print "$gene1\t$location{$gene1}\t$gene2\t$location{$gene2}\n" ;
		print OUT "$gene1\t$location{$gene1}\t$gene2\t$location{$gene2}\n" ; 
		
		my $location1 = $scaffold{$gene1} ; 


		my $locationCEL = '' ; 
		#print "$scaffold{$gene2}\n" ; 

		#if ( $assigned_scaffold { $scaffold{$gene2} } ) {
		#    $locationCEL = $assigned_scaffold { $scaffold{$gene2} } ; 

		#}
		#else {
		    $locationCEL = $scaffold{$gene2} ; 
		#}


		$genes_in_cel_chrom{$location1}{$locationCEL}++ ; 



		$gene_pairs++ ; 

		$shared_gene{$gene1}++ ; 
		$shared_gene{$gene2}++ ;

		$shared_gene_in_scaffold{ $scaffold{$gene1} }++ ; 
		$shared_gene_in_scaffold{ $scaffold{$gene2} }++;
		



	    }
	    else {

		unless ( $location{$gene1} ) {
		    print OUT_ERR "$gene1 location wierd!!!\n" ; 
		}

		unless ( $location{$gene2} ) {
                    print OUT_ERR "$gene2 location wierd!!!\n" ;
		}

	    }


	}

	
    }
    elsif ( $gene_count{$spe1} || $gene_count{$spe2} ) {


    }



 



    $count++ ;
    #last if $count == 10;
}



#my @celscaffolds = qw / GL622787 GL622785 GL622792 GL622789 GL622788 GL622784 GL624340 GL622791 GL622790 GL623393 GL623868 GL624139 GL622786 GL624942 / ; 
#my @celscaffolds = qw / 1 2 3 / ; 

#my @celscaffolds = qw / Unknown ChLG3 ChLG9 ChLG7 ChLG2 ChLG5 ChLG8 ChLG4 ChLG6 ChLG10 ChLGX / ; 

my @celscaffolds = qw / CKAN.scaff0001 CKAN.scaff0002 CKAN.scaff0003 CKAN.scaff0004 CKAN.scaff0005 CKAN.scaff0006 CKAN.scaff0007 CKAN.scaff0008 CKAN.scaff0009 CKAN.scaff0010 CKAN.scaff0011 CKAN.scaff0012 / ; 

#header
print OUT4 "scaff\tcontig_len\tgenes_in_scaff\tshared_one_one" ; 
foreach (@celscaffolds) {
    print OUT4 "\t$_" ; 
}
print OUT4 "\n" ; 

for my $scaff (sort keys %scaffold_gene_count) {

    print OUT4 "$scaff\t$contig_len{$scaff}\t$scaffold_gene_count{$scaff}\t" ; 





    if ( $shared_gene_in_scaffold{$scaff} ) {
	print OUT4 "$shared_gene_in_scaffold{$scaff}\t" ; 


	# insert things here
	foreach my $celscaffold ( @celscaffolds ) {

	    if ( $genes_in_cel_chrom{$scaff}{"$celscaffold"} ) {
		my $num = $genes_in_cel_chrom{$scaff}{"$celscaffold"} ; 
		print OUT4 "$num\t" ; 
	    }
	    else {
		print OUT4 "0\t" ; 
	    }
	}

    }
    else {
	print OUT4 "0" . ( "\t0" x @celscaffolds ) . "" ; 
    }

    print OUT4 "\n" ; 

}


print "all done! $gene_pairs single gene pairs output!\n" ; 
