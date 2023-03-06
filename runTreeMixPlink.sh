#!/bin/bash

if [ $# -eq 0 ]
then
    echo "runTreeMixPlink.sh CLUST VCF MAX_EDGES ITERATIONS OUTGROUP"
    exit 1
fi


CLUST=$1
VCF=$2
EDGES=$3
ITER=$4
OUTGROUP=$5

# plink path
RUNPLINK=/home/ijt/bin/plink_20200921/plink

# retrieve
#awk '{print $1 "\t" $1 "\t" $6}' $CLUSTFILE | grep -v NA > clust
awk '{print $1}' $CLUST > $CLUST.samples

# check num. isolates
printf "Number of isolates"
wc -l $CLUST.samples


# subset these isolates and biallelic alleles only
printf "\n\nSubsetting $VCF"
/home/ijt/miniconda3/bin/bcftools view -m2 -M2 -v snps -S clust.samples $VCF > $VCF.subset.vcf


# remove sites that has all missing bases in any group
printf "\n\nRemoving sites in $VCF.subset.vcf"
/mnt/nas1/ijt/perlscripts_jit/vcfOutputSitesWithEntireLineageMissing.pl $VCF.subset.vcf $CLUST > $CLUST.missing.sites


# number missing sites
printf "\n\nNum. missing sites: "
wc -l $CLUST.missing.sites


printf "\n\nRun Plink:  vcf -> Plink file"
$RUNPLINK --vcf $CLUST.lineageNoEntireMissing.vcf  --make-bed --recode --set-missing-var-ids @:#:\$1,\$2 --allow-extra-chr --double-id --id-delim ';' --out input  

printf "\n\nRun Plink: Identify linked sites"
$RUNPLINK --bfile input --indep-pairwise 50 10 0.5 --r2 --allow-extra-chr --out pruning

printf "\n\nRun Plink: Prune linked sites"
$RUNPLINK --bfile input --extract pruning.prune.in --make-bed --recode --allow-extra-chr --out output

printf "\n\nRun Plink: Get frequency within each group"
$RUNPLINK --bfile output --freq --missing --within $CLUST --recode --allow-extra-chr --allow-no-sex --out plink


# plink output to treemix input
gzip plink.frq.strat

# check if any group has zero count (total missing base)
zless plink.frq.strat.gz | awk '$8 == 0'  > error.missing.sites


# convert this file to treemix run
printf "\n\nConvert Plink to treemix file\n"
/mnt/nas1/ijt/perlscripts_jit/plink2treemix.py plink.frq.strat.gz plink.treemix.frq.gz

# run plink!
printf "\n\nRun Treemix!"
/mnt/nas1/ijt/perlscripts_jit/runTreeMix.pl plink.treemix.frq.gz $EDGES $ITER $OUTGROUP


