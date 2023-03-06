#!/bin/bash

if [ $# -eq 0 ]
then
    echo "runMaker.sh augustusSpecies Species CPU"
    exit 1
fi


AUGUSSPECIES=$1
SPECIES=$2
CPU=$3

species=$SPECIES

# 1st round
mpiexec -n $CPU maker -base=01Round_rmlib_est2genome_protein2genome 1> 01Round.out 2> 01Round.err

cd 01Round_rmlib_est2genome_protein2genome.maker.output
NAME=01Round_rmlib_est2genome_protein2genome_master_datastore_index ; gff3_merge -d $NAME.log -o all.gff ; fasta_merge -d $NAME.log

# SNAP training first time!
mkdir snap ; cd snap ; cp -s ../all.gff .
#4601 models <- choose this one
maker2zff -x 0.01 all.gff ; awk '{print $4}' genome.ann | sort | uniq | wc -l

# Try 500?
~/bin/SNAP/fathom -categorize 500 genome.ann genome.dna
~/bin/SNAP/fathom -export 500 -plus uni.ann uni.dna
~/bin/SNAP/forge export.ann export.dna
~/bin/SNAP/hmm-assembler.pl snapFirst . > ../../snapFirst.hmm


# #2nd round
cd ../../
cp /mnt/nas1/ijt/program_params/maker/maker_opt_02Round.ctl maker_opts.ctl
mpiexec -n $CPU maker -base=02Round_snapfirst 1> 02Round.out 2> 02Round.err

cd 02Round_snapfirst.maker.output
NAME=02Round_snapfirst_master_datastore_index
gff3_merge -d $NAME.log -o all.gff
fasta_merge -d $NAME.log ## generates fasta's, no output for this dataset
mkdir snap ; cd snap ; cp -s ../all.gff .


maker2zff -x 0.01 all.gff ; awk '{print $4}' genome.ann | sort | uniq | wc -l
~/bin/SNAP/fathom -categorize 500 genome.ann genome.dna
~/bin/SNAP/fathom -export 500 -plus uni.ann uni.dna
~/bin/SNAP/forge export.ann export.dna
~/bin/SNAP/hmm-assembler.pl snapSecond . > ../../snapSecond.hmm

cd ../../




# 3rd round

sed -i 's/snapFirst.hmm//' maker_opts.ctl
sed -i "s/augustus_species=/augustus_species=$AUGUSSPECIES/" maker_opts.ctl
sed -i "s/pred_gff=/pred_gff=augustus.hints.gtf.formaker.gff/" maker_opts.ctl
sed -i "s/min_protein=0/min_protein=30/" maker_opts.ctl
sed -i "s/single_exon=0/single_exon=1/" maker_opts.ctl

# run!
mpiexec -n $CPU maker -base=03Round_augusBraker1_braker1model 1> 03Round.out 2> 03Round.err
cd 03Round_augusBraker1_braker1model.maker.output

NAME=03Round_augusBraker1_braker1model_master_datastore_index.log ; gff3_merge -d $NAME -o all.gff ; fasta_merge -d $NAME

touch exclude.scaffolds
/mnt/nas1/ijt/perlscripts_jit/makerGff2mygff.py --gff all.gff \
	--proteinfile 03Round_augusBraker1_braker1model.all.maker.proteins.fasta \
	--transcriptfile 03Round_augusBraker1_braker1model.all.maker.transcripts.fasta \
	--speciesprefix $SPECIES --excludescaffolds exclude.scaffolds

#gff2fasta_onlycoding_maker.pl $SPECIES.gff ../ref.fa 1 $species.aa.fa > log
#gff2fasta_onlycoding_maker.pl $SPECIES.gff ../ref.fa 0 $species.nuc.fa > log

gff2fasta_onlycoding_makerAsInput.pl $SPECIES.gff ../ref.fa 1 $species.aa.fa > log
gff2fasta_onlycoding_makerAsInput.pl $SPECIES.gff ../ref.fa 0 $species.nuc.fa > log



# 4th round

cd ../
sed -i "s/augustus_species=$AUGUSSPECIES/augustus_species=/" maker_opts.ctl
sed -i "s/pred_gff=augustus.hints.gtf.formaker.gff/pred_gff=/" maker_opts.ctl
sed -i "s/model_pass=0/model_pass=1/" maker_opts.ctl
sed -i "s:maker_gff=01Round_rmlib_est2genome_protein2genome.maker.output/all.gff:maker_gff=03Round_augusBraker1_braker1model.maker.output/all.gff:" maker_opts.ctl
sed -i 's/snaphmm=/snaphmm=snapSecond.hmm/' maker_opts.ctl

mpiexec -n $CPU maker -base=04Round_augusBraker1_braker1model_snap 1> 04Round.out 2> 04Round.err

cd 04Round_augusBraker1_braker1model_snap.maker.output
NAME=04Round_augusBraker1_braker1model_snap_master_datastore_index.log ; gff3_merge -d $NAME -o all.gff ; fasta_merge -d $NAME

touch exclude.scaffolds
/mnt/nas1/ijt/perlscripts_jit/makerGff2mygff.py --gff all.gff \
	--proteinfile 04Round_augusBraker1_braker1model_snap.all.maker.proteins.fasta \
	--transcriptfile 04Round_augusBraker1_braker1model_snap.all.maker.transcripts.fasta \
	--speciesprefix $species --excludescaffolds exclude.scaffolds

#gff2fasta_onlycoding_maker.pl $species.gff ../ref.fa 1 $species.aa.fa > log
#gff2fasta_onlycoding_maker.pl $species.gff ../ref.fa 0 $species.nuc.fa > log

gff2fasta_onlycoding_makerAsInput.pl $SPECIES.gff ../ref.fa 1 $species.aa.fa > log
gff2fasta_onlycoding_makerAsInput.pl $SPECIES.gff ../ref.fa 0 $species.nuc.fa > log



# 5th round

cd ../
sed -i 's/snaphmm=snapSecond.hmm/snaphmm=/' maker_opts.ctl
sed -i 's/gmhmm=/gmhmm=gmhmm.mod/' maker_opts.ctl


# run!
# actually folder name is wrong ; need to update next time
mpiexec -n $CPU maker -base=05Round_augusBraker1_braker1model_gmhmm 1> 05Round.out 2> 05Round.err 
cd 05Round_augusBraker1_braker1model_gmhmm.maker.output
NAME=05Round_augusBraker1_braker1model_gmhmm_master_datastore_index.log ; gff3_merge -d $NAME -o all.gff ; fasta_merge -d $NAME

touch exclude.scaffolds
/mnt/nas1/ijt/perlscripts_jit/makerGff2mygff.py --gff all.gff \
	--proteinfile 05Round_augusBraker1_braker1model_gmhmm.all.maker.proteins.fasta \
	--transcriptfile 05Round_augusBraker1_braker1model_gmhmm.all.maker.transcripts.fasta \
	--speciesprefix $species --excludescaffolds exclude.scaffolds

#gff2fasta_onlycoding_maker.pl $species.gff ../ref.fa 1 $species.aa.fa > log
#gff2fasta_onlycoding_maker.pl $species.gff ../ref.fa 0 $species.nuc.fa > log

gff2fasta_onlycoding_makerAsInput.pl $SPECIES.gff ../ref.fa 1 $species.aa.fa > log
gff2fasta_onlycoding_makerAsInput.pl $SPECIES.gff ../ref.fa 0 $species.nuc.fa > log
