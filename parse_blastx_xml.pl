#!/usr/bin/perl -w
use strict ;







if (@ARGV != 2) {
    print "$0 dir prefix\n" ;
	exit ;
}

my $dir = shift ;
my $prefix = shift ;

open OUT, ">", "$prefix.final.result" or die "can't create final result!\n" ;


chdir "$dir" or die "can't change to $dir !\n" ;
opendir(DIR, ".") or die "can't opendir $!"; 



while (defined(my $file = readdir(DIR))) {

    if ($file =~ /(\S+).out/) {

	my $subject = '' ;

	my $subject_L = '' ;
	my $subject_R = '' ;
       
	my $query = '' ;

	my $query_L = '' ;
	my $query_R =  '';

	my $def = '' ;
	my $score = '' ;
	my $evalue = '' ;
	my $identity = '' ;
	my $organism = '' ;



	open (IN, $file) or die "can't open file!\n" ;

	while(<IN>) {

	    if (/<Iteration_query-def>(\S+)<\/Iteration_query-def>/ ) {
		$query = $1 ;
		print "$query\n" ;
	    }

	    if (/<Hit_id>(\S+)<\/Hit_id>/) {
		$subject = $1 ;
	    }

	    if (/<Hit_def>(.+)<\/Hit_def>/) {
		$def = $1 ;
		
		if ($def =~ /(.+?) \[(.+?)\]/) {
		    $organism = $2 ;
		    $def = $1 ;
		}

	    }
	    
	    if (/<Hsp_score>(\S+)<\/Hsp_score>/) {
		$score = $1 ;
	    }
	    
	    if (/<Hsp_evalue>(\S+)<\/Hsp_evalue>/) {
		$evalue = $1 ;
	    }


	    if (/<Hsp_query-from>(\d+)<\// ) {
		$query_L = $1 ;
	    }

	    if (/<Hsp_query-to>(\d+)<\// ) {
		$query_R = $1 ;
            }
	    
	    if (/<Hsp_hit-from>(\d+)/ ) {
		$subject_L = $1 ;
	    }
	    if (/<Hsp_hit-to>(\d+)/ ) {
		$subject_R = $1 ;
	    }



	    if (/<Hsp_identity>(\S+)<\/Hsp_identity>/) {
		$identity = $1 ;


		print OUT "$query\t$subject\t'$organism'\t'$def'\t$score\t$query_L\t$query_R\t$subject_L\t$subject_R\t$evalue\t$identity\n" ;
	    }
	  



	}
	


    }
	    

}


