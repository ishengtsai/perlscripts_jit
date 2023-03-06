

if [ $# -ne 4 ] ; then
    echo "$0 REF READS CPU MODEL"
    exit 0
fi



REF=$1
READS=$2
CPU=$3
MODEL=$4

# need to source this first
# https://github.com/conda/conda/issues/7980
source /home/ijt/miniconda3/etc/profile.d/conda.sh


conda activate medaka160


# Minimap
echo "CPU $CPU REF $REF READS $READS"
minimap2 -t$CPU $REF $READS  1> reads.paf 2> minimap.err

# Racon first round
echo "racon -t $CPU $READS reads.paf $REF consensus.1stround.fa 1>1st.out 2>1st.err"
racon -t $CPU $READS reads.paf $REF 1>consensus.1stround.fa 2>1st.err

echo "racon first iteration done!"

# Racon second round
minimap2 -t$CPU consensus.1stround.fa $READS  1> reads2.paf 2> minimap.err 
racon -t $CPU $READS reads2.paf consensus.1stround.fa 1>consensus.2ndround.fa  2>2nd.err 

echo "racon 2nd iteration done!"

# Racon third round
minimap2 -t$CPU consensus.2ndround.fa $READS  1> reads3.paf 2> minimap.err 
racon -t $CPU $READS reads3.paf consensus.2ndround.fa 1>consensus.3rdround.fa 2>3rd.err 

echo "racon 3rd iteration done!"

#Medaka
medaka_consensus -m $MODEL -i $READS -d consensus.3rdround.fa -t 4

#MitoZ
cd medaka

conda activate mitozEnv
mitoz annotate --genetic_code 5 --clade Nematoda --outprefix mitoZ_ONTpolish --thread_number 24 --fastafile consensus.fasta
