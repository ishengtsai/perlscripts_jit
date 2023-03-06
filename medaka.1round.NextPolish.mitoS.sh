
0;95;0c
if [ $# -ne 7 ] ; then
    echo "$0 REF READS CPU MODEL fq1 fq2 SAMPLEID"
    exit 0
fi



REF=$1
READS=$2
CPU=$3
MODEL=$4
FQ1=$5
FQ2=$6
SAMPLEID=$7

# need to source this first
# https://github.com/conda/conda/issues/7980
source /home/ijt/miniconda3/etc/profile.d/conda.sh


conda activate medaka160


# Minimap
#echo "CPU $CPU REF $REF READS $READS"
#echo "minimap2 -x map-ont -t$CPU $REF $READS -o reads.paf 2> minimap.err"
#minimap2 -x map-ont -t$CPU $REF $READS -o reads.paf 2> minimap.err

# Racon first round
#echo "racon -t $CPU $READS reads.paf $REF consensus.1stround.fa 1>1st.out 2>1st.err"
#racon -t $CPU $READS reads.paf $REF 1>consensus.1stround.fa 2>1st.err

#echo "racon first iteration done!"

# Racon second round
#minimap2 -x map-ont -t$CPU consensus.1stround.fa $READS  -o reads2.paf 2> minimap.err 
#racon -t $CPU $READS reads2.paf consensus.1stround.fa 1>consensus.2ndround.fa  2>2nd.err 

#echo "racon 2nd iteration done!"

# Racon third round
#minimap2 -x map-ont -t$CPU consensus.2ndround.fa $READS  -o reads3.paf 2> minimap.err 
#racon -t $CPU $READS reads3.paf consensus.2ndround.fa 1>consensus.3rdround.fa 2>3rd.err 

#echo "racon 3rd iteration done!"

#Medaka
medaka_consensus -m $MODEL -i $READS -d $REF -t 4


cd medaka

#MitoZ
#conda activate mitozEnv
#mitoz annotate --genetic_code 5 --clade Nematoda --outprefix mitoZ_ONTpolish --thread_number 24 --fastafile consensus.fasta


# NextPolish 2 rounds
echo "/mnt/nas1/ijt/perlscripts_jit/runNextPolishBWAmem.sh $FQ1 $FQ2 consensus.fasta 36"
/mnt/nas1/ijt/perlscripts_jit/runNextPolishBWAmem.sh $FQ1 $FQ2 consensus.fasta 36

# final mitos
#mitoz annotate --genetic_code 5 --clade Nematoda --outprefix mitoZ_ONTpolish_Ilmnpolish --thread_number 24 --fastafile genome.polish.fa


# MitoS

conda activate mitos

mkdir mitos ; # need output folder first
runmitos.py -i genome.polish.fa -c 5 -o mitos -R /home/ijt/mitos/ -r refseq81m 1> runmitos.out 2> runmitos.err 


STRAND=$(grep cox1 mitos/result.gff | awk '$3 == "gene" {print $7}')
#contig_1_np1	mitos	gene	7988	9526	.	+	.	ID=gene_cox1;gene_id=cox1

# circlise based on mitos2 result
START=0
CONTIGNAME=0
if [ "$STRAND" = "+" ]
then
    START=$(grep cox1 mitos/result.gff | awk '$3 == "gene" {print $4}')
    CONTIGNAME=$(grep cox1 mitos/result.gff | awk '$3 == "gene" {print $1}')
    echo "strand: $STRAND and start: $START "
    echo "fasta_CircleChangeStart.pl genome.polish.fa $CONTIGNAME $START $STRAND $SAMPLEID.mito > genome.polish.recir.fa"
    fasta_CircleChangeStart.pl genome.polish.fa $CONTIGNAME $START $STRAND $SAMPLEID.mito > genome.polish.recir.fa

else
    START=$(grep cox1 mitos/result.gff | awk '$3 == "gene" {print $5}')
    CONTIGNAME=$(grep cox1 mitos/result.gff | awk '$3 == "gene" {print $1}')
    echo "strand: $STRAND and start: $START "
    echo "fasta_CircleChangeStart.pl genome.polish.fa $CONTIGNAME $START $STRAND $SAMPLEID.mito > genome.polish.recir.fa"
    fasta_CircleChangeStart.pl genome.polish.fa $CONTIGNAME $START $STRAND $SAMPLEID.mito > genome.polish.recir.fa
fi


mkdir recirc.mitos2
runmitos.py -i genome.polish.recir.fa -c 5 -o recirc.mitos2 -R /home/ijt/mitos/ -r refseq81m 1> run.recirc.mitos2.out 2>run.recirc.mitos2.err



conda activate mitos1.0.5
mkdir mitos1.0.5 ; # need output folder first
runmitos.py -i genome.polish.fa -c 5 -o mitos1.0.5 -r /home/ijt/mitos/mitos1-refdata  1> runmitos1.out 2> runmitos1.err

mkdir recirc.mitos1.0.5
runmitos.py -i genome.polish.recir.fa -c 5 -o recirc.mitos1.0.5 -r /home/ijt/mitos/mitos1-refdata  1> run.recirc.mitos1.out 2> run.recirc.mitos1.out

