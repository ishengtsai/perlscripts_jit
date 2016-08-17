#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV != 3) {
	print "$0 fasta length.each.set out.prefix\n\n" ;
	exit ;
}

my $filenameA = shift ;
my $setlen = shift  ;
my $outprefix = shift; 

my $ram = 1 ; 
my $parameters = '--acc --notextw --cut_ga --noali' ; 
my $programs = '/nfs/helminths/users/jit/hmmer-3.0-linux-intel-x86_64/binaries/hmmscan ' ;
my $db = '/lustre/scratch108/parasites/jit/blastdb/Pfam27.0/Pfam-A.hmm  ' ; 


my %fastas = () ; 
my $PI = `echo $$` ;    chomp($PI) ;

my $directory_name = "$filenameA.split" ; 
mkdir "$directory_name" ; 





open (IN, "$filenameA") or die "oops!\n" ;

	my $read_name = '' ;
	my $read_seq = '' ;

	while (<IN>) {
	    if (/^>(\S+)/) {
		$read_name = $1 ;
		$read_seq = "" ;
		
		while (<IN>) {

			if (/^>(\S+)/) {
			    
			    $fastas{$read_name} = $read_seq ; 
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

$fastas{$read_name} = $read_seq ;







my $count = 1 ; 
my $realcount = 1 ;

for my $seq_name (sort keys %fastas) {

    if ( $count == $setlen ) {
        $count = 1 ;
        $realcount++ ;
    }

    if ( $count == 1 ) {
        close(OUT);
        open OUT, ">", "$directory_name/$realcount.fa" or die "oooops\n" ;
    }

    print OUT ">$seq_name\n$fastas{$seq_name}\n" ;


    $count++ ;
}



mkdir "$filenameA.$PI.hmmscan" or die "cannot create tmp dir!\n" ;
chdir "$filenameA.$PI.hmmscan" ;

my $numfastqs_tmp = `ls ../$directory_name/ | sort -n | tail -n 1` ;
if ( $numfastqs_tmp =~ /(^\d+)\./ ) {
        $count = $1 ;
        print "number of fastas: $count\n" ;
}


print "\n\nsubmitting job!\n" ;


my $bjob_command ;
$bjob_command = 'bsub -q normal -R "select[type==X86_64 && mem > ' . $ram . '000] rusage[mem=' . $ram . '000]" -M' . $ram . '000  -J "augus'. $PI . '[1-' .
                "$count]" . '" -o %I.o -e .%I.e "' .
                "$programs $parameters --tblout " . '\$LSB_JOBINDEX'  . ".tableout  --domtblout " . '\$LSB_JOBINDEX'  .  ".domainout $db ../$directory_name/" . '\$LSB_JOBINDEX'  . ".fa  > " .'\$LSB_JOBINDEX.out' . 
                '"' ;


print "$bjob_command\n" ; 
system("$bjob_command") ; 


$bjob_command = 'bsub -q normal -R "select[type==X86_64 && mem > 1000] rusage[mem=1000]" -M1000  -J 2merge' . $PI
    . ' -o 2merge.o -e 2merge.e -w \'done(augus' . $PI . ')\' "' . "cat *.out > ../$filenameA.$PI.hmmscan.$outprefix.out \; cat *.tableout > ../$filenameA.$PI.hmmscan.perseq.$outprefix.out \; cat *.domainout > ../$filenameA.$PI.hmmscan.perdomain.$outprefix.out " . '"' ;

print "$bjob_command\n" ;
system("$bjob_command") ;

chdir("../") ;



print "\n\nall done! coffee break!\n\n\n" ; 
