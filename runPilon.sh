#!/bin/bash

if [ $# -eq 0 ]
then
    echo "runPilon.sh forward reverse  refFile numCPU "
    exit 1
fi



FORWARD=$1
REVERSE=$2
REF=$3
CPU=$4

ROUND=1
SAMPLE=pilon.$ROUND

# once
smalt index -k 20 -s 13 $REF $REF
smalt map -i 10000 -n $CPU -x -f samsoft $REF $FORWARD $REVERSE | samtools view -b - > $SAMPLE.bam
samtools fixmate -@ $CPU -m -O bam $SAMPLE.bam $SAMPLE.fixmate.bam
samtools sort -@ $CPU -o $SAMPLE.fixmate.sorted.bam $SAMPLE.fixmate.bam
samtools markdup -@ $CPU $SAMPLE.fixmate.sorted.bam $SAMPLE.fixmate.sorted.markdup.bam
# bamtools stats
bamtools stats -in $SAMPLE.fixmate.sorted.markdup.bam -insert > $SAMPLE.fixmate.sorted.markdup.bam.stats




# second round
REF=pilon.$ROUND.fasta
ROUND=2
SAMPLE=pilon.$ROUND

smalt index -k 20 -s 13 $REF $REF
smalt map -i 10000 -n $CPU -x -f samsoft $REF $FORWARD $REVERSE | samtools view -b - > $SAMPLE.bam
samtools fixmate -@ $CPU -m -O bam $SAMPLE.bam $SAMPLE.fixmate.bam
samtools sort -@ $CPU -o $SAMPLE.fixmate.sorted.bam $SAMPLE.fixmate.bam
samtools markdup -@ $CPU $SAMPLE.fixmate.sorted.bam $SAMPLE.fixmate.sorted.markdup.bam
# bamtools stats
bamtools stats -in $SAMPLE.fixmate.sorted.markdup.bam -insert > $SAMPLE.fixmate.sorted.markdup.bam.stats


# third round
REF=pilon.$ROUND.fasta
ROUND=3
SAMPLE=pilon.$ROUND

smalt index -k 20 -s 13 $REF $REF
smalt map -i 10000 -n $CPU -x -f samsoft $REF $FORWARD $REVERSE | samtools view -b - > $SAMPLE.bam
samtools fixmate -@ $CPU -m -O bam $SAMPLE.bam $SAMPLE.fixmate.bam
samtools sort -@ $CPU -o $SAMPLE.fixmate.sorted.bam $SAMPLE.fixmate.bam
samtools markdup -@ $CPU $SAMPLE.fixmate.sorted.bam $SAMPLE.fixmate.sorted.markdup.bam
# bamtools stats
bamtools stats -in $SAMPLE.fixmate.sorted.markdup.bam -insert > $SAMPLE.fixmate.sorted.markdup.bam.stats


