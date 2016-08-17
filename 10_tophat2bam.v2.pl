#!/usr/bin/perl -w
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


if (@ARGV != 6 ) {
	print "$0 <ref.fa> <read_1> <read_2> <out prefix> <ram> \"parameter in double quotes\" \n" ;
	print "\nref.fa => the reference in fasta file\n" ;
	print "if read_2 eq 'NA', then single read pairing will be used\n" ; 

	exit;
}

# set path
#my $pathtoset = '/home/tk6/applications/tophat2/:/home/tk6/applications/bowtie2/:/bin/:/usr/local/bin/:/usr/bin/' ; 
my $pathtoset = '/home/ishengtsai/bin/tophat-2.0.11.Linux_x86_64/;/home/ishengtsai/bin/bowtie2-2.2.1/' ; 
$ENV{PATH} = "$pathtoset:$ENV{PATH}" ; 



my $ref = shift;
my $read_1 = shift;
my $read_2 = shift;
my $outprefix = shift ; 
my $ram = shift ;
my $parameters = shift ; 




chomp($PI) ;



######################################
# checking all the paths
print "checking all the paths..\n" ;
checkpath("bowtie2-build") ;
checkpath("$tophat/tophat2") ;



print '------------------------------------------------------------------------------------------------' ;
print "\ntophat ---> bam \n" ;
print "\nProcess ID:$PI\n" ;
print "\nreference = $ref \n";
print "read_1 = $read_1 \n" ;
print "read_2 = $read_2 \n";
print "tophat command: tophat2  $parameters\n" ; 
print '------------------------------------------------------------------------------------------------' . "\n\n";



# bowtie indexing
print "\n\nbowtie-build: building hash on reference!\n" ;
mkdir "$outprefix" ; 
chdir "$outprefix" ; 
print "change directory to $outprefix\n\n" ; 

system("cp -s ../$ref ref.fa") ; 

my $qsub_command ;
$qsub_command = '/home/tk6/bin/python3/qsub.v2.py 3 index' . $PI . " /home/ishengtsai/bin/bowtie2-2.2.1/bowtie2-build ref.fa ref";
print "$qsub_command\n" ; 
system("$qsub_command") ;

print "\n\nsubmitting job!\n" ;


# tophat mapping
if ( $read_2 ne 'NA' ) {
    $qsub_command = '/home/tk6/bin/python3/qsub.v2.py ' . ' -n fat --def_slot 8 --dep "index' . $PI . '" 4 top' . $PI . ' "' . "$tophat/tophat2 -p 8  $parameters ref $read_1 $read_2 ". '"'  ; 
}
else {
    $qsub_command = '/home/tk6/bin/python3/qsub.v2.py ' . ' -n fat --def_slot 8 --dep "index' . $PI . '" 4 top' . $PI . ' "' . "$tophat/tophat2 -p 8  $parameters ref $read_1 ". '"'  ;
}

    

print("$qsub_command\n");
print "send off tophat dependency!\n" ;
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

