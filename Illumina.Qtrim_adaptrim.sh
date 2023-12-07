#!/bin/bash

if [ $# -eq 0 ]
then
    echo " Illumina.Qtrim_adaptrim.sh SAMPLE_PREFIX OUT_PREFIX "
    echo " for SAMPLE_PREFIX_R1.fastq.gz ... "
    exit 1
fi


SAMPLE=$1
OUT=$2


conda activate fastp


#cutadapt first
cutadapt -a AGATCGGAAGAGCACACGTCTGAACTCCAGTCA \
    -A AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT \
    -o trimmed.$SAMPLE\_R1.fastq.gz -p trimmed.$SAMPLE\_R2.fastq.gz --cores=16 \
    $SAMPLE\_R1.fastq.gz $SAMPLE\_R2.fastq.gz 1> cutadapt.$SAMPLE.out 2> cutadapt.$SAMPLE.err


# then fastp
fastp --in1 $SAMPLE\_R1.fastq.gz --in2 $SAMPLE\_R2.fastq.gz --out1 $OUT\_1.fq.gz --out2 $OUT\_2.fq.gz \
      --cut_front --cut_tail --cut_window_size 4 --cut_mean_quality 30 --qualified_quality_phred 30  \
      --n_base_limit 5 --length_required 100 -w 16  1> fastp.$SAMPLE.out 2> fastp.$SAMPLE.err





