#! /usr/bin/perl -w
#
# Time-stamp: <19-Feb-2009 14:43:44 jit>
# $Id: $
#
# Copyright (C) 2008 by Pathogene Group, Sanger Center
#
# Author: JIT
# Description: a parallelised script to split the Illumina reads to subsets
# 
# Modified by Taisei 17aug2013 for DDBJ qsub
#

use strict;


my $PI = `echo $$` ; chomp($PI); 


if (@ARGV != 1 ) {
    print "$0 <fastq like reads.ec.k55.fastq>\n" ; 


	exit;
}

# set path

my $read_1 = shift;


my $reads = 2000000 ; #500000


my $gzipped = 0 ;


chomp($PI) ;



######################################
# checking all the paths
print "checking all the paths..\n" ;


print '------------------------------------------------------------------------------------------------' ;
print "\n sga corrected fastq -> JR initial assembly\n" ; 
print "Process ID:$PI\n" ;
print "fastq = $read_1\n" ;
print '------------------------------------------------------------------------------------------------' . "\n\n";


my $outprefix = 'zzz.JR' ; 

# symbolic link the fastq
my $directory_name = "$outprefix.split" ;



if ( -d "$directory_name" ) {
    print "split directory $directory_name already found !!\n\n" ; 
}

# splitting files according to the reads
print "splitting files into chunks of $reads ..\n" ;

my $count = 1 ;
my $read_count = 0 ;



unless (-d "$directory_name") {

	print "splitted fastqs not found! splitting...\n" ;
	mkdir "$directory_name" or die "cannot create split fastqs!" ;

	if ($read_1 =~ /.fastq$/) {
		$gzipped = 0 ;
	}
	elsif ($read_1 =~ /.gz$/) {
		$gzipped = 1 ;
	}
	
	if ($gzipped == 0 ) {
		open( IN, "$read_1" ) or die "Cannot open $read_1\n";
	}
	else {
		open( IN, "zcat $read_1 |" ) or die "Cannot open $read_1\n";
	}
	
	
	
	
	open OUT_1, '>', "$directory_name/$count.1.fasta" or die "2" ;
	
	while (<IN>) {
            s/\s+//gi ;
	    s/^\@/>/ ; 
	    my $name = $_ ; 
	    my $seq = <IN> ; 
	    my $tmp = <IN> ; 
	    $tmp = <IN> ; 
	    print OUT_1 "$name\n$seq" ;



		$read_count++ ;
	
		if ( $read_count == $reads ) {
			print "$count.1.fasta made!\n" ;
			close(OUT_1) ;
			$count++ ;
	
			open OUT_1, '>', "$directory_name/$count.1.fasta" or die "2" ;
			$read_count = 0 ;
		}
	}
	
	print "$count.1.fasta made!\n" ;
	close(OUT_1) ;

	

}


# split files
mkdir "$outprefix.$PI.JR" or die "cannot create tmp dir!\n" ;
chdir "$outprefix.$PI.JR" ;

my $numfastqs_tmp = `ls ../$directory_name/ | sort -n | tail -n 1` ;
if ( $numfastqs_tmp =~ /(^\d+)\./ ) {
	$count = $1 ;
	print "number of fastqs: $count\n" ;
}

print "\n\nmdust!\n" ; 

##my $bjob_command ;
#$bjob_command = 'bsub -q normal -R "select[type==X86_64 && mem > 3000] rusage[mem=3000]" -M3000000  -J "index' . $PI . '" -o index.%I.o -e index.%I.e "' . "bowtie2-build ../$ref $ref" . '"';
#system("$bjob_command") ;

my $qsub_command ;

my $ram = 1 ; 

print "\n\nsubmitting job!\n" ;


# mdust mapping

open QSH, '>', "map_array.sh" or die "2" ;
print QSH "/home/ishengtsai/bin/mdust/mdust ../$directory_name/" . '$SGE_TASK_ID.1.fasta > ' . " ../$directory_name/" . '$SGE_TASK_ID.1.masked.fasta' ; 

$qsub_command = 'qsub -t 1-' . $count . ':1 -V -cwd -S /bin/bash -N waha' . $PI . ' -l mem_req='. $ram . 'G,s_vmem=' . $ram . 'G map_array.sh';

print "send off qsub job array!\n" ;
print "$qsub_command\n" ;
system("$qsub_command") ;

#chdir("../") ; 

$qsub_command = '/home/tk6/bin/python3/qsub.v2.py ' . ' --dep "waha' . $PI . '" 3 merge' . $PI . ' "' . "cat ../$directory_name/*.masked.fasta > JR.masked.fa \" " ; 



# |  /home/ishengtsai/bin/JR-Assembler/bin//filterN 0 | /home/ishengtsai/bin/JR-Assembler/bin//trimReadKmer 0 0 100 0 | /home/ishengtsai/bin/JR-Assembler/bin//buildTable > JR.histogram \" " ; 



    

print("$qsub_command\n");
print "send off bsub dependency! - merge\n" ;
system("$qsub_command") ;



print "now coffee break...\n" ;














sub checkpath {
my $program = shift ;

	if ( `which $program` ) {
		print "found! $program path: " , `which $program` ;
	}
	else {
		print "$program path not found!\n" ;
		exit ;
	}
}

