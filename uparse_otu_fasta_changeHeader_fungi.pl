#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';




if (@ARGV != 1) {
    print "$0 fasta \n" ;
	exit ;
}

my $filenameA = $ARGV[0];



open OUT, ">", "$filenameA.OTUheader.changed.fa" ;

open (IN, "$filenameA") or die "oops!\n" ;

my $count = 1 ; 

	while (<IN>) {



	    if (/^>(\S+)/) {
		my $seqname = $1 ; 

		$seqname =~ s/tax=d/tax=k/ ; 
		$seqname =~ s/\(\d+\.\d+\)//gi ; 

		$seqname =~ s/\,s:.+\;$/\;/ ; 

		unless ( $seqname =~ /p:/ ) {
		    $seqname =~ s/\;$//;
		    $seqname .= ",p:NA;" ; 
		}

		unless ( $seqname =~ /c:/ ) {
		    $seqname =~s/\;$//;
		    $seqname .=",c:NA;" ;
		}

		unless ( $seqname =~ /o:/ ) {
		    $seqname =~s/\;$//;
		    $seqname .=",o:NA;" ;
		}

		unless ( $seqname =~ /f:/ ) {
		    $seqname =~s/\;$//;
		    $seqname .=",f:NA;" ;
		}

		unless ( $seqname =~ /g:/ ) {
		    $seqname =~s/\;$//;
		    $seqname .=",g:NA;" ;
		}
		
		
		print "changed: $seqname\n" ; 

		print OUT ">$seqname\n" ; 

	    }
	    else {
		chomp; 
		print OUT "$_\n" ;

	    }

	}

close(IN) ;

print "done! $filenameA.OTUheader.changed.fa produced\n" ; 


