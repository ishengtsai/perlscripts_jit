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
#smalt index -k 20 -s 13 $REF $REF
#smalt map -i 10000 -n $CPU -x -f samsoft -o $SAMPLE.sam $REF $FORWARD $REVERSE
#samtools sort -@ $CPU -O bam -o $SAMPLE.sorted.bam $SAMPLE.sam
#java -Xmx6g -jar /home/ijt/bin/picard.jar MarkDuplicates METRICS_FILE=metrics CREATE_INDEX=true INPUT=$SAMPLE.sorted.bam OUTPUT=$SAMPLE.sorted.markdup.bam
#bamtools stats -in $SAMPLE.sorted.markdup.bam -insert > $SAMPLE.sorted.markdup.bam.stats
#java -Xmx128G -jar /home/ijt/bin/pilon-1.22.jar --diploid --threads 48  --genome $REF --frags $SAMPLE.sorted.markdup.bam --output $SAMPLE  1> pilon.$ROUND.out 2> pilon.$ROUND.err
#rm $SAMPLE.sam


# second round
REF=pilon.$ROUND.fasta
ROUND=2
SAMPLE=pilon.$ROUND
#smalt index -k 20 -s 13 $REF $REF
#smalt map -i 10000 -n $CPU -x -f samsoft -o $SAMPLE.sam $REF $FORWARD $REVERSE
#samtools sort -@ $CPU -O bam -o $SAMPLE.sorted.bam $SAMPLE.sam
#java -Xmx6g -jar /home/ijt/bin/picard.jar MarkDuplicates METRICS_FILE=metrics CREATE_INDEX=true INPUT=$SAMPLE.sorted.bam OUTPUT=$SAMPLE.sorted.markdup.bam
#bamtools stats -in $SAMPLE.sorted.markdup.bam -insert > $SAMPLE.sorted.markdup.bam.stats
#java -Xmx128G -jar /home/ijt/bin/pilon-1.22.jar --diploid --threads 48  --genome $REF --frags $SAMPLE.sorted.markdup.bam --output $SAMPLE  1> pilon.$ROUND.out 2> pilon.$ROUND.err
#rm $SAMPLE.sam

# third round
REF=pilon.$ROUND.fasta
ROUND=3
SAMPLE=pilon.$ROUND
smalt index -k 20 -s 13 $REF $REF
smalt map -i 10000 -n $CPU -x -f samsoft -o $SAMPLE.sam $REF $FORWARD $REVERSE
samtools sort -@ $CPU -O bam -o $SAMPLE.sorted.bam $SAMPLE.sam
java -Xmx6g -jar /home/ijt/bin/picard.jar MarkDuplicates METRICS_FILE=metrics CREATE_INDEX=true INPUT=$SAMPLE.sorted.bam OUTPUT=$SAMPLE.sorted.markdup.bam
bamtools stats -in $SAMPLE.sorted.markdup.bam -insert > $SAMPLE.sorted.markdup.bam.stats
java -Xmx128G -jar /home/ijt/bin/pilon-1.22.jar --diploid --threads 48  --genome $REF --frags $SAMPLE.sorted.markdup.bam --output $SAMPLE  1> pilon.$ROUND.out 2> pilon.$ROUND.err
rm $SAMPLE.sam

