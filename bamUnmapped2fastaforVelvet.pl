#!/usr/bin/perl


if ( @ARGV != 2 ) {

    print "$0 xxx.bam unmapped[1].Or.notproperlypaired[2] \n" ; 
    print "fasta.gz of unmapped reads will be produced\n" ; 
    exit ; 
}


my $file = $ARGV[0] ; 
my $flag = $ARGV[1] ; 

if ( $flag eq '1' ) {
    open (IN, "samtools view -f 4 $file |") or die "ooops\n" ; 
    open $OUTPEFILE, "| gzip -c > $file.unmapped.velvet.PE.fasta.gz" ;
    open $OUTFILE, "| gzip -c > $file.unmapped.velvet.SE.fasta.gz";

}
elsif ( $flag eq '2') {
    open (IN, "samtools view -F 2 $file |") or die "ooops\n" ;
    open $OUTPEFILE, "| gzip -c > $file.notproper.velvet.PE.fasta.gz" ;
    open $OUTFILE, "| gzip -c > $file.notproper.velvet.SE.fasta.gz";
}



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

    $read_count{$seq_name}++ ; 
    $reads{$seq_name} .= ">$r[0]\n$r[9]\n" ; 


    if ( $read_count{$seq_name} == 2 ) {
	#print "$seq_name is paired!\n" ; 

	print $OUTPEFILE "$reads{$seq_name}" ;
	$PEcount++ ; 

	delete $read_count{$seq_name} ; 
	delete $reads{$seq_name} ; 
    }



    
    $count++ ; 
    #last if $count == 1000;

}


for (keys %read_count) {

    $SEcount++ ; 
    print $OUTFILE "$reads{$_}" ;

}




print "$file.unmapped.velvet.PE.fasta.gz produced\n" ; 
print "$file.unmapped.velvet.SE.fasta.gz produced\n" ; 
print "$PEcount paired end reads\n" ; 
print "$SEcount singlet reads\n" ; 
