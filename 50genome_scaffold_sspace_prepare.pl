#!/usr/bin/env perl

use strict;
use warnings;
use File::Spec;


if (@ARGV != 7) {
    print STDERR "script usage: $0 ref lane_prefix [reversecomplement?] maxrangeinsert_size standard.deviation index.ram mapping.array.ram\n\n";


    exit(1);
}


my $mapsplitterbin = '/home/tk6/bin/python3/map_splitter-qsub.py ' ; 

my $ref = $ARGV[0] ; 
my $lane_noPCR = $ARGV[1] ; 
my $reversecomplement = $ARGV[2] ; 
my $insert_size = $ARGV[3] ; 
my $sd = $ARGV[4] ;
my $index_ram = $ARGV[5] ; 
my $mapping_ram = $ARGV[6] ; 


# bsub job names
my $job_number = int(rand(4242424242));  # 42 is a GOOD number

print "ref: $ref\n" ;
print "lane: $lane_noPCR\n" ;



# bsub job to get fasta files
#system_call("~mh12/git/python3/bsub.py --out get_reads.o --err get_reads.e 0.5 $get_reads_name ~jit/bin/velvet_produce_fastqGZ.pl $lane");

# map splitter
if ( -e "$lane_noPCR\_2.fastq" ) {

    my $insert_upper = $insert_size * 1.5 ; 
    my $upper = int("$insert_upper") ; 

    if ( $reversecomplement == 1) {
	system_call("$mapsplitterbin --setup_mem $index_ram --combine_mem 20 --array_mem $mapping_ram --tmpdir tmp.$lane_noPCR -c finaljob.$job_number -r -o \" -i $upper -r 10 -x -y 0.7  \" -k 13 -s 6 --keep_raw_only smalt $ref SMALT.$lane_noPCR $lane_noPCR\_1.fastq $lane_noPCR\_2.fastq ");
    }
    else {
	system_call("$mapsplitterbin --setup_mem $index_ram --combine_mem 20 --array_mem $mapping_ram --tmpdir tmp.$lane_noPCR -c finaljob.$job_number -o \" -i $upper -r 10 -x -y 0.7 \" -k 13 -s 6 --keep_raw_only smalt $ref SMALT.$lane_noPCR $lane_noPCR\_1.fastq $lane_noPCR\_2.fastq ");
    }


}
elsif ( -e"$lane_noPCR\_2.fastq.gz" ) {
    
    my $insert_upper = $insert_size * 1.5 ;
    my $upper = int("$insert_upper") ;

    if ( $reversecomplement == 1) {
	system_call("$mapsplitterbin --setup_mem $index_ram --combine_mem 20 --array_mem $mapping_ram --tmpdir tmp.$lane_noPCR -c finaljob.$job_number -r -o \" -i $upper -r 10 -x -y 0.7 \" -k 13 -s 6 --keep_raw_only    smalt $ref SMALT.$lane_noPCR     $lane_noPCR\_1.fastq.gz $lane_noPCR\_2.fastq.gz ");   
    }
    else {
	system_call("$mapsplitterbin --setup_mem $index_ram --combine_mem 20 --array_mem $mapping_ram --tmpdir tmp.$lane_noPCR -c finaljob.$job_number -o \" -i $upper -r 10 -x -y 0.7 \" -k 13 -s 6 --keep_raw_only    smalt $ref SMALT.$lane_noPCR     $lane_noPCR\_1.fastq.gz $lane_noPCR\_2.fastq.gz ");   
    }



}
else {
    print "$lane_noPCR not present!!! exiting....\n" ; 
    exit ; 
}


# make file for sspace
#system_call("~mh12/git/python3/bsub.py --dep $job_number.finaljob --out diffcon.o --err diffcon.e 2 $job_number.map.parse '\"samtools view -F 2 SMALT.noPCR/out.raw.bam | sam2fastq.2files.pl noPCR \"' ") ; 

my $merge_command = "samtools view -F 2 SMALT.$lane_noPCR/out.raw.bam | sam2fastq.2files.pl $lane_noPCR.links" ;
my $qsub_command = '/home/tk6/bin/python3/qsub.v2.py ' . ' --dep "finaljob.' . $job_number . '" 20 map.parse.'. $job_number  .' "' . "$merge_command" . '"';

system_call("$qsub_command") ; 

# make data strcuture
mkdir "sspace.$lane_noPCR"; 
chdir "sspace.$lane_noPCR" or die "ooooops\n"  ; 
system("perl /home/ishengtsai/bin/perlscripts/little.helpSSpace.5links.pl tmp.tobescaffolded.fa > doit.sh") ; 
system("ln -s ../$ref tmp.tobescaffolded.fa") ; 
system("ln -s ../$lane_noPCR.links\_1.fastq ") ; 
system("ln -s ../$lane_noPCR.links\_2.fastq ") ;
system("echo \"LIB $lane_noPCR.links\_1.fastq $lane_noPCR.links\_2.fastq $insert_size $sd FR\" > lib2") ; 
system("chmod 755 ./doit.sh") ; 

# run sspace 1st round
system_call("/home/tk6/bin/python3/qsub.v2.py --dep map.parse.$job_number --out sspace.1st.o --err sspace.1st.e --def_slot 8 3 sspace.1stround.$job_number \" ./doit.sh \"  ") ;




# now make data strcture for 3kb
# chdir "../" ; 
# system("ln -s sspace_noPCR/final.scaffolds.fasta $lane_noPCR.scaff.fa") ;

#print "\n\n\n all done!!! cooooo heeeee break!!!!\n" ; 



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
