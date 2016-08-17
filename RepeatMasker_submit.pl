#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


#my $RM = "/software/pubseq/bin/RepeatMasker " ; 

my $RM = "RepeatMasker " ; 
my $PI = `echo $$` ;	chomp($PI) ;
my $ram = 3 ; 

if (@ARGV != 2) {
	print "$0 fasta extra_commands_in_double_quotes\n\n" ;
	print "script to partition fastas and submit bjobs arrays\n\n" ;
	exit ;
}

my $filenameA = $ARGV[0];
my $commands = $ARGV[1];


my $dir = "$filenameA.tmp" ;

if (-d "$dir") {
	print "$dir present! delete old ones..\n" ;
	system("rm -rf $dir") ;



}
mkdir "$dir" or die "oops!\n" ;
chdir "$dir" ;


my $num = 1 ;

open (IN, "../$filenameA") or die "oops!\n" ;

	my $read_name = '' ;
	my $read_seq = '' ;

	while (<IN>) {
	    if (/^>(\S+)/) {
		$read_name = $1 ;
		$read_seq = "" ;
		
		while (<IN>) {

			if (/^>(\S+)/) {

				open OUT , ">", "$num.fa" or die "can't create $num.fa" ;
			       	print OUT ">$read_name\n$read_seq\n" ;
				close(OUT) ;
				$num++ ;


			    $read_name = $1 ;
			    $read_seq = "" ;

			}
			else {
			    chomp ;
			    $read_seq .= $_ ;
			}


		}

	    }
	}

close(IN) ;



open OUT , ">", "$num.fa" or die "can't create $num.fa" ;
print OUT ">$read_name\n$read_seq\n" ;
close(OUT) ;

my $bjob_command = '' ; 

#my $bjob_command = 'bsub -q normal -R "select[type==X86_64 && mem > 3000] rusage[mem=3000]" -M3000000  -J "muwaha'. $PI . '[1-' .
#        	        "$num]" . '" -o RM.%I.o -e RM.%I.e "' . "$RM " . ' -xm -xsmall -gff -s -nolow '.  $commands   .' \$LSB_JOBINDEX.fa   "' ;

# map array mapping
open QSH, '>', "map_array.sh" or die "2" ;
print QSH "$RM -xm -xsmall -gff -s -nolow " . $commands . ' $SGE_TASK_ID.fa ' ; 
close(QSH) ;

$bjob_command = 'qsub -t 1-' . $num . ':1 -V -cwd -S /bin/bash -N Rmask' . $PI .  ' -l mem_req='. $ram . 'G,s_vmem=' . $ram . 'G map_array.sh';


print "command to submit: $bjob_command\n" ;


system("$bjob_command\n") ;



print "coffee break!!\n" ;
