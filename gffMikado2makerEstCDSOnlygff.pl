#!/usr/bin/perl -w
use strict;



if (@ARGV != 4) {
    print "$0 mikado.loci.metrics.tsv mikado.loci.gff3 cds_lengthFilter cds_fraction \n" ; 

	exit ;
}

my $metricfile = shift @ARGV ; 
my $file = shift @ARGV;

my $cdslen = shift @ARGV;
my $cdsfraction = shift @ARGV ; 

my %included_trans = () ; 
my %included_trans_score = () ; 

open (IN, "$metricfile") or die "oops!\n" ;
while (<IN>) {

    next if /^tid/ ; 
    chomp;
    my @r = split /\s+/, $_ ;

    #print "$r[10]\t$r[13]\n" ; 
    
    if ( $r[10] >= $cdslen && $r[13] > $cdsfraction ) {
	#print "$r[0]\t$r[9]\t$r[12]\n" ;
	$included_trans{$r[0]}++ ;
	#score set as cdslen x 3 
	$included_trans_score{$r[0]} = $r[10] * 3 ; 
    }


}
close(IN) ; 


my %hspCount = () ; 

## read the fastas
open (IN, "$file") or die "oops!\n" ;

while (<IN>) {

    chomp;
    next if /^\#/ ; 

    
    my @r = split /\s+/, $_ ; 
    next if $r[2] eq 'superlocus' ;
    next if $r[2] eq 'gene' ;
    next if $r[2] eq 'ncRNA_gene' ;

    my $tID = '' ; 
    
    if ( $r[2] eq 'mRNA' && /ID=(\S+)\;Parent/ ) {
	$tID = $1 ; 
	#print "$tID\n" ;
	next unless $included_trans{$tID} ;

	#maker compliant gff
	print "$r[0]\test2genome\texpressed_sequence_match\t$r[3]\t$r[4]\t$included_trans_score{$tID}\t$r[6]\t.\tID=$tID.mikado2est\;Name=$tID\n" ;

    }
    elsif ( $r[2] eq 'ncRNA' && /ID=(\S+)\;Parent/ ) {
	$tID = $1 ;
	#print "$tID\n" ;
	next unless $included_trans{$tID} ;
    }
    elsif ( $r[2] eq 'exon' ) {
	next ; 
    }
    elsif ( $r[2] =~ /UTR/ ) {
	next ; 
    }
    elsif ( /Parent=(\S+)/ ) {
	$tID = $1 ;
	#print "$tID\n" ;
	next unless $included_trans{$tID} ;

	$hspCount{$r[0]}++ ; 
	print "$r[0]\test2genome\tmatch_part\t$r[3]\t$r[4]\t$included_trans_score{$tID}\t$r[6]\t.\tID=$r[0]:hsp:$hspCount{$r[0]}\;Parent=$tID.mikado2est\;Target=$tID " ; 
	print "$included_trans{$tID} " . ($r[4] - $r[3] + $included_trans{$tID} ) . " $r[6]\;Gap=M" . ($r[4]-$r[3]+1) ;
	$included_trans{$tID} += ($r[4] - $r[3] + 1) ;  
	print "\n" ; 
	
	#print "@r\n" ; 
    }
    else {
	print "Warning not caught! @r\n" ;
	exit ; 
    }

	#$gene =~ s/\.\d+:mRNA//gi ; 



	#print "$r[0]\t$r[1]\t$r[2]\t$r[3]\t$r[4]\t$r[5]\t$r[6]\t$r[7]\tgene_id \"$gene\" transcript_id \"$mRNA\" exon_number \"$exon\"\n" ; 
    


}
close(IN) ; 
