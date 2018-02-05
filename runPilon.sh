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
smalt index -k 14 -s 8 $REF $REF
smalt map -i 10000 -n $CPU -x -f samsoft $REF $FORWARD $REVERSE | samtools view -b - > $SAMPLE.bam
samtools fixmate -@ $CPU -m -O bam $SAMPLE.bam $SAMPLE.fixmate.bam
samtools sort -@ $CPU -o $SAMPLE.fixmate.sorted.bam $SAMPLE.fixmate.bam
samtools markdup -@ $CPU $SAMPLE.fixmate.sorted.bam $SAMPLE.fixmate.sorted.markdup.bam
samtools index $SAMPLE.fixmate.sorted.markdup.bam

# bamtools stats
bamtools stats -in $SAMPLE.fixmate.sorted.markdup.bam -insert > $SAMPLE.fixmate.sorted.markdup.bam.stats

#pilon
java -Xmx128G -jar /home/ijt/bin/pilon-1.22.jar --diploid --threads 48  --genome $REF --frags $SAMPLE.fixmate.sorted.markdup.bam --output pilon.$ROUND  1> pilon.$ROUND.out 2> pilon.$ROUND.err



# second round
REF=pilon.$ROUND.fasta
ROUND=2
SAMPLE=pilon.$ROUND

smalt index -k 14 -s 8 $REF $REF
smalt map -i 10000 -n $CPU -x -f samsoft $REF $FORWARD $REVERSE | samtools view -b - > $SAMPLE.bam
samtools fixmate -@ $CPU -m -O bam $SAMPLE.bam $SAMPLE.fixmate.bam
samtools sort -@ $CPU -o $SAMPLE.fixmate.sorted.bam $SAMPLE.fixmate.bam
samtools markdup -@ $CPU $SAMPLE.fixmate.sorted.bam $SAMPLE.fixmate.sorted.markdup.bam
samtools index $SAMPLE.fixmate.sorted.markdup.bam

# bamtools stats
bamtools stats -in $SAMPLE.fixmate.sorted.markdup.bam -insert > $SAMPLE.fixmate.sorted.markdup.bam.stats

#pilon
java -Xmx128G -jar /home/ijt/bin/pilon-1.22.jar --diploid --threads 48  --genome $REF --frags $SAMPLE.fixmate.sorted.markdup.bam --output pilon.$ROUND  1> pilon.$ROUND.out 2> pilon.$ROUND.err 

# third round
REF=pilon.$ROUND.fasta
ROUND=3
SAMPLE=pilon.$ROUND

smalt index -k 14 -s 8 $REF $REF
smalt map -i 10000 -n $CPU -x -f samsoft $REF $FORWARD $REVERSE | samtools view -b - > $SAMPLE.bam
samtools fixmate -@ $CPU -m -O bam $SAMPLE.bam $SAMPLE.fixmate.bam
samtools sort -@ $CPU -o $SAMPLE.fixmate.sorted.bam $SAMPLE.fixmate.bam
samtools markdup -@ $CPU $SAMPLE.fixmate.sorted.bam $SAMPLE.fixmate.sorted.markdup.bam
samtools index $SAMPLE.fixmate.sorted.markdup.bam

# bamtools stats
bamtools stats -in $SAMPLE.fixmate.sorted.markdup.bam -insert > $SAMPLE.fixmate.sorted.markdup.bam.stats

#pilon
java -Xmx128G -jar /home/ijt/bin/pilon-1.22.jar --diploid --threads 48  --genome $REF --frags $SAMPLE.fixmate.sorted.markdup.bam --output pilon.$ROUND  1> pilon.$ROUND.out 2> pilon.$ROUND.err 




# fourth round
REF=pilon.$ROUND.fasta
ROUND=4
SAMPLE=pilon.$ROUND

smalt index -k 14 -s 8 $REF $REF
smalt map -i 10000 -n $CPU -x -f samsoft $REF $FORWARD $REVERSE | samtools view -b - > $SAMPLE.bam
samtools fixmate -@ $CPU -m -O bam $SAMPLE.bam $SAMPLE.fixmate.bam
samtools sort -@ $CPU -o $SAMPLE.fixmate.sorted.bam $SAMPLE.fixmate.bam
samtools markdup -@ $CPU $SAMPLE.fixmate.sorted.bam $SAMPLE.fixmate.sorted.markdup.bam
samtools index $SAMPLE.fixmate.sorted.markdup.bam

# bamtools stats
bamtools stats -in $SAMPLE.fixmate.sorted.markdup.bam -insert > $SAMPLE.fixmate.sorted.markdup.bam.stats

#pilon
java -Xmx128G -jar /home/ijt/bin/pilon-1.22.jar --diploid --threads 48  --genome $REF --frags $SAMPLE.fixmate.sorted.markdup.bam --output pilon.$ROUND  1> pilon.$ROUND.out 2> pilon.$ROUND.err




# fifth round
REF=pilon.$ROUND.fasta
ROUND=5
SAMPLE=pilon.$ROUND

smalt index -k 14 -s 8 $REF $REF
smalt map -i 10000 -n $CPU -x -f samsoft $REF $FORWARD $REVERSE | samtools view -b - > $SAMPLE.bam
samtools fixmate -@ $CPU -m -O bam $SAMPLE.bam $SAMPLE.fixmate.bam
samtools sort -@ $CPU -o $SAMPLE.fixmate.sorted.bam $SAMPLE.fixmate.bam
samtools markdup -@ $CPU $SAMPLE.fixmate.sorted.bam $SAMPLE.fixmate.sorted.markdup.bam
samtools index $SAMPLE.fixmate.sorted.markdup.bam

# bamtools stats
bamtools stats -in $SAMPLE.fixmate.sorted.markdup.bam -insert > $SAMPLE.fixmate.sorted.markdup.bam.stats

#pilon
java -Xmx128G -jar /home/ijt/bin/pilon-1.22.jar --diploid --threads 48  --genome $REF --frags $SAMPLE.fixmate.sorted.markdup.bam --output pilon.$ROUND  1> pilon.$ROUND.out 2> pilon.$ROUND.err


# sixth round
REF=pilon.$ROUND.fasta
ROUND=6
SAMPLE=pilon.$ROUND

smalt index -k 14 -s 8 $REF $REF
smalt map -i 10000 -n $CPU -x -f samsoft $REF $FORWARD $REVERSE | samtools view -b - > $SAMPLE.bam
samtools fixmate -@ $CPU -m -O bam $SAMPLE.bam $SAMPLE.fixmate.bam
samtools sort -@ $CPU -o $SAMPLE.fixmate.sorted.bam $SAMPLE.fixmate.bam
samtools markdup -@ $CPU $SAMPLE.fixmate.sorted.bam $SAMPLE.fixmate.sorted.markdup.bam
samtools index $SAMPLE.fixmate.sorted.markdup.bam

# bamtools stats
bamtools stats -in $SAMPLE.fixmate.sorted.markdup.bam -insert > $SAMPLE.fixmate.sorted.markdup.bam.stats

#pilon
java -Xmx128G -jar /home/ijt/bin/pilon-1.22.jar --diploid --threads 48  --genome $REF --frags $SAMPLE.fixmate.sorted.markdup.bam --output pilon.$ROUND  1> pilon.$ROUND.out 2> pilon.$ROUND.err




