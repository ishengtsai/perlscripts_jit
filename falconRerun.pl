#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV != 6) {
    print "$0 max_diff max_cov min_cov bestn min_len1 min_len2\n" ;
    print "Need to run: source /home/ijt/bin/FALCON-integrate/env.sh before\n" ; 
    exit ;
}

my $max_diff = shift ;
my $max_cov = shift ;
my $min_cov = shift ;
my $bestn = shift ;
my $min_len1 = shift ;
my $min_len2 = shift ; 



#time fc_ovlp_filter --db /mnt/nas1/ijt/falcon/Para-2/1-preads_ovl/preads.db --fofn /mnt/nas1/ijt/falcon/Para-2/1-preads_ovl/merge-gather/las.fofn --max_diff 100 --max_cov 100 --min_cov 1 --bestn 10 --n_core 24 --min_len 5000 >| preads.ovl
    
my $command = "time /home/ijt/bin/FALCON-integrate/fc_env/bin/fc_ovlp_filter --db ../1-preads_ovl/preads.db --fofn ../1-preads_ovl/merge-gather/las.fofn --max_diff $max_diff --max_cov $max_cov --min_cov $min_cov --bestn $bestn --n_core 24 --min_len  $min_len1 " . " >| preads.ovl" ; 

print "$command\n" ; 
system("$command") ; 

system("ln -sf ../1-preads_ovl/db2falcon/preads4falcon.fasta ./preads4falcon.fasta") ; 

# Given preads.ovl,
# write sg_edges_list, c_path, utg_data, ctg_paths.
$command  = " time fc_ovlp_to_graph  --min_len $min_len2 preads.ovl " . ' >| fc_ovlp_to_graph.log ' ; 
system("$command") ; 

# Given sg_edges_list, utg_data, ctg_paths, preads4falcon.fasta,
# write p_ctg.fa and a_ctg_all.fa,
# plus a_ctg_base.fa, p_ctg_tiling_path, a_ctg_tiling_path, a_ctg_base_tiling_path:
system("time fc_graph_to_contig") ; 

system("rm -f ./preads4falcon.fasta") ; 

# Given a_ctg_all.fa, write a_ctg.fa:
system("time fc_dedup_a_tigs") ; 


system("fasta_include_above_len.pl p_ctg.fa 1000") ;
system("mv p_ctg.fa.above1000.fa p_ctg.fa.max_diff$max_diff.max_cov$max_cov.min_cov$min_cov.min_len$min_len1.min_len$min_len2") ;


print "\n\n\n\nStats:\nmax_diff$max_diff.max_cov$max_cov.min_cov$min_cov.min_len$min_len1.min_len$min_len2\n" ; 
system("stats p_ctg.fa.max_diff$max_diff.max_cov$max_cov.min_cov$min_cov.min_len$min_len1.min_len$min_len2") ;

