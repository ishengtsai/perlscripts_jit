#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV != 3) {
	print "$0 fasta repeat_fasta out_prefix\n" ;
	print "fasta.tmp directory must be present for this script to work\n" ;
	exit ;
}

my $fasta = $ARGV[0];
my $repeat_lib = $ARGV[1] ;
my $out = $ARGV[2];

my %contig_len = () ;
my %contig_seq = () ;
my %contig_seq_N = () ;
my @contig_names = () ;


if ( -e "$out.masked.fa" ) {
	print "$out.masked.fa and $out.repeat.content already present...delete..\n" ;
	system("rm $out.masked.fa $out.repeat.content") ;

}



# some parsing 
open OUT , ">" , "$out.repeat.content" or die "cannot create  $out.repeat.content\n" ;





open (IN, "$fasta") or die "oops!\n" ;

	my $read_name = '' ;
	my $read_seq = '' ;

	while (<IN>) {
	    if (/^>(\S+)/) {
		$read_name = $1 ;
		$read_seq = "" ;
		
		while (<IN>) {

			if (/^>(\S+)/) {
			    
			    #print "$read_name\t" . length($read_seq) . "\n" ;


				$contig_len{$read_name} = length($read_seq) ;
				$contig_seq{$read_name} = $read_seq ;

				

				

				push(@contig_names, $read_name) ;
				
				my $old_read_name = $read_name ;
				$read_name = $1 ;


				my $N_count= $read_seq =~ s/([n])/$1/gi;
				$contig_seq_N{$old_read_name} = $N_count ;

			    $read_seq = "" ;

			}
			else {
			    chomp ;
			    $read_seq .= $_ ;
			}


		}

	    }
	}

close(IN) ;


		$contig_len{$read_name} = length($read_seq) ;
		$contig_seq{$read_name} = $read_seq ;
		my $N_count= $read_seq =~ s/([n])/$1/gi;
		$contig_seq_N{$read_name} = $N_count ;

		push(@contig_names, $read_name) ;



# /nfs/users/nfs_j/jit/bin/RepeatMasker/RepeatMasker  239.fa -xm -gff -s -lib ../all_v1.fa

# for problem in schisto...
    for (my $i = 0 ; $i < @contig_names ; $i++) {

	my $count = $i + 1 ;

	unless ( -e "$fasta.tmp/$count.fa.out" ) {
	    print "$count.fa.out wasn't found... redoing..\n" ;
	    chdir "$fasta.tmp/" ;
#	    system("/nfs/users/nfs_j/jit/bin/RepeatMasker/RepeatMasker  $count.fa -xm -gff -s -lib ../consensi.atleast1kb.fa") ;
#	    system("/nfs/users/nfs_j/jit/bin/RepeatMasker/RepeatMasker  $count.fa -xm -gff -s -lib ../consensi.fa.classified") ;
#            system("/nfs/users/nfs_j/jit/bin/RepeatMasker/RepeatMasker  $count.fa -xm -gff -s -lib ../all_v1.fa") ;
#	    system("/nfs/users/nfs_j/jit/bin/RepeatMasker/RepeatMasker  $count.fa -xm -gff -s -lib ../Iter_1.fasta") ;
#            system("/software/pubseq/bin/RepeatMasker  $count.fa -xm -gff -s -lib ../$repeat_lib") ;
	    system("RepeatMasker $count.fa -xm -gff -s -lib ../$repeat_lib") ;

	    chdir "../" ;

	}

    }

system("cat $fasta.tmp/*.cat > $out.cat") ;




# put hash to all the annotations
my %repeats = () ;
open (IN, "$out.cat") or die "oops!\n" ;

while (<IN>) {

	chomp ;

	my @line = split /\s+/ , $_ ;
	next unless @line > 8 ; 
	next if $line[0] =~ /\#/ ;
	next if $line[0] =~ /\D+/ ;
	next unless $line[0] =~ /^\d+/ ; 

	#print "line: @line\n" ; 


	for (my $i = $line[5] ; $i < ($line[6]+1) ; $i++) {
			$repeats{$line[4]}{$i}++ ;
	}

	#last;

}
close(IN) ;

for (my $i = 0 ; $i < @contig_names ; $i++) {


	my $contig = $contig_names[$i] ;
	my $count = $i + 1 ;

	print "doing contig: $contig\n" ;


	if (  $repeats{$contig} ) {
		my $repeat_content =  0;

		

		for my $repeat_base ( keys %{ $repeats{$contig} } ) {
			my $base = substr ($contig_seq{$contig}, ($repeat_base - 1), 1) ;
			$repeat_content++ if $base ne 'N' ;
		}


		print OUT "$contig\t$repeat_content\t$contig_len{$contig}\t" . ($repeat_content / $contig_len{$contig} * 100)   ."\n" ;

		system("cat $fasta.tmp/$count.fa.masked >> $out.masked.fa") ;

	}
	else {

		if ( -e "$fasta.tmp/$count.fa.out" ) {
		    

			my $output = `grep 'no repetitive' $fasta.tmp/$count.fa.out` ;
			
			if ( $output ) {
			    if ($output =~ /There were no repetitive/) {
				print "no repeats were found in $contig\n" ;
			    }
			}
			else {
			    print "wierd in $fasta.tmp/$count.fa.out !!!!\n" ;
			}

		}
		else {
			print "error in repeatmasking $count.fa ; $contig\n" ;
			exit ;
		}

		print OUT "$contig\t0\t$contig_len{$contig}\t0\n" ;
		
		open OUTFA, ">>" , "$out.masked.fa" or die "can not append to $out.masked.fa" ;
		print OUTFA ">$contig\n$contig_seq{$contig}\n" ;
		close(OUTFA) ;

	}



}




