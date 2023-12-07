#!/bin/bash

if [ $# -eq 0 ]
then
    echo "runPE.sh asm.fa hiclist "
    exit 1
fi


asm=$1
hiclist=$2



#Given a list hiclist of Hi-C read files (suppose in fastq.gz format, paired files in a line) 
#and the assembly asm, use the following code to generate Hi-C alignment files.
bwa index $asm
while read -r r1 r2
do
	prefix=`basename $r1 .fastq.gz`
	echo $r1
  echo $r2
	echo $prefix
	bwa mem -SP -B10 -t96 $asm $r1 $r2 | samtools view -b - > $asm.$prefix.bam
done < $hiclist






