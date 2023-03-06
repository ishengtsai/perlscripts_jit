#! /usr/bin/perl -w

######################################################################################
# This script takes alignment sequence fasta file and converts it to phylip file
# Author: Wenjie Deng
# Date: 2007-01-29
# Usage: perl Fasta2Phylip.pl inputFastaFile outputPhilipFile
######################################################################################
use strict;

my $usage = "Usage: $0  inputFastaFile outputPhilipFile\n";
my $infile = shift or die($usage);	# input nexus file
my $outFile = shift or die($usage);	# output phylip file
my $unixFile = $infile.".unix";

my $seqnameLen = 20 ; 


ConvertToUnix ($infile, $unixFile);
ChangetoPhylip($unixFile, $outFile);
unlink ($unixFile);
print "All done!\n";

exit 0;




######################################################################################
sub ConvertToUnix {
	my ($infile, $unixFile) = @_;
	open (IN, $infile) or die "Couldn't open $infile: $!\n";
	open (OUT, ">$unixFile") or die "Couldn't open $unixFile: $!\n";
	my @buffer = <IN>;
	close IN;
	my $line = "";
	foreach my $element (@buffer) {
		$line .= $element;
	}
	if ($line =~ /\r\n/) {
		$line =~ s/\r//g;
	}elsif ($line =~ /\r/) {
		$line =~ s/\r/\n/g;
	}
	print OUT $line;	
	close OUT;	
}


######################################################################################
sub ChangetoPhylip {
	my ($unixFile, $phylipFile) = @_;
	my $seqCount = 0;
	my $seq = my $seqName = "";
	open IN, $unixFile or die "Couldn't open $unixFile\n";
	while (my $line = <IN>) {
		chomp $line;
		next if $line =~ /^\s*$/;
		if ($line =~ /^>/) {
			$seqCount++;
		}elsif ($seqCount == 1) {
			$seq .= $line;
		}
	}
	close IN;
	my $seqLen = length $seq;
	
	open(IN, $unixFile) || die "Can't open $unixFile\n";
	open(OUT, ">$phylipFile") || die "Cant open $phylipFile\n";
	print OUT $seqCount," ",$seqLen,"\n";
	$seqCount = 0;
	$seq = "";
	while(my $line = <IN>) {
		chomp $line;	
		next if($line =~ /^\s*$/);
	
		if($line =~ /^>(\S+)/) {
			if ($seqCount) {
				my $len = length $seq;
				if ($len == $seqLen) {
				    my $currentSeqnameLen = length ($seqName) ;

				    if ( $currentSeqnameLen > $seqnameLen ) {
					print "seq name: $seqName too long with $currentSeqnameLen than expected $seqnameLen\n" ;
					exit ; 
				    }
				    
				    my $newSeqNameHeader = $seqName . " " x ( $seqnameLen - $currentSeqnameLen ) ;
				    
				    print OUT "$newSeqNameHeader$seq\n";

				    if ( $seq =~ /\s+/ ) {
					print "$seqName very weird containing spaces!\n" ; 
				    }
				    
				    $seq = $seqName = "";


				    
				}else {
					unlink $unixFile;
					unlink $phylipFile;
					die "Error: the sequence length of $seqName is not same as others.\n";
				}
			}	
			$seqName = $1;

			$seqName =~ s/\#/\./gi ; 
			$seqName =~ s/\%/\./gi ;
                        $seqName =~ s/\:/\./gi ;


			$seqCount++;
		}else {
			$seq .= $line;		
		}		
	}
	close IN;
	# check the length of last sequence
	my $len = length $seq;
	if ($len == $seqLen) {
	    my $currentSeqnameLen = length ($seqName) ;

	    if ( $currentSeqnameLen > $seqnameLen ) {
		print "seq name: $seqName too long with $currentSeqnameLen than expected $seqnameLen\n" ;
		exit ;
	    }

	    my $newSeqNameHeader = $seqName . " " x ( $seqnameLen - $currentSeqnameLen ) ;

	    if ( $seq =~ /\s+/ ) {
		print "$seqName very weird containing spaces!\n" ;
	    }
	    
	    print OUT "$newSeqNameHeader$seq\n";
	    $seq = $seqName = "";
	    #print OUT "$seqName\t$seq\n";
	}else {
		unlink $unixFile;
		unlink $phylipFile;
		die "Error: the sequence length of $seqName is not same as others.\n";
	}	
	close IN;
	close OUT;
}

