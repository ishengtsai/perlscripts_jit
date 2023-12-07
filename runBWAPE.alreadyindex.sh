#!/bin/bash

if [ $# -eq 0 ]
then
    echo "runPE.sh outPrefix forward reverse  refFile numCPU "
    exit 1
fi


SAMPLE=$1
FORWARD=$2
REVERSE=$3
REF=$4
CPU=$5



#bwa index $REF 

bwa mem -t $CPU $REF $FORWARD $REVERSE | samtools view -b - > $SAMPLE.bam



# fixmate, sort then markdup
samtools fixmate -@ $CPU -m -O bam $SAMPLE.bam $SAMPLE.fixmate.bam
samtools sort -@ $CPU -o $SAMPLE.fixmate.sorted.bam $SAMPLE.fixmate.bam
samtools markdup -@ $CPU $SAMPLE.fixmate.sorted.bam $SAMPLE.fixmate.sorted.markdup.bam
samtools index $SAMPLE.fixmate.sorted.markdup.bam

# bamtools stats
bamtools stats -in $SAMPLE.fixmate.sorted.markdup.bam -insert > $SAMPLE.fixmate.sorted.markdup.bam.stats


#Old using picard
#samtools sort -@ $CPU -O bam -o $SAMPLE.sorted.bam $SAMPLE.sam
#java -Xmx6g -jar /usr/local/bioinfo/picard-tools-1.130/picard.jar MarkDuplicates METRICS_FILE=metrics CREATE_INDEX=true INPUT=$SAMPLE.sorted.bam OUTPUT=$SAMPLE.sorted.markdup.bam
#java -Xmx6g -jar /home/ijt/bin/picard.jar MarkDuplicates METRICS_FILE=metrics CREATE_INDEX=true INPUT=$SAMPLE.sorted.bam OUTPUT=$SAMPLE.sorted.markdup.bam
#bamtools stats -in $SAMPLE.sorted.markdup.bam -insert > $SAMPLE.sorted.markdup.bam.stats
