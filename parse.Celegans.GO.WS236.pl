#!/usr/bin/perl -w
use strict;



if (@ARGV != 2) {
    print "$0 go.raw.file c_elegans.WS236.functional_descriptions.txt\n" ; 

	exit ;
}

my $file = shift @ARGV;
my $file2 = shift @ARGV;



open OUT, ">", "Cel.GO" or die "ooops\n" ; 
open OUTWB, ">", "Cel.GO.fortopGO.WBGeneID" or die "ooops\n" ; 
open OUTID, ">","Cel.GO.fortopGO.GeneID" or die "ooops\n" ;
 

my %gene = () ;
open (IN, "$file2") or die "ooooops\n" ;
while (<IN>) {

    if ( /(^WB\S+)\s+(\S+)\s+(\S+)/ ) {
	$gene{$1} = "$3" ; 
    }
}
close(IN); 


open (IN, "$file") or die "ooooops\n" ; 


my $count = 1 ; 

my %GO = () ; 
my %GOnr = () ; 


my %evidence = () ; 

while (<IN>) {
    
	chomp ;
	my @r = split /\s+/, $_ ;

#!DataBase_Project_Name: WormBase WS232/WS233
#WB      WBGene00000001  aap-1           GO:0005942      PMID:12520011|PMID:12654719     IEA     INTERPRO:IPR001720      C               Y110A7A.10      gene    taxon:6239      20120528        WB              
#WB      WBGene00000001  aap-1           GO:0035014      PMID:12520011|PMID:12654719     IEA     INTERPRO:IPR001720      F               Y110A7A.10      gene    taxon:6239      20120528        WB              

	#print "$r[0]\t$r[3]\t$r[5]\n" ; 

	if ( /^!/ ) {
	    next ;
	}
	if ( $r[0] ne 'WB' )  {
	    next ; 
	}

	unless ( $r[5] ) {
	    next ; 
	}

	if ( $r[5] =~ /^\S\S\S$/ ) {

	}
	elsif ( $r[5] eq 'IC' || $r[5] eq 'ND' ) {

	}
	else {
	    next ; 
	}

	#print "$r[0]\t$r[3]\t$r[5]\n" ;



	
	if ( $GO{$r[1]}{"$r[3].$r[5]"} ) {

	}
	else {
	    $GO{$r[1]}{"$r[3].$r[5]"}++ ;
	    $evidence{$r[5]}++ ;
	    
	    #$gene{$r[1]} = "$r[8]" ;
	    $GOnr{$r[1]}{$r[3]}++ ; 
	}
	
	

}

for my $code ( keys %evidence ) {
    print "$code\t$evidence{$code}\n" ; 

}




for my $gene (sort keys %GO ) {
    print OUT "$gene\t" ; 

    for my $goid (sort keys %{ $GO{$gene} } ) {
	print OUT "$goid " ; 
    }

    print OUT "\n" ; 

}


for my $gene (sort keys %GOnr ) {


    if ( $gene{$gene} eq 'not' ) {
	print "$gene wierd!\n" ; 
	next ; 
    }

    print OUTID "$gene{$gene} " ;
    print OUTWB "$gene " ;

    my $presence = 0 ;
    for my $goid (sort keys %{ $GOnr{$gene} } ) {

	


	if ( $presence ) {
	    print OUTID ",$goid" ;
	    print OUTWB ",$goid" ;
	}
	else {
	    print OUTID "$goid" ;
            print OUTWB "$goid" ;
	    $presence++ ; 
	}
    }

    print OUTID "\n" ;
    print OUTWB "\n" ;
}


close(IN) ;
close(OUT) ; 

print "all done! Cel.GO Cel.GO.fortopGO.GeneID Cel.GO.fortopGO.WBGeneID  produced\n" ; 
