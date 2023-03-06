#!/usr/bin/perl -w
use strict;



if (@ARGV != 3) {
	print "$0 gff contigs.fa.len.txt species\nNote: Need to read only Non-redundant isoform PASA!\n" ;

	exit ;
}

my $file = shift @ARGV;
my $contiglenfile = shift @ARGV ; 
my $species = shift @ARGV ; 
my $id = 0 ; 


print "start id: $id\n" ; 




open (IN, "$file") or die "oops!\n" ;

open OUT, ">", "$file.sorted.parsed.gff" or die "ooops\n" ;



my @contig_order = () ; 

open (CON, "$contiglenfile") or die "ooops\n" ; 
while (<CON>) {
    chomp ; 
    my @r = split /\s+/, $_ ; 
    push(@contig_order, $r[0]) ; 
}
close(CON) ; 

#my %gene_strand = () ;
#my %gene_loc = () ;
#my %gene_exons = () ;
#my %gene_exon_num = () ;
#my %gene_introns = () ;
#my %gene_intron_num = () ;

my %gene_start = () ;
my %gene_info = () ; 



my $genecount = $id ; 
my $transcriptcount = 0 ; 


## read in the cufflink annotations
while (<IN>) {
	

	next if /^\#/ ;
	next if /^\n/ ;

	chomp ;
	my @r = split /\s+/, $_ ;



	if ($r[2] eq 'gene' ) {


	    # this sometimes happens in PASA when the original model was merged and new model is an isoform, in this case the next line would be empty
	    if ( $gene_info{$r[0]}{$r[3]} ) {
		
		if ( <IN> =~ /^\s+/ ) {
		    next ; 
		}
		
		# here then when it's not the case .. so we still try to catch it
		print "$gene_info{$r[0]}{$r[3]} already present! noo....\n" ;
		print "line: $_\n" ; 
		die ; 
	    }
	    else {
		
		$gene_info{$r[0]}{$r[3]} = "$_\n" ;

		# to catch the empty line again
		my $mRNAline = <IN> ;
		if ( $mRNAline =~ /^\s+/ ) {
		    delete($gene_info{$r[0]}{$r[3]});
		    next ;
		}
		else {
		    $gene_info{$r[0]}{$r[3]} .= $mRNAline ;
		}
		     
		
		
		while (<IN>) {
		    
		    if ( /^\#/ ) {
			last ;
		    }
		    elsif ( /^\s+/  ) {
			last ; 
		    }
		    else {
			$gene_info{$r[0]}{$r[3]} .= $_ ;

		    }
		}


	    }
	}

	#last;
}
close(IN) ;





my %present = () ; 

foreach my $contig (@contig_order ) {

    for my $coord (sort  { $a <=> $b } keys  % {$gene_info{$contig}} ) {
	$genecount++ ;
	
	#print "$gene_info{$contig}{$coord}\n" ;
	my $gffblock = $gene_info{$contig}{$coord} ;
	my @lines = split /\n/, $gffblock ;

	# catch here if something weird happend
	if ( @lines <= 1 ) {
	    print "Weird!!! @lines\n" ;
	    print "gffblock:  $gffblock\n" ;
	    die ; 
	}
	
	my @geneline = split /\s+/, $lines[0] ;
	my @mRNAline = split /\s+/, $lines[1] ;
	#print "$geneline[8]\n" ; 

	my $oldid ;
	if ( $geneline[8] =~ /ID=(\S+)\;Name/ ) {
	    $oldid = $1 ; 
	}

	my $oldmRNAid ;
	if ( $mRNAline[8] =~ /ID=(\S+)\;Parent/ ) {
            $oldmRNAid = $1 ;
        }
	
	my $idnum = sprintf("%07d", $genecount * 100) ;
	my $id = "$species\_$idnum" ;

	$gffblock =~ s/$oldid/$id/g ;
	$gffblock =~ s/$oldmRNAid/$id:mRNA/g ;
	$gffblock =~ s/MERGED.+\n/$id\n/g ;
	
	print "$oldid  ----> $id \n" ;
	print OUT "$gffblock" ; 
	
    }

}



print "all done!!!\n" ;
print "$genecount total genes\n" ;


#my $idnum = sprintf("%07d", $genecount * 100) ;
#$id = "$species\_$idnum" ;
#print "last id: $id\n" ;








