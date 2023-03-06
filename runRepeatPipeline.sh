#!/bin/bash

if [ $# -eq 0 ]
then
    echo "runPE.sh ref.fa prefix cpu"
    exit 1
fi


REF=$1
SPECIES=$2
CPU=$3


mkdir $SPECIES
cd $SPECIES
cp -s $REF ref.fa


#Repeatmodeler
mkdir RepeatModeler
cd RepeatModeler
ln -s ../ref.fa
BuildDatabase -name ref.fa ref.fa
RepeatModeler -engine ncbi -pa $CPU -database ref.fa

#TransposonPSI
cd ..
mkdir transposonPSI
cd transposonPSI
ln -s ../ref.fa
export PATH=/home/ijt/bin/blast-2.2.26/bin:$PATH

/home/ijt/bin/TransposonPSI_08222010/transposonPSI.pl ref.fa nuc
transposonPSI_result_2fasta.pl ref.fa ref.fa.TPSI.allHits.chains.bestPerLocus
fasta_include_above_len.pl ref.fa.TPSI.allHits.chains.bestPerLocus.fa 100
cd ..

#Consensus
mkdir consensus 
cd consensus

ln -s ../transposonPSI/ref.fa.TPSI.allHits.chains.bestPerLocus.fa.above100.fa
cp -s ../RepeatModeler/RM_*/consensi.fa.classified .

fasta2single.pl consensi.fa.classified > consensi.SL.fa.classified
cat consensi.SL.fa.classified ref.fa.TPSI.allHits.chains.bestPerLocus.fa.above100.fa > merged.fa

#cluster them and create multiple alignment ; use centroid sequence
usearch8.1.1861_i86linux64 -sortbylength merged.fa -fastaout seqs_sorted.fasta
usearch8.1.1861_i86linux64 -strand both -cluster_smallmem seqs_sorted.fasta -id 0.8 -centroids nr.fasta -uc clusters.uc

touch additional.annotation.txt 
repeat_rename_fasta_for_RepeatMasker.pl nr.fasta additional.annotation.txt > renamed.log 
contig_length_fasta.pl nr.fasta.renamed.fa | grep '\#Unknown' > exclude.unknown.list 
fasta_exclude_subsets.v2.noClean.pl nr.fasta.renamed.fa exclude.unknown.list 

# final repeat library for repeatmasking analysis and for maker 
ln -s nr.fasta.renamed.fa repeatLib.fa 
ln -s nr.fasta.renamed.fa.excluded.fa repeatLib.formaker.fa


# RepeatMasker finally!
cd ..
mkdir denovoRepeat.$SPECIES
mkdir denovoRepeatnolow.$SPECIES ;
RepeatMasker -xsmall -pa $CPU -gff -dir denovoRepeat.$SPECIES -lib consensus/repeatLib.fa ref.fa > denovo.$SPECIES.log


