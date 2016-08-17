#!/usr/bin/perl
use strict;
use warnings;

#usage is perl OneBigNexus filenamepattern
#will read all fasta files (aligned, please!) listed in column 1 of a text file, and produce a single nexus file 

my $listfile = $ARGV[0];


open(LF,"<$listfile") or die("cannot open list file ".$listfile);
my @files;
while (<LF>) { 
	chomp;
	my @line = split(/\t/);
	push(@files,$line[0]);
}
close LF;

my $numseqs = -1;
my %seqs;
foreach my $f (@files) { 
	open(INF,"<$f") or die("cannot open $f");
	my $seqlen = -1;
	my $title = "";
	my $genome = "";
	my $seq = "";
	my $thiscount = 0;
	print STDERR $f."\n";
	while (<INF>) {
		chomp;
		if (m/^>/) { 
			if ($title ne "") {
				if ($seqlen > -1) { 
					if (length $seq != $seqlen) { die ("in file ".$f." we have a problem - $title not the same length (".(length $seq)." rather than ".$seqlen.") as other seqs here\n"); 
					} 
				} else { $seqlen = length $seq; }
				if ($genome ne "") { 
				$seqs{$genome} .= $seq;
				}
				$seq = "";
			}
			($title = $_) =~ s/^>//;
			$title =~ m/([\S+]+)/;
			


			$genome = $1;
			print STDERR $title."->".$genome."\n";
		} else { $seq .= $_; }
	}
	if ($seqlen > -1) { 
		if (length $seq != $seqlen) { die("in file ".$f." we have a problem - ".$title." not the same length (".(length $seq)." rather than ".$seqlen.") as other seqs here\n"); 
		}
	} else { $seqlen = length $seq; }
	if ($genome ne "") { $seqs{$genome} .= $seq; } 
}

my $len = -1;
foreach my $s (keys %seqs) { 
	my $thislen = length $seqs{$s};
	print STDERR $s."\t".$thislen."\n";
	if ($len > -1) { 
		if ($thislen != $len) { die("lengths not equal - $s has len ".$thislen." not ".$len."\n"); }
	} else { $len = $thislen; }	
}
#die();


#print "#NEXUS\n\nBEGIN DATA;\nDIMENSIONS NTAX=".(scalar keys %seqs)." NCHAR=".$len.";\n";
#print "FORMAT DATATYPE=DNA GAP=-;\n";
#print "MATRIX\n";
foreach my $s (keys %seqs) { 
	print ">".$s."\n".$seqs{$s}."\n";
}
#print "\t;\n";
#print "ENDBLOCK;\n";
