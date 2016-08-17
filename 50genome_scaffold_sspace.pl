#!/usr/bin/env perl

use strict;
use warnings;
use File::Spec;


if (@ARGV != 3) {
    print STDERR "script usage: $0 ref 600bp_lane 3kb_PCR_lane \n\n\n\n";
    print STDERR 'pathfind -t study -id "50 Helminth Genomes Initiative" -f fastq' . "\n" ; 
    print STDERR "\n" ; 

    exit(1);
}


my $mapsplitterbin = '/home/tk6/bin/python3/map_splitter-qsub.py ' ; 
#my $mapsplitterbin = '/home/tk6/bin/python3/map_splitter-qsub.py ' ; 


my $ref = $ARGV[0] ; 
my $lane_noPCR = $ARGV[1] ; 
my $lane_3kb = $ARGV[2];


# bsub job names
my $job_number = int(rand(4242424242));  # 42 is a GOOD number

print "ref: $ref\n" ;
print "noPCR: $lane_noPCR\n" ;
print "lane_3kb: $lane_3kb\n" ;


# bsub job to get fasta files
#system_call("~mh12/git/python3/bsub.py --out get_reads.o --err get_reads.e 0.5 $get_reads_name ~jit/bin/velvet_produce_fastqGZ.pl $lane");

# map splitter
if ( -e "$lane_noPCR\_2.fastq" ) {

    
    system_call("$mapsplitterbin --split_mem 5 --setup_mem 10 --array_mem 8 --tmpdir tmpnoPCR -c finaljob.$job_number -o \" -i 500 -r 10 -x -m 70 \" -k 13 -s 6 --keep_raw_only    smalt $ref SMALT.noPCR $lane_noPCR\_1.fastq $lane_noPCR\_2.fastq ");

}
elsif ( -e"$lane_noPCR\_2.fastq.gz" ) {
    
 system_call("$mapsplitterbin --setup_mem 10 --split_mem 5  --array_mem 8 --tmpdir tmpnoPCR -c finaljob.$job_number -o \" -i 500 -r 10 -x -m 70 \" -k 13 -s 6 --keep_raw_only    smalt $ref SMALT.noPCR     $lane_noPCR\_1.fastq.gz $lane_noPCR\_2.fastq.gz ");   
    
}
else {
    print "$lane_noPCR not present!!! exiting....\n" ; 
    exit ; 
}


# make file for sspace
#system_call("~mh12/git/python3/bsub.py --dep $job_number.finaljob --out diffcon.o --err diffcon.e 2 $job_number.map.parse '\"samtools view -F 2 SMALT.noPCR/out.raw.bam | sam2fastq.2files.pl noPCR \"' ") ; 

my $merge_command = 'samtools view -F 2 SMALT.noPCR/out.raw.bam | sam2fastq.2files.pl noPCR' ;
my $qsub_command = '/home/tk6/bin/python3/qsub.v2.py ' . ' --dep "finaljob.' . $job_number . '" 10 map.parse.'. $job_number  .' "' . "$merge_command" . '"';

system_call("$qsub_command") ; 

# make data strcuture
mkdir "sspace_noPCR"; 
chdir "sspace_noPCR" or die "ooooops\n"  ; 
system("perl /home/ishengtsai/bin/perlscripts/little.helpSSpace.pl $ref > doit.sh") ; 
system("ln -s ../$ref") ; 
system("ln -s ../noPCR_1.fastq ") ; 
system("ln -s ../noPCR_2.fastq ") ;
system("echo \"LIB noPCR_1.fastq noPCR_2.fastq 450 0.3 FR\" > lib2") ; 
system("chmod 755 ./doit.sh") ; 

# run sspace 1st round
system_call("/home/tk6/bin/python3/qsub.v2.py --dep map.parse.$job_number --out sspace.1st.o --err sspace.1st.e 6 sspace.1stround.$job_number \" ./doit.sh \"  ") ;




# now make data strcture for 3kb
chdir "../" ; 
system("ln -s sspace_noPCR/final.scaffolds.fasta noPCR.scaff.fa") ;

# map splitter for 3kb
# map splitter

if ( -e "$lane_3kb\_1.fastq" ) {

    system_call("$mapsplitterbin --depend sspace.1stround.$job_number --split_mem 5  --setup_mem 10 --array_mem 8 --combine_mem 20 --tmpdir tmp3kb -c finaljob2.$job_number -o \" -i 3000 -r 10 -x -m 70 \" -k 13 -s 6 -r --keep_raw_only smalt noPCR.scaff.fa SMALT.3kb $lane_3kb\_1.fastq $lane_3kb\_2.fastq ");

}
elsif ( -e"$lane_3kb\_1.fastq.gz" ) {

    system_call("$mapsplitterbin --depend sspace.1stround.$job_number --setup_mem 10 --split_mem 5  --array_mem 8 --combine_mem 20 --tmpdir tmp3kb -c finaljob2.$job_number -o \" -i 3000 -r 10 -x -m 70 \" -k  13 -s 6 -r --keep_raw_only smalt noPCR.scaff.fa SMALT.3kb $lane_3kb\_1.fastq.gz $lane_3kb\_2.fastq.gz ");

}
else {
    print "$lane_3kb not found!!! exiting..\n" ; 
    exit ; 

}



# make file for sspace ; some errors here!!
system_call("/home/tk6/bin/python3/qsub.v2.py  --dep finaljob2.$job_number --out diffcon2.o --err diffcon2.e 10 map2.parse.$job_number \" samtools view -F 2 SMALT.3kb/out.raw.bam | sam2fastq.2files.pl 3kb \" ") ;


# data structure for 3kb
mkdir "sspace_3kb" ; 
chdir "sspace_3kb" or die "oooops\n" ; 
system("perl /home/ishengtsai/bin/perlscripts/little.helpSSpace.pl noPCR.scaff.fa > doit.sh") ;
system("ln -s ../sspace_noPCR/final.scaffolds.fasta noPCR.scaff.fa") ; 
system("ln -s ../3kb_1.fastq ") ;
system("ln -s ../3kb_2.fastq ") ;
system("echo \"LIB 3kb_1.fastq 3kb_2.fastq 3000 0.3 FR\" > lib2") ;
system("chmod 755 ./doit.sh") ;

# run sspace 2nd round                                                                                                                                                       

system_call("/home/tk6/bin/python3/qsub.v2.py --dep map2.parse.$job_number --out sspace.2nd.o --err sspace.2nd.e 6 sspace.2ndround.$job_number \" ./doit.sh \" ") ;

# now we copy the scaffold files and delete all the intermediate files
chdir "../" ; 
mkdir "final_scaffolds" ; 
chdir "final_scaffolds" ; 
system_call("/home/tk6/bin/python3/qsub.v2.py --dep sspace.2ndround.$job_number --out cp.o --err cp.e 2 copy.$job_number \" cp ../sspace_noPCR/final.scaffolds.fasta noPCR.scaff.fa  ;   cp ../sspace_3kb/final.scaffolds.fasta noPCR.3kb.scaff.fa  ; rm -rf ../SMALT*/out.raw.bam \" ") ;




print "\n\n\n all done!!! cooooo heeeee break!!!!\n" ; 



# usage: system_call(string)
# Runs the string as a system call, dies if call returns nonzero error code
sub system_call {
    my $cmd  = shift;
    print "$cmd\n";
    if (system($cmd)) {
        print STDERR "Error in system call:\n$cmd\n";
        exit(1);
    }
}
