#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV != 3) {
	print "$0 fasta folder SAMPLENAME\n\n" ;
	exit ;
}

my $filenameA = $ARGV[0];
my $folder = $ARGV[1];
my $SAMPLENAME = $ARGV[2] ; 

my %reads = () ;

if ( -d "$folder") {
    print "$folder present!\n" ; 
}
else {
    mkdir $folder ;
    print "$folder created!\n" ; 
}


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

			    
			    
			    open OUT, ">>", "$folder/$read_name.fa" or die "can not open and append $folder/$read_name.fa" ; 
			    print OUT ">$SAMPLENAME.$read_name\n$read_seq\n" ;
			    close(OUT); 

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

open OUT, ">>", "$folder/$read_name.fa" or die "can not open and append $folder/$read_name.fa" ;
print OUT ">$SAMPLENAME.$read_name\n$read_seq\n" ;
close(OUT);


print "all done! files in $folder\n" ; 
