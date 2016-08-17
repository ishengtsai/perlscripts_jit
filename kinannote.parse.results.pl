#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV != 1) {
    print "$0 species.prefix\n" ; 
	exit ;
}

my $species = $ARGV[0];

my %kinome = () ; 

open (IN, "$species.draft_kinome") or die "doapodspoadoas\n" ; 
my $header = <IN> ; 
while (<IN>) {

    chomp; 
    my @r = split /\t/, $_ ; 


    $r[7] = uc($r[7]) ; 
    $r[4] = uc($r[4]) ; 

    #print "$r[0]\t'$r[4]'\t'$r[7]'\n" ; 


    if ( $r[7] ) {

	if ( $r[7] eq 'AGC' ) {
	    $r[7] = 'AGC/AGC-UNIQUE' ; 
	}
	elsif ( $r[7] eq 'CAMK' ) {
	    #print "woo $r[0]\t'$r[4]'\t'$r[7]'\n" ;
	    $r[7] = 'CAMK/CAMK-UNIQUE' ; 
	}
	elsif ( $r[7] eq 'CK1' ) {
	    $r[7] = 'CK1/CK1-UNIQUE' ;
	}
	elsif ( $r[7] eq 'TK' ) {
	    $r[7] = 'TK/TK-UNIQUE' ;
	}
	
	if ( $kinome{$r[7]} ) {
	    $kinome{$r[7]} .= ",$r[0]" ; 
	}
	else {
	    $kinome{$r[7]} .= "$r[0]" ;
	}       
    }
    elsif ( $r[4] eq 'PAB-DEPENDENT POLY(A) SPECIFIC RIBONUCLEASE SUBUNIT' ) {
	if ( $kinome{'PAB-DEPENDENT POLY(A) SPECIFIC RIBONUCLEASE SUBUNIT'} ) {
            $kinome{'PAB-DEPENDENT POLY(A) SPECIFIC RIBONUCLEASE SUBUNIT'} .= ",$r[0]" ;
        }
        else {
            $kinome{'PAB-DEPENDENT POLY(A) SPECIFIC RIBONUCLEASE SUBUNIT'} .= "$r[0]" ;
        }


    }
    elsif ( $r[4] eq uc('SPECIFIC RIBONUCLEASE SUBUNIT') ) {
	if ( $kinome{'SPECIFIC RIBONUCLEASE SUBUNIT'} ) {
            $kinome{'SPECIFIC RIBONUCLEASE SUBUNIT'} .= ",$r[0]" ;
        }
        else {
            $kinome{'SPECIFIC RIBONUCLEASE SUBUNIT'} .= "$r[0]" ;
        }


    }
    elsif ( $r[4] eq 'PROTEIN KINASE SUBDOMAIN-CONTAINING PROTEIN' ) {
	if ( $kinome{'PROTEIN KINASE SUBDOMAIN-CONTAINING PROTEIN'} ) {
            $kinome{'PROTEIN KINASE SUBDOMAIN-CONTAINING PROTEIN'} .= ",$r[0]" ;
        }
        else {
            $kinome{'PROTEIN KINASE SUBDOMAIN-CONTAINING PROTEIN'} .= "$r[0]" ;
        }


    }
    elsif ( $r[4] eq 'SERINE/THREONINE PROTEIN KINASE' ) {
	if ( $kinome{'SERINE/THREONINE PROTEIN KINASE'} ) {
            $kinome{'SERINE/THREONINE PROTEIN KINASE'} .= ",$r[0]" ;
        }
        else {
            $kinome{'SERINE/THREONINE PROTEIN KINASE'} .= "$r[0]" ;
        }


    }
    elsif ( $r[4] eq 'SUBTHRESHOLD' ) {

	if ( $kinome{'SUBTHRESHOLD'} ) {
	    $kinome{'SUBTHRESHOLD'} .= ",$r[0]" ;
        }
	else {
            $kinome{'SUBTHRESHOLD'} .= "$r[0]" ;
	}



    }

}
close(IN) ; 


#for (keys %kinome ) {
#    print "test\t$_\n" ; 
#}


open (IN, "$species.merged_classifications") or die "doadoaspaodoa\n" ; 

my $subthres  = 0 ; 
my $pabnum = 0 ; 

while (<IN>) {    

    if ( /whole kinome analysis reported/ ) {

	my $tmp = <IN> ; 
	$tmp = <IN> ; 

	while (<IN>) {
	    chomp;
	    my @r = split /\t/, $_ ;
	    $r[0] =~ s/\s+$//gi ; 
	    $r[0] =~ s/\*//gi ; 

	    my $UCterm = uc($r[0]) ;


	    #print "'$r[0]'\n" ; 

	    if ( $UCterm eq 'SUBTHRESHOLD' ) {
		$subthres = $r[1] ; 
		next ; 
	    }
	    if ( $UCterm eq 'PROTEIN KINASE SUBDOMAIN-CONTAINING PROTEIN' ) {
		$pabnum = $r[1] ; 
		next ; 
	    }

	    if ( $kinome{"$r[0]"} ) {
		print "$UCterm\t$r[1]\t$kinome{$r[0]}\n" ;
	    }
	    elsif ($UCterm eq 'UNCLASSIFIED EPK' ) {
		print "$UCterm\t$r[1]\t$kinome{'SERINE/THREONINE PROTEIN KINASE'}\n" ;
            }
	    else {
		print "$UCterm\t$r[1]\n" ; 
	    }


	    last if /^UNCLASSIFIED/ ; 
	}
	
    }

}

print "\n\n\n\n" ; 
print "domain protein\t$pabnum\t$kinome{'PROTEIN KINASE SUBDOMAIN-CONTAINING PROTEIN'}\n" ; 
print "SUBTHRESHOLD\t$subthres\t$kinome{'SUBTHRESHOLD'}\n" ; 

