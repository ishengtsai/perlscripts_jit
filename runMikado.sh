#!/bin/bash

if [ $# -eq 0 ]
then
    echo "runPE.sh proteome.fa"
    exit 1
fi


REF=$1





# mikado configure [mode permissive]
mikado configure --list list --reference ref.fa configuration.yaml

# mikado prepare
mikado prepare --json-conf configuration.yaml

# diamond ;
cp -s $REF blastdb.fa

diamond makedb -d blastdb.fa --in blastdb.fa
diamond blastx --max-target-seqs 5 --outfmt 5 --threads 30 -d blastdb.fa -q mikado_prepared.fasta --evalue 0.000001 2>diamond.log | gzip -c - > mikado.blast.xml.gz


# transdecoder [5.3.0]
# conda install -c bioconda transdecoder
# conda install -c bioconda perl-uri
# cpanm URI::Escape
TransDecoder.LongOrfs -t mikado_prepared.fasta 
TransDecoder.Predict -t mikado_prepared.fasta 

# mikado serialize
# make sure file mikado.db is not present
mikado serialise --json-conf configuration.yaml --xml mikado.blast.xml.gz \
	--orfs mikado_prepared.fasta.transdecoder.bed --blast_targets blastdb.fa \
	--junctions portcullis_filtered.pass.junctions.bed

# mikado pick
mikado pick --json-conf configuration.yaml --mode permissive


# Parsing with CDS only!
# v4 now!!
gffMikado2makerEstgff.v4.pl mikado.loci.metrics.tsv mikado.loci.gff3 100 0.1 0 > makerEst.gff
