#!/usr/bin/perl -w
use strict;



if (@ARGV != 4) {
	print "$0 groups.txt xxx.fa outgroup ingroup\n\n" ;


	exit ;
}


my $file = $ARGV[0];
my $fasta = $ARGV[1] ; 

my @outgroup_tmp = split /\s+/, $ARGV[2] ; 
my %outgroup = () ;  
foreach ( @outgroup_tmp ) {
    print "outgroup is : $_\n" ; 
    $outgroup{$_}++ ; 
}

my @ingroup_tmp = split /\s+/, $ARGV[3] ;
my %ingroup = () ;
foreach ( @ingroup_tmp ) {
    print "ingroup is : $_\n" ;
    $ingroup{$_}++ ;
}




my %seqs  = () ;


# read the fastas!
print "fasta file to be read: $fasta\n\n\n" ;
open (IN, $fasta) or die "ooops\n" ; 

my $species = '' ; 
my $read_name = '' ;
my $read_seq = '' ;

if ( $fasta =~ /(\S+)\./) {
    $species = $1; 
}



while (<IN>) {
            if (/^>(\S+)\|(\S+)/) {
                $read_name = $2 ;
                $read_seq = "" ;

                while (<IN>) {

                        if (/^>(\S+)\|(\S+)/) {

                            $seqs{$species}{$read_name} = $read_seq ;

                            $read_name = $2 ;
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


open DESC, ">", "$fasta.clusterdescription" or die "ooops\n" ;
open DESC_CLUS , ">" , "$fasta.clusterItselfOnly" or die "ooops\n" ; 

#open IN_DESC, ">", "$file.ingroup.description" or die "ooops\n" ; 
open IN_CLUS, ">", "$file.ingroup.with$species.cluster" or die "oooops\n" ; 

open UNIQUE_CLUS, ">", "$fasta.uniqueInSpecies_singlecopy" or die "ooops\n" ; 
open UNIQUE_LIST, ">", "$fasta.uniqueInSpecies.list" or die "ooops\n" ; 


open SUMMARY , ">", "$file.summary" or die "ooops\n" ; 


print "$file.summary will be produced for general purposes\n" ;


open EXCEL, ">", "$file.OrthoMCL.forExcel.txt" or die "ooops\n" ;
print "$file.OrthoMCL.forExcel.txt will be printed for excel purposes\n" ;

open DOLLOP, ">", "$file.OrthoMCL.forDOLLOP.tmp.txt" or die "oooops\n" ; 
print "$file.OrthoMCL.forDOLLOP.tmp.txt will be printed for excel purposes\n" ;



#headers
print SUMMARY "Cluster\t" ;


print EXCEL "Cluster\tOrtholog_count\t" ;
 
for (sort keys %outgroup) {
    print SUMMARY "$_\t" ; 
    print EXCEL "$_\t" ;

}
for (sort keys %ingroup) {
    print SUMMARY "$_\t" ;
    print EXCEL "$_\t" ;

}
print SUMMARY "\n" ;
print EXCEL "\n" ; 




my $count = 0 ;
my %cluster_size = () ;

my %shared_gene = () ;

my $self_cluster = 0 ; 
my $self_cluster_genes = 0 ; 

my $total_gene_number_into_family = 0 ; 

my %dollop_size = () ; 

my $clusterWithAtLeastOneIn = 0 ; 
my $clusterWithAtLeastOneInAndOut = 0;

open (IN, $file) or die "ooops\n" ;
while (<IN>) {

    chomp ; 
    #print "$_\n" ;

    my @r = split /\s+/, $_ ;

    my $group = '' ;

    if ($r[0] =~ /(ORTHO\S+)/) {
	$group = $1 ;
    }


    #parsing 
    my $cluster_name = '' ; 
    if ($r[0] =~ /(ORTHOMCL\d+)/) {
	$cluster_name = $1 ; 
    }


    my $size = @r -1 ;
    $total_gene_number_into_family += $size ; 

    #Print "$r[0]\t $r[1]\n" ;


    # put clusters info into hash
    my %cluster = () ;
    my %speciesincluster = () ;
    my $targetspecies = 0 ; 
    for ( my $i = 1 ; $i < @r ; $i++ ) {
	if ( $r[$i] =~ /(\S+)\|(\S+)/ ) {
	    $cluster{$1}++ ;
	    $speciesincluster{$1}++ ; 
	}
	if ( $r[$i] =~ /$species\|(\S+)/ ) {
	    $shared_gene{$1}++ ; 
	    $targetspecies = 1; 
	}
    }

    my $numspecies = scalar keys %speciesincluster ; 
 
    if ( $targetspecies == 1 && $numspecies  == 1 ) {
	#print "found $species only!\n" ; 
	#print "$_\n" ; 

	print DESC "$species\t$cluster_name\t$size\tITSELFONLY\n" ; 
	print DESC_CLUS "$_\n" ; 

	for ( my $i = 1 ; $i < @r ; $i++ ) {

	    if ( $r[$i] =~ /$species\|(\S+)/ ) {
		print UNIQUE_LIST "$1\n" ; 
	    }
	}
	
	$self_cluster++ ; 
	$self_cluster_genes += $size ; 

    }
    elsif ( $_ =~ /$species/) {

	# output the cluster
	my $outgroup_present = 0 ; 
	my $ingroup_present = 0 ; 

	for my $organism (sort keys %cluster) {
	    $outgroup_present = 1 if exists $outgroup{$organism} ; 
	    $ingroup_present = 1 if exists $ingroup{$organism} ; 
	    #print "$_:$cluster{$_}\t" ; 	    
	}
	#print "\n" ; 

	# print for specific specieis
	if ( $outgroup_present == 1 ) {
	    print DESC "$species\t$cluster_name\t$cluster{$species}\tWITHOUTGRUP\n" ; 
	}
	elsif ( $ingroup_present == 1 )  {
	    print DESC "$species\t$cluster_name\t$cluster{$species}\tGROUPONLY\n" ;
	    #print IN_CLUS "$_\n" ; 

	    for ( my $i = 1 ; $i < @r ; $i++ ) {

		if ( $r[$i] =~ /$species\|(\S+)/ ) {
		    print IN_CLUS "$1\n" ;
		}
	    }

	}

	if ( $outgroup_present == 1 && $ingroup_present == 1 ) {
	    $clusterWithAtLeastOneInAndOut++;
	}
	elsif ( $ingroup_present == 1 ) {
	    $clusterWithAtLeastOneIn++ ; 
	}


    }

    # print out cluster size, each column is one species
    # also for Excel file...
    print SUMMARY "$cluster_name\t" ; 
    print EXCEL "$cluster_name\t$size\t" ;

    # If emu gene is present and at least 2 other families are present                                                                                                                                                                                                   
    # put this as an output                                                                                                                                                                                                                                        




    for (sort keys %outgroup) {
	if ( $cluster{$_} ) {
	    print SUMMARY "$cluster{$_}\t" ; 
	    print EXCEL "$cluster{$_}\t" ;
            $dollop_size{$_} .= "1" ;

	}
	else {
	    print SUMMARY "0\t" ; 
	    print EXCEL "0\t" ;
            $dollop_size{$_} .= "0" ;

	}
    }
    for (sort keys %ingroup) {
        if ( $cluster{$_} ) {
            print SUMMARY "$cluster{$_}\t" ;
	    print EXCEL "$cluster{$_}\t" ;
	    $dollop_size{$_} .= "1" ; 


        }
        else {
            print SUMMARY "0\t" ;
            print EXCEL "0\t" ;
	    $dollop_size{$_} .= "0" ; 


        }
    }
    print SUMMARY "\n" ; 


    #system("muscle -in $group.fa -out $group.aln") ;
    #system("muscle -in $group.dna.fa -out $group.dna.aln") ;
 
    print EXCEL "\n" ; 


    $count++ ;
    #last if $count == 10;
}




# now we check for species unique genes
my $unique_genes = 0 ;

for my $gene (sort keys  % { $seqs{$species} } ) {

    if ( $shared_gene{$gene} ) {

    }
    else {
	#print "$gene not found in orthomcl!\n" ; 
	$unique_genes++ ; 

	print UNIQUE_CLUS "UNIQUE$unique_genes\(1 genes,1 taxa):\t$gene($species)\n" ; 
        print DESC "$species\tUNIQUE\t1\tITSELFONLY\n" ;

	print UNIQUE_LIST "$gene\n" ; 

    }
}


# print out file for dollop
my $species_size = scalar keys %dollop_size ; 
print DOLLOP "$species_size $count\n" ; 
for (sort keys %dollop_size) {
    print DOLLOP "$_       " ; 
    print DOLLOP "$dollop_size{$_}\n" ;
    print "" . length($dollop_size{$_}) . "\n" ; 
}


system("fasta2phylip.pl $file.OrthoMCL.forDOLLOP.tmp.txt $file.OrthoMCL.forDOLLOP.phylip") ; 

print "total clusters: $count\n" ; 
print "a total of $unique_genes unique SINGLE COPY genes not found hit with other species in $species\n" ; 
print "a total of $self_cluster_genes unique gene families in $self_cluster clusters\n\n" ; 
print "a total of $total_gene_number_into_family proteins characterised into gene families\n" ; 


print "Number of incluster also with outcluster: $clusterWithAtLeastOneInAndOut\n" ; 
print "Number of incluster only: $clusterWithAtLeastOneIn\n" ; 





print "all done!!!\n" ; 
