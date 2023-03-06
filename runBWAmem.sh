#!/bin/bash

if [ $# -eq 0 ]
then
    echo "$0 forward reverse  refFile numCPU sample "
    exit 1
fi



FORWARD=$1
REVERSE=$2
REF=$3
CPU=$4
SAMPLE=$5



bwa-mem2 index  $REF 
bwa-mem2 mem  -t $CPU  $REF $FORWARD $REVERSE | samtools view -b - > $SAMPLE.bam
samtools fixmate -@ $CPU -m -O bam $SAMPLE.bam $SAMPLE.fixmate.bam
samtools sort -@ $CPU -o $SAMPLE.fixmate.sorted.bam $SAMPLE.fixmate.bam
samtools markdup -@ $CPU $SAMPLE.fixmate.sorted.bam $SAMPLE.fixmate.sorted.markdup.bam
samtools index $SAMPLE.fixmate.sorted.markdup.bam

# bamtools stats
bamtools stats -in $SAMPLE.fixmate.sorted.markdup.bam -insert > $SAMPLE.fixmate.sorted.markdup.bam.stats





   






