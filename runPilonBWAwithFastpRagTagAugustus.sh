#!/bin/bash

if [ $# -eq 0 ]
then
    echo "runPilonBWAwithFastpRagTagAugustus.sh forward reverse  refFile numCPU prefix"
    exit 1
fi



FORWARDTMP=$1
REVERSETMP=$2
REF=$3
CPU=$4
PREFIX=$5

ROUND=1
SAMPLE=pilon.$ROUND


# trim with fastp
fastp -i $FORWARDTMP -I $REVERSETMP -o F.fq.gz -O R.fq.gz -w $CPU &


FORWARD=F.fq.gz
REVERSE=R.fq.gz


# once
bwa index  $REF 
bwa mem  -t $CPU  $REF $FORWARD $REVERSE | samtools view -b - > $SAMPLE.bam
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

bwa index  $REF
bwa mem  -t $CPU  $REF $FORWARD $REVERSE | samtools view -b - > $SAMPLE.bam
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

bwa index  $REF
bwa mem  -t $CPU  $REF $FORWARD $REVERSE | samtools view -b - > $SAMPLE.bam
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

bwa index  $REF
bwa mem  -t $CPU  $REF $FORWARD $REVERSE | samtools view -b - > $SAMPLE.bam
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

bwa index  $REF
bwa mem  -t $CPU  $REF $FORWARD $REVERSE | samtools view -b - > $SAMPLE.bam
samtools fixmate -@ $CPU -m -O bam $SAMPLE.bam $SAMPLE.fixmate.bam
samtools sort -@ $CPU -o $SAMPLE.fixmate.sorted.bam $SAMPLE.fixmate.bam
samtools markdup -@ $CPU $SAMPLE.fixmate.sorted.bam $SAMPLE.fixmate.sorted.markdup.bam
samtools index $SAMPLE.fixmate.sorted.markdup.bam

# bamtools stats
bamtools stats -in $SAMPLE.fixmate.sorted.markdup.bam -insert > $SAMPLE.fixmate.sorted.markdup.bam.stats

#pilon
java -Xmx128G -jar /home/ijt/bin/pilon-1.22.jar --diploid --threads 48  --genome $REF --frags $SAMPLE.fixmate.sorted.markdup.bam --output pilon.$ROUND  1> pilon.$ROUND.out 2> pilon.$ROUND.err


# sixth round
#REF=pilon.$ROUND.fasta
#ROUND=6
#SAMPLE=pilon.$ROUND

#bwa index  $REF
#bwa mem  -t $CPU  $REF $FORWARD $REVERSE | samtools view -b - > $SAMPLE.bam
#samtools fixmate -@ $CPU -m -O bam $SAMPLE.bam $SAMPLE.fixmate.bam
#samtools sort -@ $CPU -o $SAMPLE.fixmate.sorted.bam $SAMPLE.fixmate.bam
#samtools markdup -@ $CPU $SAMPLE.fixmate.sorted.bam $SAMPLE.fixmate.sorted.markdup.bam
#samtools index $SAMPLE.fixmate.sorted.markdup.bam

# bamtools stats
#bamtools stats -in $SAMPLE.fixmate.sorted.markdup.bam -insert > $SAMPLE.fixmate.sorted.markdup.bam.stats

#pilon
#java -Xmx128G -jar /home/ijt/bin/pilon-1.22.jar --diploid --threads 48  --genome $REF --frags $SAMPLE.fixmate.sorted.markdup.bam --output pilon.$ROUND  1> pilon.$ROUND.out 2> pilon.$ROUND.err



#ragtag
cp -s /mnt/nas1/tjl/ref.genome/S288C_reference_genome_R64-2-1_20150113/SC64-2-1.fa ref.fa
cp -s /mnt/nas1/tjl/ref.genome/S288C_reference_genome_R64-2-1_20150113/saccharomyces_cerevisiae_R64-2-1_20150113.gff scer.gff
ragtag.py scaffold ref.fa pilon.5.fasta
cd ragtag_output



# annotation
#augustus --species=saccharomyces --gff3=on ragtag.scaffolds.fasta 1> ragtag.scaffolds.fasta.out 2> ragtag.scaffolds.fasta.out.err
#contig_length_fasta.pl ragtag.scaffolds.fasta > ragtag.scaffolds.fasta.len.txt
#touch exclude.scaff
#augustus_gff2mygff.pl ragtag.scaffolds.fasta.out ragtag.scaffolds.fasta.len.txt $PREFIX 0 exclude.scaff
#gff2fasta_onlycoding.pl ragtag.scaffolds.fasta.out.mygff.gff ragtag.scaffolds.fasta 0 $PREFIX.nuc.fa
#gff2fasta_onlycoding.pl ragtag.scaffolds.fasta.out.mygff.gff ragtag.scaffolds.fasta 2 $PREFIX.aa.fa




