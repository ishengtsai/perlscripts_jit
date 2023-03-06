#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV != 2) {
	print "$0 fasta SAMPLENAME\n\n" ;
	exit ;
}

my $filenameA = $ARGV[0];
my $SAMPLENAME = $ARGV[1] ; 

my %reads = () ;




open (IN, "$filenameA") or die "oops!\n" ;
#open OUT, ">", "$filenameA.included.fa" or die "daodpoad\n" ; 

	my $read_name = '' ;
	my $read_seq = '' ;

	while (<IN>) {
	    if (/^>.+\s+(\S+)$/) {
		$read_name = $1 ;
		$read_seq = "" ;
		#$read_name =~ s/\#/\./gi ; 
		
		while (<IN>) {

		    
			if (/^>.+\s+(\S+)$/) {

			    
			    
			    #open OUT, ">>", "$folder/$read_name.fa" or die "can not open and append $folder/$read_name.fa" ; 
			    #print OUT ">$SAMPLENAME.$read_name\n$read_seq\n" ;
			    #close(OUT); 
			    #print ">$read_name gene - $SAMPLENAME\n$read_seq\n" ; 

			    $reads{$read_name} = $read_seq ; 
			    
			    
			    $read_name = $1 ;
			    $read_seq = "" ;
			    #$read_name =~ s/\#/\./gi ;


			}
			else {
			    chomp ;
			    $read_seq .= $_ ;
			}


		}

	    }
	}

close(IN) ;

#open OUT, ">>", "$folder/$read_name.fa" or die "can not open and append $folder/$read_name.fa" ;
#print OUT ">$SAMPLENAME.$read_name\n$read_seq\n" ;
#close(OUT);
$reads{$read_name} = $read_seq ;

#print ">$read_name gene - $SAMPLENAME\n$read_seq\n" ;


for my $seq_name (sort keys %reads) {

    if ( $seq_name !~ /^tr/ && $seq_name !~ /^OH/ ) {
	if ( $seq_name !~ /^rrn/ ) {
	    print ">$seq_name gene - $SAMPLENAME\n$reads{$seq_name}\n" ;
	}
    }
    

}


#print "all done! files in $folder\n" ; 
