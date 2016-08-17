#!/usr/bin/perl


if ( @ARGV != 1 ) {

    print "$0 xxx.bam " ; 
    print "fastq of unmapped reads will be produced\n" ; 
    exit ; 
}


my $file = $ARGV[0] ; 



open (IN, "samtools view -f 4 $file |") or die "ooops\n" ; 
open $OUTPEF, ">", "$file.unmapped.F.fastq" ; 
open $OUTPER, ">", "$file.unmapped.R.fastq" ; 
open $OUTSE,  ">", "$file.unmapped.SE.fastq" ; 




#my $count = 0 ; 

my $read = '' ; 
my $seq = '' ; 

my $PEcount =  0 ;
my $SEcount = 0 ; 

my %reads = () ; 
my %read_count = () ; 

my $count = 0 ; 

while(<IN>) {
    my @r = split /\s+/, $_ ; 


    my $seq_name = $r[0] ; 

    if ( $r[1] == 77 ) {
	print $OUTPEF '@' . "$r[0]\n$r[9]\n+\n$r[10]\n" ; 
    }
    elsif ( $r[1] == 141 ) {
	print $OUTPER '@' . "$r[0]\n$r[9]\n+\n$r[10]\n" ;
    }
    else {
	print $OUTSE '@' . "$r[0]\n$r[9]\n+\n$r[10]\n" ;
    }

    
    $count++ ; 
    #last if $count == 1000;

}


print " $file.unmapped.F.fastq , $file.unmapped.R.fastq and $file.unmapped.SE.fastq produced\n" ; 
