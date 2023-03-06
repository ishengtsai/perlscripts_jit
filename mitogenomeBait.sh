

if [ $# -ne 4 ] ; then
    echo "$0 SAMPLE_ID INPUT BAIT CPU"
    echo 'need absolute path'
    exit 0
fi

SAMPLE=$1
INPUT=$2
BAIT=$3
CPU=$4


echo "SAMPLE: $SAMPLE INPUT: $INPUT BAIT:$READS"


mkdir $SAMPLE
cd $SAMPLE

# symbolic link
cp -s $INPUT data.fastq.gz
cp -s $BAIT mitobait.pep.fa

diamond makedb --in mitobait.pep.fa -d ref
db=ref
# match reference
diamond blastx --query-gencode 5 --long-reads --threads 60 -d $db -q data.fastq.gz -o $db.matches.tsv


# get the ID out
awk '$4 > 150 {print $1}' $db.matches.tsv | sort | uniq > $db.match.id


# get the reads out
fastq_subset.firstfield.v2.pl $db.match.id  data.fastq.gz data.fastq.gz.subseq.fq 20000

# stats
fastn2stats.py --fastn data.fastq.gz.subseq.fq

#flye
/home/ijt/bin/Flye-2.9/bin/flye --nano-hq data.fastq.gz.subseq.fq --out-dir out_nano_hq_1000 --threads $CPU --min-overlap 1000
/home/ijt/bin/Flye-2.9/bin/flye --nano-hq data.fastq.gz.subseq.fq --out-dir out_nano_hq_2000 --threads $CPU --min-overlap 2000
/home/ijt/bin/Flye-2.9/bin/flye --nano-hq data.fastq.gz.subseq.fq --out-dir out_nano_hq_4000 --threads $CPU --min-overlap 4000

/home/ijt/bin/Flye-2.9/bin/flye --meta --nano-hq data.fastq.gz.subseq.fq --out-dir out_nano_hq_meta_1000 --threads $CPU --min-overlap 1000
/home/ijt/bin/Flye-2.9/bin/flye --meta --nano-hq data.fastq.gz.subseq.fq --out-dir out_nano_hq_meta_2000 --threads $CPU --min-overlap 2000
/home/ijt/bin/Flye-2.9/bin/flye --meta --nano-hq data.fastq.gz.subseq.fq --out-dir out_nano_hq_meta_4000 --threads $CPU --min-overlap 4000

source /home/ijt/miniconda3/etc/profile.d/conda.sh
#conda activate mitozEnv
conda activate mitos

cd out_nano_hq_1000
#mitoz annotate --genetic_code 5 --clade Nematoda --outprefix mitoZ --thread_number 36 --fastafile assembly.fasta
mkdir mitos
runmitos.py -i assembly.fasta -c 5 -o mitos -R /home/ijt/mitos/ -r refseq81m 1> runmitos.out 2> runmitos.err
cd ../

cd out_nano_hq_2000
#mitoz annotate --genetic_code 5 --clade Nematoda --outprefix mitoZ --thread_number 36 --fastafile assembly.fasta
mkdir mitos
runmitos.py -i assembly.fasta -c 5 -o mitos -R /home/ijt/mitos/ -r refseq81m 1> runmitos.out 2> runmitos.err
cd ../

cd out_nano_hq_4000
#mitoz annotate --genetic_code 5 --clade Nematoda --outprefix mitoZ --thread_number 36 --fastafile assembly.fasta
mkdir mitos
runmitos.py -i assembly.fasta -c 5 -o mitos -R /home/ijt/mitos/ -r refseq81m 1> runmitos.out 2> runmitos.err
cd ../

cd out_nano_hq_meta_1000
#mitoz annotate --genetic_code 5 --clade Nematoda --outprefix mitoZ --thread_number 36 --fastafile assembly.fasta
mkdir mitos
runmitos.py -i assembly.fasta -c 5 -o mitos -R /home/ijt/mitos/ -r refseq81m 1> runmitos.out 2> runmitos.err
cd ../

cd out_nano_hq_meta_2000
#mitoz annotate --genetic_code 5 --clade Nematoda --outprefix mitoZ --thread_number 36 --fastafile assembly.fasta
mkdir mitos
runmitos.py -i assembly.fasta -c 5 -o mitos -R /home/ijt/mitos/ -r refseq81m 1> runmitos.out 2> runmitos.err
cd ../

cd out_nano_hq_meta_4000
#mitoz annotate --genetic_code 5 --clade Nematoda --outprefix mitoZ --thread_number 36 --fastafile assembly.fasta
mkdir mitos
runmitos.py -i assembly.fasta -c 5 -o mitos -R /home/ijt/mitos/ -r refseq81m 1> runmitos.out 2> runmitos.err
cd ../
