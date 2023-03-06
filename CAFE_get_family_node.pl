#!/usr/bin/perl -w
use strict;







if (@ARGV != 2) {
    print "$0 summary_run1_fams.txt NODE_name\n" ; 
	exit ;
}

my $file = shift ; 
my $NODEname = shift ; 



open (IN, $file) or die "dadakjdadjklad\n" ; 



my $gain = 0 ;
my $contract = 0 ;
my $rapid = 0 ; 



my $modNODEname = $NODEname ;
$modNODEname =~ s/\<// ;
$modNODEname =~ s/\>// ;
print "node is $NODEname, changed to $modNODEname\n" ; 

open GAIN, ">", "$file.$modNODEname.expandOG" or die "daosdpaosd\n" ;
open CONTRACT, ">", "$file.$modNODEname.contractOG" or die "daposdpadpoao\n" ;


while (<IN>) {

    chomp;



    
    my @r = split /\s+/, $_ ; 
    my @families = split /\,/ ,$r[1] ; 

    $r[0] =~ s/\<// ;
    $r[0] =~ s/\>// ;
    $r[0] =~ s/\:// ; 
    next unless $r[0] eq $modNODEname ; 
    

    for (my $i = 0 ; $i < @families ; $i++) {
	#print "$families[$i]\n" ; 

	if ( $families[$i] =~ /(\S+)\[([+-])(\d+)(\*?)\]/ ) {
	    #print "$1\t$2\t$3\t$4\n" ;

	    my $OG = $1 ;
	    my $size = $3 ;
	    my $direction = $2 ;
	    
	    my $israpid = 0 ;
	    $israpid = 1 if $4 eq '*' ; 


	    
	    $gain++ if $direction eq '+' ;
	    $contract++ if $direction eq '-'  ;
	    $rapid++ if $israpid == 1 ;


	    if ($direction eq '+' ) {
		print GAIN "$OG\n" ; 
	    }
	    else {
		print CONTRACT "$OG\n" ; 
	    }
	    
	    
	}
	
    }


    
}
close(IN) ; 


print "Expansion: $gain\n" ;
print "Contraction: $contract \n" ;
print "Rapid: $rapid\n" ; 

