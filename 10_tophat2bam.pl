#! /usr/local/bin/perl -w
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

#my $tophat = '/home/tk6/applications/tophat2/tophat2' ; 
my $tophat = '/home/ishengtsai/bin/tophat-2.0.11.Linux_x86_64/' ; 
my $bowtiepath = '/home/ishengtsai/bin/bowtie2-2.2.1/' ; 

my $PI = `echo $$` ; chomp($PI); 


if (@ARGV != 7 ) {
	print "$0 <ref.fa> <read_1> <read_2> <out prefix> <insert range> <ram> \"parameter in double quotes\" \n" ;
	print "\nref.fa => the reference in fasta file\n" ;
	print "range big => 500 or 3000; etc etc \n" ;

	exit;
}

# set path
#my $pathtoset = '/home/tk6/applications/tophat2/:/home/tk6/applications/bowtie2/:/bin/:/usr/local/bin/:/usr/bin/' ; 
my $pathtoset = '/home/ishengtsai/bin/tophat-2.0.11.Linux_x86_64/;/home/ishengtsai/bin/bowtie2-2.2.1/' ; 
$ENV{PATH} = "$pathtoset:$ENV{PATH}" ; 



my $ref = shift;
my $read_1 = shift;
my $read_2 = shift;

my $reads = 200000 ; #500000
$reads = $reads * 4 ; 

my $outprefix = shift ; 

my $range2 = shift;
my $ram = shift ;
my $parameters = shift ; 

my $gzipped = 0 ;


chomp($PI) ;



######################################
# checking all the paths
print "checking all the paths..\n" ;
checkpath("bowtie2-build") ;
checkpath("$tophat") ;



print '------------------------------------------------------------------------------------------------' ;
print "\ntophat ---> bam \n" ;
print "\nProcess ID:$PI\n" ;
print "\nreference = $ref \n";
print "read_1 = $read_1 \n" ;
print "read_2 = $read_2 \n";
print "chunk size = $reads lines \n" ;
print "-r = $range2 \n" ;
print "tophat command: tophat -r $range2 $parameters\n" ; 
print '------------------------------------------------------------------------------------------------' . "\n\n";




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
		open( IN2, "$read_2" ) or die "Cannot open $read_2\n";
	}
	else {
		open( IN, "zcat $read_1 |" ) or die "Cannot open $read_1\n";
		open( IN2, "zcat $read_2 |" ) or die "Cannot open $read_2\n";
	}
	
	
	
	
	open OUT_1, '>', "$directory_name/$count.1.fastq" or die "2" ;
	open OUT_2, '>', "$directory_name/$count.2.fastq" or die "2" ;
	
	while (<IN>) {
            s/\s+//gi ;
	    print OUT_1 "$_\n" ;

	    my $tmp = <IN2> ;
	    $tmp =~ s/\s+//gi ;
	    print OUT_2 "$tmp\n" ;


		$read_count++ ;
	
		if ( $read_count == $reads ) {
			print "$count.1.fastq and $count.2.fastq made!\n" ;
			close(OUT_1) ;
			close(OUT_2) ;
			$count++ ;
	
			open OUT_1, '>', "$directory_name/$count.1.fastq" or die "2" ;
			open OUT_2, '>', "$directory_name/$count.2.fastq" or die "2" ;
	
			$read_count = 0 ;
		}
	}
	
	print "$count.1.fastq and $count.2.fastq made!\n" ;
	close(OUT_1) ;
	close(OUT_2) ;
	

}


# split files
mkdir "$outprefix.$PI.tmp" or die "cannot create tmp dir!\n" ;
chdir "$outprefix.$PI.tmp" ;

my $numfastqs_tmp = `ls ../$directory_name/ | sort -n | tail -n 1` ;
if ( $numfastqs_tmp =~ /(^\d+)\./ ) {
	$count = $1 ;
	print "number of fastqs: $count\n" ;
}

print "\n\nbowtie-build: building hash on reference!\n" ;

##my $bjob_command ;
#$bjob_command = 'bsub -q normal -R "select[type==X86_64 && mem > 3000] rusage[mem=3000]" -M3000000  -J "index' . $PI . '" -o index.%I.o -e index.%I.e "' . "bowtie2-build ../$ref $ref" . '"';
#system("$bjob_command") ;

my $qsub_command ;
$qsub_command = '/home/tk6/bin/python3/qsub.v2.py 3 index' . $PI . " bowtie2-build ../$ref $ref";
system("$qsub_command") ;

print "\n\nsubmitting job!\n" ;


# tophat mapping
print "indexing job submitted!\n\n" ;
open QSH, '>', "map_array.sh" or die "2" ;
print QSH "$tophat -o " . 'out.$SGE_TASK_ID'  . " $parameters -r $range2 $ref ../$directory_name/" . '$SGE_TASK_ID.1.fastq ' . "../$directory_name/" . '$SGE_TASK_ID.2.fastq ' .
              ';mv out.$SGE_TASK_ID/accepted_hits.bam $SGE_TASK_ID.bam';


$qsub_command = 'qsub -t 1-' . $count . ':1 -V -cwd -S /bin/bash -N waha' . $PI . ' -hold_jid "index' . $PI . '" -l mem_req='. $ram . 'G,s_vmem=' . $ram . 'G map_array.sh';

print "send off qsub job array!\n" ;
print "$qsub_command\n" ;
system("$qsub_command") ;

#chdir("../") ; 

$qsub_command = '/home/tk6/bin/python3/qsub.v2.py ' . ' --dep "waha' . $PI . '" 3 merge' . $PI . ' "' . "samtools merge ../$outprefix.tophat.bam *.bam ". ';' 
    . "samtools index ../$outprefix.tophat.bam " . ';'
    . "samtools merge ../$outprefix.tophat.unmapped.bam out.*/unmapped.bam " . ';'
    . "samtools index ../$outprefix.tophat.unmapped.bam " .  ';'
    . "~tk6/applications/bamtools/bin/bamtools stats -insert -in ../$outprefix.tophat.bam > ../$outprefix.tophat.bam.stats" . ';'
    . "~tk6/applications/bamtools/bin/bamtools stats -insert -in ../$outprefix.tophat.unmapped.bam > ../$outprefix.tophat.unmapped.bam.stats" . ';'
    . 'cat out.*/junctions.bed > raw.merged.juctions.bed | cat raw.merged.juctions.bed |bed_to_juncs |sort -k 1,4 -u |sort -k 1,1 >junction.merged.junc' . ';'
    . 'cat out.*/insertions.bed > raw.merged.insertions.bed' . ";"
    . 'cat out.*/deletions.bed > raw.merged.deletions.bed'
    .  '"';

    

print("$qsub_command\n");
print "send off bsub dependency! - merge\n" ;
system("$qsub_command") ;

chdir("../") ;

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

