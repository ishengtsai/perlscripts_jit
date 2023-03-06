fasta_cleanName.intoDots.pl genome.contigs.fasta
mv genome.contigs.fasta.changed.fa raw.assem.fa  
../winMasker/windowmasker -mk_counts -in raw.assem.fa -infmt fasta -out raw.assem.count -sformat obinary ; 
../winMasker/windowmasker -ustat raw.assem.count -in raw.assem.fa -out raw.assem.fa.masked -outfmt fasta ; 
mv raw.assem.fa.masked genome.fa
gzip genome.fa
./hm.batchB1.initiation_and_all_lastz genome  &
./hm.batchB2.chainNet_and_netToMaf genome ＆
./hm.batchB3.haplomerger genome & 
./hm.batchB4.refine_unpaired_sequences genome
./hm.batchB5.merge_paired_and_unpaired_sequences genome
fastn2stats.py --fastn raw.assem.fa
