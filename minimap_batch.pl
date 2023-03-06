#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV != 3) {
	print "$0 ref list cpu\n\n" ;
	exit ;
}

my $ref = $ARGV[0] ; 
my $filenameA = $ARGV[1];
my $cpu = $ARGV[2] ;


open (IN, "$filenameA") or die "oops!\n" ;

while (<IN>) {
    if (/^(\S+)\s+(\S+)/) {
	my $ID = $1 ;
	my $fastqpath = $2 ;

	print "ID: $ID\n FASTQ: $fastqpath\n" ; 

	# delete first
	system("rm $ID.fq.gz $ID.srt.bam.*") ; 

	# symbolic link fastq
	system("cp -s $fastqpath $ID.fq.gz") ;

	# minimap
	my $minimapcommand = "minimap2 -ax map-ont -t $cpu -R '\@RG\\tID:$ID" ."nanopore\\tSM:$ID' ref.fa PD28A.fq.gz \| samtools sort -o $ID.srt.bam" ;
	print "$minimapcommand\n" ; 
	system("$minimapcommand") ;
	system("samtools index $ID.srt.bam") ;

	
    }
    
    #last ; 
	    
}

close(IN) ;

